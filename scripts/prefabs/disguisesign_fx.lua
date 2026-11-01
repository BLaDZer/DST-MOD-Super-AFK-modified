local assets=
{ 
    Asset("ANIM", "anim/disguisesign_fx.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddFollower()

    inst.AnimState:SetBank("disguisesign_fx")
    inst.AnimState:SetBuild("disguisesign_fx")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

return Prefab("disguisesign_fx", fn)
