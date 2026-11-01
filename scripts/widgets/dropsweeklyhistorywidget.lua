--Drops Reset Countdown Steam Workshop Page: https://steamcommunity.com/sharedfiles/filedetails/?id=1688661034
--Website Version: https://dst-skins-checklist.firebaseapp.com/drops
--Created by Instant Noodles: https://steamcommunity.com/id/instant-noodles
--This mod may not be copied, altered, or reproduced in any way without the explicit and prior permission of the author

local Image=require("widgets/image")
local ImageButton=require("widgets/imagebutton")
local Spinner=require("widgets/spinner")
local Templates=require("widgets/redux/templates")
local Text=require("widgets/text")
local UIAnim=require("widgets/uianim")
local Widget=require("widgets/widget")
require("drops_func")

local boxW, boxH=400, 250
local directory, mod, version="", "", ""
local font=NUMBERFONT
local format="12"
local lang, modstr="EN", {}
local week, items, lookup, lastitem=0, {}, {}, 0

local function getLookup()
  local skinslist=TheInventory:GetFullInventory()
  local data={}

  for i=1, #skinslist do
    data[skinslist[i].item_id]=skinslist[i].modified_time
  end

  return data
end

local function getData(itemlist)
  local data={}

  for k, v in pairs(itemlist) do
    if (v=="nil") then
      break
    end

    local ttbl={}
    ttbl["pref"]=v
    ttbl["rari"]=GetRarityForItem(v)
    ttbl["skin"]=STRINGS.SKIN_NAMES[v]
    ttbl["symb"]=GetFrameSymbolForRarity(ttbl.rari)
    ttbl["itid"]=k

    if lookup[k]~=nil and lookup[k]>=0 then
      ttbl["time"]=ldateFormat(lookup[k], modstr.units, lang, format, "full")
      ttbl["unix"]=lookup[k]
    else
      ttbl["time"]=nil
      ttbl["unix"]=0
    end

    table.insert(data, ttbl)
  end

  local function sort(a, b)
    if (a.time==nil or b.time==nil) then
      if (a.time==nil and b.time~=nil) then
        return false
      elseif (a.time~=nil and b.time==nil) then
        return true
      else
        if (a.itid==lastitem and b.itid~=lastitem) then
          return false
        elseif (a.itid~=lastitem and b.itid==lastitem) then
          return true
        elseif (a.rari~=b.rari) then
          return RARITY_ORDER[a.rari]>RARITY_ORDER[b.rari]
        else
          return a.skin<b.skin
        end
      end
    else
      return a.unix<b.unix
    end
  end

  table.sort(data, sort)

  return data
end

local function getCycleDates()
  local dates={}
  local data={}

  for k, v in pairs(items) do
    if week==k or not items[k]["items"]["empty"] then
      table.insert(dates, k)
    end
  end

  table.sort(dates)

  for k, v in pairs(dates) do
    local next=ldateFormat(v+7*24*60*60-1, modstr.units, lang, format, "wdmdy")
    local last=ldateFormat(v, modstr.units, lang, format, "wdmdy")
    local ttbl={}

    ttbl["text"]=last.." "..modstr.weeklyhistory.to[lang].." "..next
    ttbl["data"]=v
    table.insert(data, ttbl)
  end

  return data  
end

local function HistoryConstruct(ctx, idx)
  local cell=Widget("cell")
  cell.root=cell:AddChild(Widget("root"))
  cell.image=cell.root:AddChild(UIAnim())
  cell.image:GetAnimState():SetBuild("frames_comp")
  cell.image:GetAnimState():SetBank("frames_comp")
  cell.image:GetAnimState():Hide("NEW")
  cell.image:GetAnimState():PlayAnimation("idle_on", true)
  cell.image:SetScale(0.5)

  return cell
end

local function HistoryUpdate(ctx, cell, data, idx)
  if (data) then
    local hovertext=""
    cell.image:GetAnimState():Hide("NEW")

    if data.time~=nil then
      hovertext=data.skin.."\n"..data.time
      cell.image:GetAnimState():SetMultColour(1, 1, 1, 1)
    else
      if data.itid==lastitem then
        hovertext=data.skin.."\n"..modstr.weeklyhistory.unopened[lang]
        cell.image:GetAnimState():Show("NEW")
        cell.image:GetAnimState():SetMultColour(0.25, 0.25, 0.25, 1)
      else
        hovertext=data.skin.."\n"..modstr.weeklyhistory.missing[lang]
        cell.image:GetAnimState():SetMultColour(0.5, 0.5, 0.5, 1)
      end
    end

    cell.image:GetAnimState():OverrideSkinSymbol("SWAP_ICON", GetBuildForItem(data.pref), "SWAP_ICON")
    cell.image:GetAnimState():OverrideSymbol("SWAP_frameBG", "frame_BG", data.symb)
    cell.image:SetHoverText(hovertext, {bg=true, font=font, font_size=locScale(16, lang)})
  else
    cell.image:GetAnimState():ClearOverrideSymbol("SWAP_frameBG")
    cell.image:GetAnimState():ClearOverrideSymbol("SWAP_ICON")
    cell.image:ClearHoverText()
  end
