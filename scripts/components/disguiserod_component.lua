local DisguiseRod_Component = Class(function(self, inst)
    self.inst = inst
    self.name = nil
end)

function DisguiseRod_Component:DoCopy(doer, target)

	local pos = doer:GetPosition()
    SpawnPrefab("collapse_small").Transform:SetPosition(pos.x, pos.y, pos.z)

	if (
        target.prefab == "asriel" or
        target:HasTag("charlie") or
        target:HasTag("engie") or
        target:HasTag("medic") or
        target:HasTag("spy") or
        target:HasTag("tf2scout")
        ) then

        if target.components.skinner.skin_name == ""..target.prefab.."_none" or target.components.skinner.skin_name == "" or target.components.skinner.skin_name == nil then
            self.name = target.prefab
        else
        	self.name = target.components.skinner.skin_name
        end

    elseif target.prefab == "plutia" then

        if target.soundsname == "iris" then
            self.name = "irisheart"
        else
            self.name = "plutia"
        end

	elseif target.prefab == "wolfgang" then

        if target.strength ~= nil then
            if target.strength == "mighty" then
                self.name = "wolfgang_mighty"
            elseif target.strength == "normal" then
                self.name = "wolfgang"
            elseif target.strength == "wimpy" then
                self.name = "wolfgang_skinny"
            else
                self.name = target.prefab
            end
        else
            self.name = target.prefab
        end

    else

	    self.name = target.prefab
	end

    doer.AnimState:SetBuild(self.name)
    
	self.name = nil
end

return DisguiseRod_Component

--doer.components.talker:Say("1", 2.5, false)


