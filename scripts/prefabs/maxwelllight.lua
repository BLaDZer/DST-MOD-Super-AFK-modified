local assets = {
    Asset("ANIM", "anim/maxwell_torch.zip"),
    Asset("SOUND", "sound/common.fsb")
}

local prefabs = {
    "maxwelllight_flame",
    "pigtorch_flame"
}

local loot = {
    "marble",
    "marble",
    "nightmare_fuel",
    "marble"
}

-- local function onhammered(inst)
--     inst.components.lootdropper:DropLoot()
--     local fx = SpawnPrefab("collapse_small")
--     fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
--     fx:SetMaterial("wood")
--     inst:Remove()
-- end

local function changelevels(inst, order)
    for i = 1, #order do
        inst.components.burnable:SetFXLevel(order[i])
        Sleep(0.05)
    end
end

local function light(inst)
    inst.task =
        inst:StartThread(
        function()
            changelevels(inst, inst.lightorder)
        end
    )
end

-- local function onhit(inst,worker)
--     --inst.AnimState:PlayAnimation("hit")
--     --inst.AnimState:PushAnimation("idle")
-- end

-- local function extinguish(inst)
--     if inst.components.burnable:IsBurning() then
--         inst.components.burnable:Extinguish()
--     end
-- end

-- local function onupdatefueledraining(inst)
--     inst.components.fueled.rate = 1 + TUNING.PIGTORCH_RAIN_RATE * TheWorld.state.precipitationrate
-- end

-- local function onisraining(inst, israining)
--     if inst.components.fueled ~= nil then
--         if israining then
--             inst.components.fueled:SetUpdateFn(onupdatefueledraining)
--         else
--             inst.components.fueled:SetUpdateFn()
--             inst.components.fueled.rate = 1
--         end
--     end
-- end

-- local function OnVacate(inst)
--     SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
-- end

-- local function extinguish(inst)
--     if inst.components.burnable:IsBurning() then
--         inst.components.burnable:Extinguish()
--     end
-- end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.1)

    inst.AnimState:SetBank("maxwell_torch")
    --pigtorch
    inst.AnimState:SetBuild("maxwell_torch")
    --pig_torch
    inst.AnimState:PlayAnimation("idle", false)

    inst:AddTag("structure")
    inst:AddTag("wildfireprotected")
    inst:AddTag("maxlight")

    --MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "maxwelllight"

    inst:AddComponent("burnable")

    inst.components.burnable.canlight = false
    inst.components.burnable:AddBurnFX("maxwelllight_flame", Vector3(0, 0, 0), "fire_marker")
    inst.components.burnable:SetOnIgniteFn(light)

    inst.lightorder = {5, 6, 7, 8, 7}
    inst.components.burnable:Ignite()
    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(17, 27)
    inst.components.playerprox:SetOnPlayerNear(
        function()
            if not inst.components.burnable:IsBurning() then
                inst.components.burnable:Ignite()
            end
        end
    )
    -- inst.components.playerprox:SetOnPlayerFar(extinguish)

    --[[
    inst:AddComponent("fueled")
    inst.components.fueled.maxfuel = TUNING.PIGTORCH_FUEL_MAX
    inst.components.fueled.accepting = true

    inst.components.fueled:SetSections(3)

    inst.components.fueled.ontakefuelfn = function() inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel") end
    inst.components.fueled:SetSectionCallback(function(section)
        if section == 0 then
            inst.components.burnable:Extinguish()
        else
            if not inst.components.burnable:IsBurning() then
                inst.components.burnable:Ignite()
            end

            inst.components.burnable:SetFXLevel(section, inst.components.fueled:GetSectionPercent())
        end
    end)
    inst.components.fueled:InitializeFuelLevel(TUNING.PIGTORCH_FUEL_MAX)

    inst:WatchWorldState("israining", onisraining)
    onisraining(inst, TheWorld.state.israining)]]
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)

    return inst
end

-- local function arealight()
--     local inst = fn()
--     inst.lightorder = {5,6,7,8,7}
-- 	inst:AddComponent("burnable")
-- 	inst.components.burnable:Ignite()
--     inst:AddComponent("playerprox")
--     inst.components.playerprox:SetDist(17, 27 )
--     inst.components.playerprox:SetOnPlayerNear(function() if not inst.components.burnable:IsBurning() then inst.components.burnable:Ignite() end end)
--     inst.components.playerprox:SetOnPlayerFar(extinguish)
--     --inst:AddComponent("named")
--     --inst.components.named:SetName(STRINGS.NAMES["MAXWELLLIGHT"])
--     --inst.components.inspectable.nameoverride = "maxwelllight"

--     return inst
-- end

STRINGS.NAMES.MAXWELLLIGHT_AREA = "Maxwell's Light"

return Prefab("maxwelllight_area", fn, assets, prefabs)
