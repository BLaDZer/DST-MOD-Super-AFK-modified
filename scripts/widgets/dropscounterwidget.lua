--Drops Reset Countdown Steam Workshop Page: https://steamcommunity.com/sharedfiles/filedetails/?id=1688661034
--Website Version: https://dst-skins-checklist.firebaseapp.com/drops
--Created by Instant Noodles: https://steamcommunity.com/id/instant-noodles
--This mod may not be copied, altered, or reproduced in any way without the explicit and prior permission of the author

local DropsWeeklyHistoryWidget=require("widgets/dropsweeklyhistorywidget")
local Image=require("widgets/image")
local ImageButton=require("widgets/imagebutton")
local Text=require("widgets/text")
local TextButton=require("widgets/textbutton")
local Widget=require("widgets/widget")
require("drops_func")

local boxW, boxH=370, 30
local data, name, week, kuid={}, "dropsdata", 0, ""
local font=NUMBERFONT
local autoopen, lasttryopen, lang, modstr=false, 0, "EN", {}
local ftue=false
local offset={EN=0, EU=0, RU=-40, ZH=30, ZT=30, PT=0, KO=0}
local toffset={EN=0, EU=0, RU=2, ZH=-2, ZT=-2, PT=0, KO=0}
local moffset={EN=0, EU=0, RU=0, ZH=-2, ZT=-2, PT=0, KO=0}

local function checkWeek()
  if not data[tostring(week)] or not data[tostring(week)]["count"] then
    local nweek={count=0, items={empty="nil"}}
    data[tostring(week)]=nweek
  end
end

local function removeEmpty()
  if data[tostring(week)]["items"]["empty"] then
    data[tostring(week)]["items"]["empty"]=nil
  end
end

