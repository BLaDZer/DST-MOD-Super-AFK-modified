local assets=
{ 
    Asset("ANIM", "anim/disguiserod.zip"),
    Asset("ANIM", "anim/swap_disguiserod.zip"),
    Asset("ATLAS", "images/inventoryimages/disguiserod.xml"),
    Asset("IMAGE", "images/inventoryimages/disguiserod.tex"),
}

--local prefabs =
--{
--    "disguisesign_fx",
--}

local function OnEquip(inst, owner) 

    owner.AnimState:OverrideSymbol("swap_object", "swap_disguiserod", "swap_disguiserod")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal")

    --if inst.sign == nil then
    --    local x, y, z = inst.Transform:GetWorldPosition()
    --    inst.sign = SpawnPrefab("disguisesign_fx")
    --    inst.sign.Transform:SetPosition(x, y, z)
    --    inst.sign.Follower:FollowSymbol(owner.GUID, "swap_object", 0, 0, 0)
    --end
end

local function OnUnequip(inst, owner) 
    --if inst.sign ~= nil then
    --    inst.sign:Remove()
    --    inst.sign = nil
    --end

    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal")
end

local function OnDropped(inst)
    inst:DoTaskInTime(0,function()inst:Remove()end)
end

local function fn()
    local inst = CreateEntity()

    inst:AddTag("disguiserod")

    --inst.sign = nil

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("disguiserod")
    inst.AnimState:SetBuild("disguiserod")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("quickcast")
    --inst:AddTag("irreplaceable")
    --inst.spelltype = "SCIENCE"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("disguiserod_component")

    inst:AddComponent("tradable")
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "disguiserod"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/disguiserod.xml"
    
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HANDS
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(10)

    inst:ListenForEvent("ondropped", OnDropped)

    MakeHauntableLaunch(inst)

    return inst
end

STRINGS.NAMES.DISGUISEROD = "Rod of Disguise"
STRINGS.RECIPE_DESC.DISGUISEROD = "Take the appearance of whoever you want."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DISGUISEROD = "I'm everyone, everyone is me."

return Prefab( "common/inventory/disguiserod", fn, assets, prefabs)