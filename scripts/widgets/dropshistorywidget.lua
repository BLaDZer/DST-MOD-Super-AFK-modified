--Drops Reset Countdown Steam Workshop Page: https://steamcommunity.com/sharedfiles/filedetails/?id=1688661034
--Website Version: https://dst-skins-checklist.firebaseapp.com/drops
--Created by Instant Noodles: https://steamcommunity.com/id/instant-noodles
--This mod may not be copied, altered, or reproduced in any way without the explicit and prior permission of the author

local Image=require("widgets/image")
local Text=require("widgets/text")
local Widget=require("widgets/widget")
require("drops_func")

local boxW, boxH=370, 100
local font=NUMBERFONT
local format="12"
local lang, modstr="EN", {}
local lookup={[3]=72, [5]=100, [7]=128, [9]=156, [12]=200}
local size=3
local titlesize={EN=22, EU=22, RU=20, ZH=22, ZT=22, PT=22, KO=22}

local function getLast(num, format)
  local skinslist=TheInventory:GetFullInventory()
  local prefArr, rariArr, skinArr, timeArr={}, {}, {}, {}

  local function reverse(a,b)
    if a.modified_time~=b.modified_time then
      return a.modified_time>b.modified_time
    end

    return a.item_type>b.item_type
  end

  table.sort(skinslist, reverse)

  if num>#skinslist then
    num=#skinslist
  end

  if #skinslist>0 then
    for i=1,num do
      prefArr[i]=skinslist[i].item_type
      rariArr[i]=STRINGS.UI.RARITY[GetRarityForItem(skinslist[i].item_type)]
      skinArr[i]=STRINGS.SKIN_NAMES[skinslist[i].item_type]
      timeArr[i]=ldateFormat(skinslist[i].modified_time, modstr.units, lang, format, "fullb")
    end
  end

  return prefArr, rariArr, skinArr, timeArr, #skinslist
end