local DropsCounterWidget=Class(Widget, function(self, options, unix)
  Widget._ctor(self, "DropsCounterWidget")
  self.root=self:AddChild(Widget("root"))
  self.root:SetPosition(0, -139)

  autoopen, lang, modstr, week=options.autoopen, options.language, options.strings, unix
  kuid=TheNet:GetUserID()

  self.box=self.root:AddChild(Image("images/ui.xml", "black.tex"))
  self.box:SetTint(1, 1, 1, 0.75)
  self.box:SetSize(boxW, boxH)
  self.box:SetPosition(-boxW*2/3, -boxH/2)
  self.text=self.box:AddChild(Text(font, locScale(16, lang), modstr.counter.text[lang]))
  self.caveat=self.box:AddChild(TextButton())
  self.caveat:SetText(modstr.counter.caveat[lang])
  self.caveat:SetFont(font)
  self.caveat:SetTextSize(locScale(14, lang))
  self.caveat.image:ScaleToSize(self.caveat.text:GetRegionSize())
  self.count=self.box:AddChild(Text(font, locScale(18, lang), "0"))
  self.text:SetPosition(-boxW/3+self.text:GetRegionSize()*0.5+offset[lang], 6)
  self.caveat:SetPosition(-boxW/3+self.text:GetRegionSize()*0.5-offset[lang]/4+offset[lang], -6)
  self.count:SetPosition(boxW/4-offset[lang], 0)

  if (TheFrontEnd:GetIsOfflineMode() or not TheNet:IsOnlineMode()) then
    self.text:Hide()
    self.caveat:Hide()
    self.count:Hide()
    self.error=self.box:AddChild(Text(font, locScale(15, lang), modstr.counter.error[lang]))
  end

  self.noticebox=self.root:AddChild(Image("images/ui.xml", "black.tex"))
  self.noticebox:SetVAnchor(ANCHOR_MIDDLE)
  self.noticebox:SetHAnchor(ANCHOR_MIDDLE)
  self.noticebox:SetScaleMode(SCALEMODE_PROPORTIONAL)
  self.noticebox:SetTint(1, 1, 1, 0.75)
  self.noticebox:SetSize(boxW*0.9, 160)
  self.notice=self.noticebox:AddChild(Text(font, locScale(16, lang), modstr.counter.notice[lang]))
  self.notice:SetPosition(0, -10)
  self.notice:SetRegionSize(boxW*0.75, 120)
  self.notice:EnableWordWrap(true)
  self.noticetitle=self.noticebox:AddChild(Text(font, locScale(22, lang), modstr.counter.noticetitle[lang]))
  self.noticetitle:SetPosition(0, 60)
  self.noticebox:Hide()

  self.noticeclose=self.noticebox:AddChild(ImageButton("images/global_redux.xml", "button_carny_square_normal.tex", "button_carny_square_hover.tex", "button_carny_square_disabled.tex", "button_carny_square_down.tex", nil, {0.2, 0.2}, {0, 0}))
  self.noticeclose:SetPosition(boxW*0.9*0.5-20, 160*0.5-20)
  self.noticex=self.noticeclose:AddChild(Image("images/global_redux.xml", "close.tex"))
  self.noticex:ScaleToSize(15, 15)

  self.lerrorbox=self.root:AddChild(Image("images/ui.xml", "black.tex"))
  self.lerrorbox:SetVAnchor(ANCHOR_MIDDLE)
  self.lerrorbox:SetHAnchor(ANCHOR_MIDDLE)
  self.lerrorbox:SetScaleMode(SCALEMODE_PROPORTIONAL)
  self.lerrorbox:SetTint(1, 1, 1, 0.75)
  self.lerrorbox:SetSize(boxW, 160)
  self.lerror=self.lerrorbox:AddChild(Text(font, locScale(16-moffset[lang], lang), modstr.counter.loaderror[lang]))
  self.lerror:SetPosition(0, -10)
  self.lerror:SetRegionSize(boxW*0.9, 120)
  self.lerror:EnableWordWrap(true)
  self.lerrortitle=self.lerrorbox:AddChild(Text(font, locScale(22-toffset[lang], lang), modstr.counter.loaderrortitle[lang]))
  self.lerrortitle:SetPosition(0, 60)
  self.lerrorbox:Hide()

  self.lerrorclose=self.lerrorbox:AddChild(ImageButton("images/global_redux.xml", "button_carny_square_normal.tex", "button_carny_square_hover.tex", "button_carny_square_disabled.tex", "button_carny_square_down.tex", nil, {0.2, 0.2}, {0, 0}))
  self.lerrorclose:SetPosition(boxW*0.5-20, 160*0.5-20)
  self.lerrorx=self.lerrorclose:AddChild(Image("images/global_redux.xml", "close.tex"))
  self.lerrorx:ScaleToSize(15, 15)

  self.caveat:SetOnClick(function() self.noticebox:Show() self.lerrorbox:Hide() self.list:Hide() end)
  self.noticeclose:SetOnClick(function() self.noticebox:Hide() if ftue then ftue=false end end)
  self.lerrorclose:SetOnClick(function() self.lerrorbox:Hide() end)

  local l_one, l_oneerr=self:Load()

  if not l_one then
    print("[Drops Reset Countdown] Existing save not detected/loaded - "..l_oneerr)
    data={[tostring(week)]={count=0, items={empty="nil"}}}
    local s_one, s_oneerr=self:Save()

    if (not s_one) then
      print("[Drops Reset Countdown] Could not create a new save file - "..s_oneerr)
    else
      print("[Drops Reset Countdown] New save file generated")

      if (l_oneerr=="Old file corrupted" or l_oneerr=="Old file had invalid syntax" or l_oneerr=="Unknown") then
        self.lerrorbox:Show()
      else
        self.noticebox:Show()
        ftue=true
      end
    end
  else
    print("[Drops Reset Countdown] Save file loaded successfully")
  end

  checkWeek()
  self:Save()

  self.count:SetString(tostring(data[tostring(week)]["count"])..modstr.counter.count[lang])

  self.list=self.root:AddChild(DropsWeeklyHistoryWidget(options, week, data))
  self.list:SetVAnchor(ANCHOR_MIDDLE)
  self.list:SetHAnchor(ANCHOR_MIDDLE)
  self.list:SetScaleMode(SCALEMODE_PROPORTIONAL)
  self.list:Hide()
end)

