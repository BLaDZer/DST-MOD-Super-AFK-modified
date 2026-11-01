--Drops Reset Countdown Steam Workshop Page: https://steamcommunity.com/sharedfiles/filedetails/?id=1688661034
--Website Version: https://dst-skins-checklist.firebaseapp.com/drops
--Created by Instant Noodles: https://steamcommunity.com/id/instant-noodles
--This mod may not be copied, altered, or reproduced in any way without the explicit and prior permission of the author

local DropsPreviewWidget=require("widgets/dropspreviewwidget")
local Image=require("widgets/image")
local ImageButton=require("widgets/imagebutton")
local Templates=require("widgets/redux/templates")
local Text=require("widgets/text")
local Widget=require("widgets/widget")
require("drops_func")

local boxW, boxH=600, 400
local directory, mod, version="", "", ""
local font=NUMBERFONT
local format="12"
local lang, modstr="EN", {}
local breakdown, rarityList={}, {}
local prefab, lastprefab, state, laststate, invalid="", "", false, nil, {}

for k,v in pairs(RARITY_ORDER) do
  table.insert(rarityList, k)
end

table.sort(rarityList, function(a,b) return RARITY_ORDER[a]>RARITY_ORDER[b] end)

local function getData(format)
  local skinslist=TheInventory:GetFullInventory()
  local data={}

  for i=1, #rarityList do
    breakdown[rarityList[i]]=0
  end

  local function reverse(a,b)
    if a.modified_time~=b.modified_time then
      return a.modified_time>b.modified_time
    end

    return a.item_type>b.item_type
  end

  table.sort(skinslist, reverse)

  local function checkValidity(mtime, itype)
    if mtime<0 or RARITY_ORDER[GetRarityForItem(itype)]==nil then
      if invalid[itype]==nil then
        print("[Drops Reset Countdown] Skin with invalid data detected: "..itype.." / "..mtime.." / "..GetRarityForItem(itype))
        invalid[itype]=mtime
      end
      return false
    end

    return true
  end

  for i=1, #skinslist do
    if checkValidity(skinslist[i].modified_time, skinslist[i].item_type) then
      local ttbl={}
      ttbl["pref"]=skinslist[i].item_type
      ttbl["rari"]=STRINGS.UI.RARITY[GetRarityForItem(skinslist[i].item_type)]
      ttbl["skin"]=STRINGS.SKIN_NAMES[skinslist[i].item_type]
      ttbl["time"]=ldateFormat(skinslist[i].modified_time, modstr.units, lang, format, "full")
      table.insert(data, ttbl)

      breakdown[GetRarityForItem(skinslist[i].item_type)]=breakdown[GetRarityForItem(skinslist[i].item_type)]+1
    end
  end

  return data
end

local function HistoryConstruct(ctx, idx)
  local row=Widget("row")
  row.root=row:AddChild(Widget("root"))
  row.idx=row.root:AddChild(Text(font, locScale(18, lang)))
  if (lang=="EN" or lang=="EU") then
    row.time=row.root:AddChild(Text(font, locScale(18, lang)))
  elseif (lang=="RU") then
    row.time=row.root:AddChild(Text(font, locScale(17, lang)))
  else
    row.time=row.root:AddChild(Text(font, locScale(16, lang)))
  end
  row.skin=row.root:AddChild(Text(font, locScale(18, lang)))
  row.rari=row.root:AddChild(Text(font, locScale(16, lang)))
  row.hover=row.skin:AddChild(ImageButton("images/ui.xml", "blank.tex", "blank.tex", "blank.tex", nil, nil, {1,1}, {0,0}))

  return row
end

local function HistoryUpdate(ctx, row, data, idx)
  if (data) then
    row.idx:SetString(idx..".")
    row.time:SetString(data.time)
    row.skin:SetString("-   "..data.skin)
    row.rari:SetString(" ("..data.rari..")")
    row.rari:SetColour(GetColorForItem(data.pref))
    row.idx:SetPosition(-60-boxW/3, 0)
    row.time:SetPosition(-30-boxW/3+row.time:GetRegionSize()*0.5, 0)

    row.hover.image:ScaleToSize(row.skin:GetRegionSize())
    row.hover.OnGainFocus=function() prefab=data.pref state=true end
    row.hover.OnLoseFocus=function() state=false end

    if (format=="12") then
      local shift=-150
      if (lang=="RU") then shift=-120 elseif (lang=="ZH" or lang=="ZT") then shift=-145 elseif (lang=="PT") then shift=-170 elseif (lang=="KO") then shift=-140 end
      row.skin:SetPosition(shift+boxW/6+row.skin:GetRegionSize()*0.5, 0)
      row.rari:SetPosition(shift+boxW/6+row.skin:GetRegionSize()*1+row.rari:GetRegionSize()*0.5, 0)
    else
      local shift=-175
      if (lang=="PT") then shift=-190 elseif (lang=="KO") then shift=-160 elseif (lang~="EN" and lang~="EU") then shift=-165 end
      row.skin:SetPosition(shift+boxW/6+row.skin:GetRegionSize()*0.5, 0)
      row.rari:SetPosition(shift+boxW/6+row.skin:GetRegionSize()*1+row.rari:GetRegionSize()*0.5, 0)
    end
  end
