--Drops Reset Countdown Steam Workshop Page: https://steamcommunity.com/sharedfiles/filedetails/?id=1688661034
--Website Version: https://dst-skins-checklist.firebaseapp.com/drops
--Created by Instant Noodles: https://steamcommunity.com/id/instant-noodles
--This mod may not be copied, altered, or reproduced in any way without the explicit and prior permission of the author

local Image=require("widgets/image")
local Text=require("widgets/text")
local UIAnim=require("widgets/uianim")
local Widget=require("widgets/widget")
require("drops_func")

local boxW, boxH=600, 400
local font=NUMBERFONT
local lang="EN"

local DropsPreviewWidget=Class(Widget, function(self, options)
  Widget._ctor(self, "DropsPreviewWidget")
  self.root=self:AddChild(Widget("root"))

  lang=options.language

  self.box=self.root:AddChild(Image("images/ui.xml", "black.tex"))
  self.box:SetTint(1, 1, 1, 0.75)
  self.box:SetSize(boxW/3.5, boxH)

  self.name=self.box:AddChild(Text(font, locScale(20, lang), ""))
  self.name:SetPosition(0, boxH/2-40)

  self.hr=self.box:AddChild(Image("images/ui.xml", "white.tex"))
  self.hr:SetTint(1, 1, 1, 0.5)
  self.hr:SetSize(boxW/4, 1)
  self.hr:SetPosition(0, boxH/2-55)

  self.rarity=self.box:AddChild(Text(font, locScale(20, lang), ""))
  self.rarity:SetPosition(0, boxH/2-70)

  self.image=self.box:AddChild(UIAnim())
  self.image:SetPosition(0, 50)
  self.image:GetAnimState():SetBuild("frames_comp")
  self.image:GetAnimState():SetBank("frames_comp")
  self.image:GetAnimState():Hide("NEW")
  self.image:GetAnimState():PlayAnimation("idle_on", true)

  self.description=self.box:AddChild(Text(font, locScale(16, lang), ""))
  self.description:SetPosition(0, -60)

  self.hr2=self.box:AddChild(Image("images/ui.xml", "white.tex"))
  self.hr2:SetTint(1, 1, 1, 0.5)
  self.hr2:SetSize(boxW/4, 1)
  self.hr2:SetPosition(0, -boxH/2+55)
end)

function DropsPreviewWidget:SetSkin(prefab)
  local skin=STRINGS.SKIN_NAMES[prefab]
  local rari=STRINGS.UI.RARITY[GetRarityForItem(prefab)]

  if (skin:len()>=25) then  
    self.name:SetAutoSizingString(skin, boxW/3.5-10, false)
  else
    self.name:SetString(skin)
    self.name:SetSize(locScale(20, lang))
  end

  if (rari:len()>=25) then
    self.rarity:SetAutoSizingString(rari, boxW/3.5-10, false)
  else
    self.rarity:SetString(rari)
    self.rarity:SetSize(locScale(20, lang))
  end
  self.rarity:SetColour(GetColorForItem(prefab))

  self.description:SetMultilineTruncatedString(STRINGS.SKIN_DESCRIPTIONS[prefab], 6, boxW/3.5-10, 40, true, false)

  self.image:GetAnimState():OverrideSkinSymbol("SWAP_ICON", GetBuildForItem(prefab), "SWAP_ICON")
  self.image:GetAnimState():OverrideSymbol("SWAP_frameBG", "frame_BG", GetFrameSymbolForRarity(GetRarityForItem(prefab)))
end

return DropsPreviewWidget