local DropsHistoryWidget=Class(Widget, function(self, options)
  Widget._ctor(self, "DropsHistoryWidget")
  self.root=self:AddChild(Widget("root"))
  self.root:SetPosition(0, -139-29)

  lang, modstr=options.language, options.strings
  format, size=options.clock, options.size
  boxH=lookup[size]+15

  self.box=self.root:AddChild(Image("images/ui.xml", "black.tex"))
  self.box:SetTint(1, 1, 1, 0.75)
  self.box:SetSize(boxW, boxH)
  self.box:SetPosition(-boxW*2/3, -boxH/2)

  local pref, rari, skin, time, ownnum=getLast(size, options.clock)
  self.indx, self.date, self.skin, self.rari={}, {}, {}, {}

  if (lang=="RU" and size==3) then
    self.title=self.box:AddChild(Text(font, locScale(titlesize[lang], lang), modstr.history.title.a[lang]..size..modstr.history.title.c[lang]))
  else
    self.title=self.box:AddChild(Text(font, locScale(titlesize[lang], lang), modstr.history.title.a[lang]..size..modstr.history.title.b[lang]))
  end

  self.title:SetPosition(0, boxH/2-12)

  for i=1, size do
    if (skin[i]) then skin[i]="-   "..skin[i] end
    if (rari[i]) then rari[i]=" ("..rari[i]..")" end

    self.indx[i]=self.box:AddChild(Text(font, locScale(14, lang), i.."."))
    if (lang=="RU" and options.clock=="24") then
      self.date[i]=self.box:AddChild(Text(font, locScale(15, lang), time[i]))
    else
      self.date[i]=self.box:AddChild(Text(font, locScale(14, lang), time[i]))
    end
    self.skin[i]=self.box:AddChild(Text(font, locScale(14, lang), skin[i]))
    self.rari[i]=self.box:AddChild(Text(font, locScale(12, lang), rari[i], GetColorForItem(pref[i])))

    self.date[i]:SetPosition(-30-boxW/3+self.date[i]:GetRegionSize()*0.5, boxH/2-18+(-14*i))
    self.indx[i]:SetPosition(-40-boxW/3, boxH/2-18+(-14*i))

    if (format=="12") then
      local shift=-80
      if (lang=="RU") then shift=-75 elseif (lang=="PT") then shift=-100 end
      self.skin[i]:SetPosition(shift+boxW/6+self.skin[i]:GetRegionSize()*0.5, boxH/2-18+(-14*i))
      self.rari[i]:SetPosition(shift+boxW/6+self.rari[i]:GetRegionSize()*0.5+self.skin[i]:GetRegionSize()*1, boxH/2-18+(-14*i))
    else
      local shift=-90
      if (lang=="PT") then shift=-110 elseif (lang~="EN" and lang~="EU") then shift=-100 end
      self.skin[i]:SetPosition(shift+boxW/6+self.skin[i]:GetRegionSize()*0.5, boxH/2-18+(-14*i))
      self.rari[i]:SetPosition(shift+boxW/6+self.rari[i]:GetRegionSize()*0.5+self.skin[i]:GetRegionSize()*1, boxH/2-18+(-14*i))
    end
  end

  if ((TheFrontEnd:GetIsOfflineMode() or not TheNet:IsOnlineMode()) and (not TheInventory:HasSupportForOfflineSkins() or not TheInventory:HasDownloadedInventory())) then
    self.error=self.box:AddChild(Text(font, locScale(14, lang), modstr.history.error[lang]))
    self.error:SetPosition(0, boxH/2-18-14)

    for i=1, size do
      self.indx[i]:Hide()
    end
  end

  local function update()
    local pref, rari, skin, time, ownnum=getLast(size, format)

    if (ownnum>0 and #self.date==size) then
      for i=1, size do
        if (skin[i]) then skin[i]="-   "..skin[i] end
        if (rari[i]) then rari[i]=" ("..rari[i]..")" end

        self.date[i]:SetString(time[i])
        self.skin[i]:SetString(skin[i])
        self.rari[i]:SetString(rari[i])
        self.rari[i]:SetColour(GetColorForItem(pref[i]))

        self.date[i]:SetPosition(-30-boxW/3+self.date[i]:GetRegionSize()*0.5, boxH/2-18+(-14*i))

        local shift=0

        if (format=="12") then
          shift=-80
          if (lang=="RU") then shift=-75 elseif (lang=="PT") then shift=-100 end
          self.skin[i]:SetPosition(shift+boxW/6+self.skin[i]:GetRegionSize()*0.5, boxH/2-18+(-14*i))
          self.rari[i]:SetPosition(shift+boxW/6+self.rari[i]:GetRegionSize()*0.5+self.skin[i]:GetRegionSize()*1, boxH/2-18+(-14*i))
        else
          shift=-90
          if (lang=="PT") then shift=-110 elseif (lang~="EN" and lang~="EU") then shift=-100 end
          self.skin[i]:SetPosition(shift+boxW/6+self.skin[i]:GetRegionSize()*0.5, boxH/2-18+(-14*i))
          self.rari[i]:SetPosition(shift+boxW/6+self.rari[i]:GetRegionSize()*0.5+self.skin[i]:GetRegionSize()*1, boxH/2-18+(-14*i))
        end

        local truncSkinStr=false

        if (self.skin[i]:GetRegionSize()>=boxW/2-(shift+boxW/6)-25) then
          self.skin[i]:SetMultilineTruncatedString(skin[i], 1, boxW/2-(shift+boxW/6)-15, nil, true, false)
          self.skin[i]:SetPosition(shift+boxW/6+self.skin[i]:GetRegionSize()*0.5, boxH/2-18+(-14*i))
          truncSkinStr=true
        end

        local truncRariWidth=boxW/2-(shift+boxW/6+self.skin[i]:GetRegionSize())-15

        if KnownModIndex:IsModEnabled("workshop-1240565842") then truncSkinStr=true end

        if (truncSkinStr or truncRariWidth<=0) then
          self.rari[i]:SetString("")
        elseif (self.rari[i]:GetRegionSize()>=truncRariWidth) then
          self.rari[i]:SetMultilineTruncatedString(rari[i], 1, truncRariWidth, 20, true, false)
          self.rari[i]:SetPosition(shift+boxW/6+self.rari[i]:GetRegionSize()*0.5+self.skin[i]:GetRegionSize()*1, boxH/2-18+(-14*i))
        end

      end
    end

    if (self.error and TheInventory:HasDownloadedInventory() and ownnum>0) then
      self.error:Kill()
      self.error=nil

      for i=1, size do
        self.indx[i]:Show()
      end
    end
  end

  update()
  self.quick=self.inst:DoPeriodicTask(0.1, function() if (not self.error) then if (self.skin[1]:GetString()=="") then update() else self.quick:Cancel() end else self.quick:Cancel() end end)
  self.task=self.inst:DoPeriodicTask(3, update)
end)

return DropsHistoryWidget