end

local DropsFullHistoryWidget=Class(Widget, function(self, options)
  Widget._ctor(self, "DropsFullHistoryWidget")
  self.root=self:AddChild(Widget("root"))

  lang, modstr=options.language, options.strings
  directory, format, mod, version=options.directory, options.clock, options.modname, options.modversion

  self.box=self.root:AddChild(Image("images/ui.xml", "black.tex"))
  self.box:SetTint(1, 1, 1, 0.75)
  self.box:SetSize(boxW, boxH)

  self.title=self.box:AddChild(Text(font, locScale(26, lang), modstr.fullhistory.title[lang]))
  self.title:SetPosition(0, boxH/2-20)

  self.total=self.box:AddChild(Text(font, locScale(16, lang), modstr.fullhistory.total.a[lang].."0 - "..modstr.fullhistory.total.b[lang].."0 - "..modstr.fullhistory.total.f[lang].."0"))
  self.total:SetPosition(0, boxH/2-40)

  self.breakbox=self.box:AddChild(Image("images/ui.xml", "black.tex"))
  self.breakbox:SetTint(1, 1, 1, 0.75)
  self.breakbox:SetSize(boxW/3.5, boxH)
  self.breakbox:SetPosition(boxW/2+boxW/3.5/2-1, 0)
  self.breakbox:Hide()

  self.hover=self.total:AddChild(ImageButton("images/ui.xml", "blank.tex", "blank.tex", "blank.tex", nil, nil, {1,1}, {0,0}))
  self.hover.image:ScaleToSize(self.total:GetRegionSize())
  self.hover.OnGainFocus=function() self.breakbox:Show() end
  self.hover.OnLoseFocus=function() self.breakbox:Hide() end

  self.breaktitle=self.breakbox:AddChild(Text(font, locScale(20, lang), modstr.fullhistory.total.c[lang]))
  self.breaktitle:SetPosition(0, boxH/2-25)

  self.breakhr=self.breakbox:AddChild(Image("images/ui.xml", "white.tex"))
  self.breakhr:SetTint(1, 1, 1, 0.5)
  self.breakhr:SetSize(boxW/4, 1)
  self.breakhr:SetPosition(0, boxH/2-40)

  self.breakcat={}
  for i=1, #rarityList do
    self.breakcat[i]=self.breakbox:AddChild(Text(font, locScale(15, lang), ""))
    self.breakcat[i]:SetPosition(0, boxH/2-55-(i-1)*20)
  end

  self.breakhr2=self.breakbox:AddChild(Image("images/ui.xml", "white.tex"))
  self.breakhr2:SetTint(1, 1, 1, 0.5)
  self.breakhr2:SetSize(boxW/4, 1)
  self.breakhr2:SetPosition(0, boxH/2-55-(#rarityList-1)*20-15)

  self.breaktotal=self.breakbox:AddChild(Text(font, locScale(15, lang), ""))
  self.breaktotal:SetPosition(0, boxH/2-55-(#rarityList-1)*20-15*2)

  self.preview=self.box:AddChild(DropsPreviewWidget(options))
  self.preview:SetPosition(boxW/2+boxW/3.5/2-1, 0)

  if ((TheFrontEnd:GetIsOfflineMode() or not TheNet:IsOnlineMode()) and (not TheInventory:HasSupportForOfflineSkins() or not TheInventory:HasDownloadedInventory())) then
    self.error=self.box:AddChild(Text(font, locScale(16, lang), modstr.fullhistory.error[lang]))
    self.error:SetPosition(0, boxH/2-70)
  end

  self.list=self.box:AddChild(Templates.ScrollingGrid(getData(format), {apply_fn=HistoryUpdate, item_ctor_fn=HistoryConstruct, widget_width=boxW, widget_height=22, num_visible_rows=15, num_columns=1, scrollbar_offset=-25, scrollbar_height_offset=-50, scroll_per_click=1}))
  self.list:SetPosition(0, -20)

  self.inst:ListenForEvent("giftreceiverupdate", function() if (options.autoopen~=false) then self.refreshtask=self.inst:DoTaskInTime(3, function() self:RefreshData() end) end end, ThePlayer)
  self.refreshpreview=self.inst:DoPeriodicTask(0.3, function() if (prefab~=lastprefab) then self.preview:SetSkin(prefab) lastprefab=prefab end if (state~=laststate) then if (state) then self.preview:Show() else self.preview:Hide() end laststate=state end end)
end)

function DropsFullHistoryWidget:RefreshBreakdown(total)
  if (breakdown~=nil) then
    self.breaktitle:SetString(modstr.fullhistory.total.c[lang])
    self.breaktotal:SetString(modstr.fullhistory.total.d[lang]..": "..total..modstr.fullhistory.total.e[lang].." ("..replaceNaN(roundNum(total/total*100, 0)).."%)")

    for i=1, #rarityList do
      local catStr=STRINGS.UI.RARITY[rarityList[i]]:gsub(" %b()", ""):gsub("%（.-%）", "")..": "..breakdown[rarityList[i]]..modstr.fullhistory.total.e[lang].." ("..replaceNaN(roundNum(breakdown[rarityList[i]]/total*100, 2)).."%)"
      if (catStr:len()>=47) then
        self.breakcat[i]:SetAutoSizingString(catStr, boxW/3.5-4, false)
      else
        self.breakcat[i]:SetString(catStr)
      end
      self.breakcat[i]:SetColour(SKIN_RARITY_COLORS[rarityList[i]])
    end
  end

  if (self.error and TheInventory:HasDownloadedInventory() and total>0) then
    self.error:Kill()
    self.error=nil
  end
end

function DropsFullHistoryWidget:RefreshData()
  if (self.list) then
    self.list:SetItemsData(getData(format))
  end

  self.total:SetString(modstr.fullhistory.total.a[lang]..#getData(format).." - "..modstr.fullhistory.total.b[lang]..TheInventory:GetCurrencyAmount().." - "..modstr.fullhistory.total.f[lang]..TheInventory:GetKleiPointsAmount())
  self:RefreshBreakdown(#getData(format))
end

local function generateExport(jsonEncode, path)
  local name=path or "skindata_"..os.date("%Y%m%d%H%M%S")..".json"
  local ts=format=="12" and string.gsub(os.date("%a, %b %d, %Y %I:%M:%S %p"), " 0(%d)", " %1") or os.date("%a, %b %d, %Y %H:%M:%S")
  local ref={pref="prefab", rari="rarity", skin="name", time="time"}
  local data=getData(format)
  local output={}
  local saveFolder=BRANCH=="release" and "DoNotStarveTogether" or "DoNotStarveTogetherBetaBranch"
  local savePath=path and name or "Klei//"..saveFolder.."/"..TheSim:GetSteamIDNumber().."/client_save/"..name

  output["generated"]={["time"]=ts, ["unix"]=os.time(), ["mod"]=mod, ["version"]=version, ["language"]=lang, ["path"]=savePath}
  output["data"]={["id"]=TheNet:GetUserID(), ["spools"]=TheInventory:GetCurrencyAmount(), ["kleipoints"]=TheInventory:GetKleiPointsAmount(), ["count"]={}, ["skins"]={}}

  for i=1, #rarityList do
    output["data"]["count"][rarityList[i]]=breakdown[rarityList[i]]
  end

  output["data"]["count"]["Total"]=#data

  for i,row in pairs(data) do
    output["data"]["skins"][tostring(i)]={}
    for k,v in pairs(row) do
      output["data"]["skins"][tostring(i)][ref[k]]=v
    end
  end

  if jsonEncode then
    output=json.encode_compliant(output)
  end

  return name, output
end

function DropsFullHistoryWidget:ExportData()
  local name, data="unsafedata/skindata_"..os.date("%Y%m%d%H%M%S")..".json", nil
  local io, error=io.open(name, "w")
  local result=false

  if io then
    name, data=generateExport(true, name)
    io:write(data)
    io:close()
    result=true
  else
    name, data=generateExport(true)
    local status=xpcall(function()
      SavePersistentString(name, data, false)
      result=true
    end, function(x)
      error=x
    end)
    return name, result, error
  end

  return string.gsub(name, "unsafedata/(.+%.json)", "%1"), result, error
end

return DropsFullHistoryWidget