local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"

local SkinCouner = Class(Widget, function(self, owner)
    self.owner = owner
    self.skins_opened = 0

    Widget._ctor(self, "SkinCouner")
    self.anim = self:AddChild(UIAnim())
    self.anim:GetAnimState():SetBank("gift_popup")
    self.anim:GetAnimState():SetBuild("skingift_popup")
	self.anim:GetAnimState():OverrideSymbol("SWAP_ICON", "swap_numbers", tostring(self.skins_opened))
	self.anim:GetAnimState():PlayAnimation("activate")
	self.anim:GetAnimState():PushAnimation("open")
	self.anim:GetAnimState():PushAnimation("skin_loop", true)

    self.text = self.anim:AddChild(Text(UIFONT, 61))
    self.text:SetString(STRINGS.SKINS_COUNT)
    self.text:SetPosition(0, 170, 0)
end)

function SkinCouner:CountChanged()
	self.skins_opened = self.skins_opened + 1
	--Этого не может быть.
	if self.skins_opened > 9 then
		self.skins_opened = 0
	end
	
	self.anim:GetAnimState():PlayAnimation("skin_out")
	self.inst:DoTaskInTime(1.3, function() self.anim:GetAnimState():OverrideSymbol("SWAP_ICON", "swap_numbers", tostring(self.skins_opened)) end)
    self.anim:GetAnimState():PushAnimation("activate")
    self.anim:GetAnimState():PushAnimation("open")
    self.anim:GetAnimState():PushAnimation("skin_loop", true)
end

return SkinCouner