end

local DropsWeeklyHistoryWidget=Class(Widget, function(self, options, cweek, cdata)
  Widget._ctor(self, "DropsWeeklyHistoryWidget")
  self.root=self:AddChild(Widget("root"))

  lang, modstr=options.language, options.strings
  directory, format, mod, version=options.directory, options.clock, options.modname, options.modversion
  week, items, lookup=tostring(cweek), cdata, getLookup()

  self.box=self.root:AddChild(Image("images/ui.xml", "black.tex"))
  self.box:SetTint(1, 1, 1, 0.75)
  self.box:SetSize(boxW, boxH)

  self.title=self.box:AddChild(Text(font, locScale(25, lang), modstr.weeklyhistory.title[lang]))
  self.title:SetPosition(0, boxH/2-25)

  self.week=self.box:AddChild(Spinner(getCycleDates(), boxW-50, 25, {font=font, size=locScale(16, lang)}, nil, "images/global_redux.xml", {arrow_left_normal="arrow2_left.tex",	arrow_left_over="arrow2_left_over.tex", arrow_left_disabled="arrow_left_disabled.tex", arrow_left_down="arrow2_left_down.tex", arrow_right_normal="arrow2_right.tex", arrow_right_over="arrow2_right_over.tex", arrow_right_disabled="arrow_right_disabled.tex", arrow_right_down="arrow2_right_down.tex", bg_middle="blank.tex", bg_middle_focus="blank.tex", bg_middle_changing="blank.tex", bg_end="blank.tex", bg_end_focus="blank.tex", bg_end_changing="blank.tex", bg_modified="option_highlight.tex"}, true))
  self.week:SetPosition(0, boxH/2-55)
  self.week:SetSelectedIndex(self.week:MaxIndex())
  
  self.info=self.box:AddChild(ImageButton("images/global_redux.xml", "button_carny_square_normal.tex", "button_carny_square_hover.tex", "button_carny_square_disabled.tex", "button_carny_square_hover.tex", nil, {0.2, 0.2}, {0, 0}))
  self.info:SetHoverText(modstr.weeklyhistory.caveat[lang], {bg=true, font=font, font_size=16, wordwrap=true, offset_y=30})
  self.info.move_on_click=false  
  self.info:SetPosition(boxW/2-50, boxH/2-25)
  self.mark=self.info:AddChild(Image("images/ui.xml", "new_label_motd.tex")) 
  self.mark:ScaleToSize(15, 15)

  self.index=self.box:AddChild(Text(font, locScale(16, lang), " / "))
  self.index:SetPosition(-boxW/2+25+13+70/2, -boxH/2+15)

  self.jstart=self.box:AddChild(ImageButton("images/global_redux.xml", "button_carny_square_normal.tex", "button_carny_square_hover.tex", "button_carny_square_disabled.tex", "button_carny_square_hover.tex", nil, {0.2, 0.2}, {0, 0}))
  self.jstartarr=self.jstart:AddChild(Image("images/global_redux.xml", "arrow2_left_down.tex"))
  self.jstartarr:SetDisabledTexture("images/global_redux.xml", "arrow_left_disabled.tex")
  self.jstartarr:ScaleToSize(10, 15)
  self.jstartarr2=self.jstart:AddChild(Image("images/global_redux.xml", "arrow2_left_down.tex"))
  self.jstartarr2:SetDisabledTexture("images/global_redux.xml", "arrow_left_disabled.tex")
  self.jstartarr2:ScaleToSize(10, 15)
  self.jstartline=self.jstart:AddChild(Image("images/global_redux.xml", "black.tex"))
  self.jstartline:ScaleToSize(2, 12)
  self.jstartline:SetTint(1, 1, 1, 0.5)
  self.jstartarr:SetPosition(0, 0)
  self.jstartarr2:SetPosition(5, 0)
  self.jstartline:SetPosition(-5, 0)
  self.jstart:SetPosition(-boxW/2+25, -boxH/2+15)

  self.jend=self.box:AddChild(ImageButton("images/global_redux.xml", "button_carny_square_normal.tex", "button_carny_square_hover.tex", "button_carny_square_disabled.tex", "button_carny_square_hover.tex", nil, {0.2, 0.2}, {0, 0}))
  self.jendarr=self.jend:AddChild(Image("images/global_redux.xml", "arrow2_right_down.tex"))
  self.jendarr:SetDisabledTexture("images/global_redux.xml", "arrow_right_disabled.tex")
  self.jendarr:ScaleToSize(10, 15)
  self.jendarr2=self.jend:AddChild(Image("images/global_redux.xml", "arrow2_right_down.tex"))
  self.jendarr2:SetDisabledTexture("images/global_redux.xml", "arrow_right_disabled.tex")
  self.jendarr2:ScaleToSize(10, 15)
  self.jendline=self.jend:AddChild(Image("images/global_redux.xml", "black.tex"))
  self.jendline:ScaleToSize(2, 12)
  self.jendline:SetTint(1, 1, 1, 0.5)
  self.jendarr:SetPosition(-4, 0)
  self.jendarr2:SetPosition(1, 0)
  self.jendline:SetPosition(5, 0)
  self.jend:SetPosition(-boxW/2+25+26/2+70+26/2, -boxH/2+15)

  self:UpdateIndex()
  self.jstart:SetOnClick(function() self.week:SetSelectedIndex(1) self:UpdateItems() end)
  self.jend:SetOnClick(function() self.week:SetSelectedIndex(self.week:MaxIndex()) self:UpdateItems() end)

  local unopened=TheInventory:GetUnopenedItems()
  if (#unopened>0) then lastitem=unopened[1].item_id end

  if (not TheFrontEnd:GetIsOfflineMode() and TheNet:IsOnlineMode()) then
    self.list=self.box:AddChild(Templates.ScrollingGrid(getData(items[tostring(week)]["items"]), {apply_fn=HistoryUpdate, item_ctor_fn=HistoryConstruct, widget_width=boxW/5, widget_height=75, num_visible_rows=2, num_columns=4, scrollbar_offset=15, scrollbar_height_offset=-50, scroll_per_click=1, peek_height=10, end_offset=1}))
    self.list:SetPosition(0, -20)
  else
    self.week:Hide()
  end

  local function updateItems(date)
    if (self.list) then
      self.list:SetItemsData(getData(items[tostring(date)]["items"]))
      self:UpdateIndex()
    end
  end

  self.week:SetOnChangedFn(updateItems)

  if (options.autoopen==false) then
    self.refreshtask=self.inst:DoPeriodicTask(6, function() if (lastitem~=0) then if (lookup[lastitem]==nil) then lookup=getLookup() else self:UpdateItems() lastitem=0 end end end)
  end
end)

function DropsWeeklyHistoryWidget:GetBoxW()
  return boxW
end

function DropsWeeklyHistoryWidget:GetBoxH()
  return boxH
end

function DropsWeeklyHistoryWidget:UpdateIndex()
  local curIdx=self.week:GetSelectedIndex()
  local maxIdx=self.week:MaxIndex()

  self.index:SetString(curIdx.." / "..maxIdx)

  self.jstart:Enable()
  self.jstartarr:Enable()
  self.jstartarr2:Enable()
  self.jstartline:SetTint(1, 1, 1, 0.5)
  self.jend:Enable()
  self.jendarr:Enable()
  self.jendarr2:Enable()
  self.jendline:SetTint(1, 1, 1, 0.5)

  if (curIdx==1) then
    self.jstartarr:Disable()
    self.jstartarr2:Disable()
    self.jstart:Disable()
    self.jstartline:SetTint(1, 1, 1, 0.2)
  end

  if (curIdx==maxIdx) then
    self.jendarr:Disable()
    self.jendarr2:Disable()
    self.jend:Disable()
    self.jendline:SetTint(1, 1, 1, 0.2)
  end
end

function DropsWeeklyHistoryWidget:UpdateItems()
  if (self.list) then
    self.list:SetItemsData(getData(items[tostring(self.week:GetSelectedData())]["items"]))
    self:UpdateIndex()
  end
end

function DropsWeeklyHistoryWidget:RefreshData(cweek, cdata)
  if (self.list) then
    items, lookup=cdata, getLookup()

    if (week~=tostring(cweek)) then
      week=tostring(cweek)
      self.week:SetOptions(getCycleDates())
      self.week:SetSelectedIndex(self.week:MaxIndex())
    end

    self:UpdateItems()
  end
end

function DropsWeeklyHistoryWidget:SetLastItem(id)
  lastitem=id
end

return DropsWeeklyHistoryWidget