function DropsCounterWidget:Drop()
  checkWeek()
  local skin=TheInventory:GetUnopenedItems()
  local now=os.time()

  if (#skin>0 and not data[tostring(week)]["items"][tostring(skin[1].item_id)]) then
    data[tostring(week)]["items"][tostring(skin[1].item_id)]=skin[1].item_type
    data[tostring(week)]["count"]=data[tostring(week)]["count"]+1

    local s_drop, s_err=self:Save()

    if (not s_drop) then
      print("[Drops Reset Countdown] Weekly Skin Drop Detected - Could not update save file: "..s_err)
    else
      removeEmpty()
      self:Save()
      self.count:SetString(tostring(data[tostring(week)]["count"])..modstr.counter.count[lang])
      self.list:SetLastItem(skin[1].item_id)
      self.list:RefreshData(week, data)
      print("[Drops Reset Countdown] Weekly Skin Drop Detected - Save file updated to "..tostring(data[tostring(week)]["count"]).." drop(s)")
    end
  end

  if (#skin>0 and autoopen=="text" and lasttryopen~=now) then
    lasttryopen=now

    self.opentask=self.inst:DoTaskInTime(1, function()
      TheInventory:SetItemOpened(skin[1].item_id)

      if pcall(function() return type(ChatHistory) end) then
        ChatHistory:OnSkinAnnouncement(ThePlayer.name, ThePlayer.playercolour, skin[1].item_type)
      else
        ThePlayer.HUD.eventannouncer:ShowSkinAnnouncement(ThePlayer.name, ThePlayer.playercolour, skin[1].item_type)
      end

      print("[Drops Reset Countdown] Auto-Opening Gift Box - Received "..skin[1].item_type.." ("..STRINGS.SKIN_NAMES[skin[1].item_type]..")")
    end)

    self.refreshtask=self.inst:DoTaskInTime(2, function()
      self.list:RefreshData(week, data)
      self.list:SetLastItem(0)
    end)
  end
end

function DropsCounterWidget:CloseWeekly()
  self.list:Hide()
end

function DropsCounterWidget:OpenWeekly()
  self.noticebox:Hide()
  self.list:RefreshData(week, data)
  self.list:Show()
  if ftue then ftue=false end
end

function DropsCounterWidget:GetWeeklyBtnOffset()
   return self.root:GetPosition()+self.box:GetPosition()+self.count:GetPosition()
end

function DropsCounterWidget:GetWeeklyCloseOffset()
   return self.list:GetPosition()+Vector3(self.list:GetBoxW()/2-25, self.list:GetBoxH()/2-25, 0)
end

function DropsCounterWidget:Close()
  self.box:Hide()
  if not ftue then self.noticebox:Hide() end
end

function DropsCounterWidget:Open()
  self.box:Show()
end

function DropsCounterWidget:GetFTUE()
  return ftue
end

function DropsCounterWidget:DisableFTUE()
  ftue=false
end

function DropsCounterWidget:RefreshWeekly()
  self.list:RefreshData(week, data)
end

function DropsCounterWidget:Load()
  local io, error=io.open(name.."_"..kuid..".json", "r")
  local read=nil
  local result=false
  local err=""

  TheSim:GetPersistentString(name.."_"..kuid, function(loaded, str)
    if loaded then
      read=str
    elseif io then
      read=io:read("*all")
      io:close()
      print("[Drops Reset Countdown] Failed to GetPersistentString - Fellback to io:read successfully")
    else
      error=name.."_"..kuid..": No such file or directory"
    end
  end)

  if read then
    local status=xpcall(function()
      data=json.decode(read)
      result=true
    end, function(x)
      if string.match(x, "Unterminated JSON encoded object") then
        error="Old file corrupted"
      elseif string.match(x, "scan constant") or string.match(x, "unterminated string") or string.match(x, "ended unexpectedly") then
        error="Old file had invalid syntax"
      else
        error="Unknown"
      end

      print("[Drops Reset Countdown] Corrupted Save File Detected - Backing Up & Deleting")
      err=x
    end)

    if not status then
      self:Backup(read, err)
    end
  end

  return result, error
end

function DropsCounterWidget:Backup(copy, err)
  local io, error=io.open("unsafedata/"..name.."_"..kuid.."-"..os.time()..".backup", "w")
  local result=false

  if io then
    if err then
      io:write("<<ERROR:"..err..">>\n\n")
    end
    io:write(copy)
    io:close()
    result=true
  end

  local status=xpcall(function()
    SavePersistentString(name.."_"..kuid.."-"..os.time()..".backup", json.encode({["_ERROR"]=err, ["_JSON"]=copy}), false)
    result=true
  end, function(x)
    error=x
  end)

  return result, error
end

function DropsCounterWidget:Save()
  local io, error=io.open("unsafedata/"..name.."_"..kuid..".json", "w")
  local result=false

  if io then
    io:write(json.encode(data))
    io:close()
    result=true
  end

  local status=xpcall(function()
    SavePersistentString(name.."_"..kuid, json.encode(data), false)
    result=true
  end, function(x)
    error=x
  end)

  if not status then
    print("[Drops Reset Countdown] Failed to SavePersistentString")
    result=false
  end

  return result, error
end

function DropsCounterWidget:SetWeek(unix)
  if (week~=unix) then
    week=unix
    checkWeek()
    self:Save()
    self.count:SetString(tostring(data[tostring(week)]["count"])..modstr.counter.count[lang])
    self.list:RefreshData(week, data)
    print("[Drops Reset Countdown] Resetting Weekly Drops Count")
  end  
end

return DropsCounterWidget