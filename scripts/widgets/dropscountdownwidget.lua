--Drops Reset Countdown Steam Workshop Page: https://steamcommunity.com/sharedfiles/filedetails/?id=1688661034
--Website Version: https://dst-skins-checklist.firebaseapp.com/drops
--Created by Instant Noodles: https://steamcommunity.com/id/instant-noodles
--This mod may not be copied, altered, or reproduced in any way without the explicit and prior permission of the author

local DropsCounterWidget=require("widgets/dropscounterwidget")
local Image=require("widgets/image")
local Text=require("widgets/text")
local Widget=require("widgets/widget")
require("drops_func")

local boxW, boxH=370, 140
local curWeek=0
local family=TheSim:IsBorrowed()
local font=NUMBERFONT
local format="12"
local lang, modstr="EN", {}
local pendingGift=false

local ldt=os.date("*t", os.time())
local udt=os.date("!*t", os.time())
local shift=os.difftime(os.time(ldt), os.time(udt))
local shift_h, shift_m=math.modf(shift/60/60+(ldt.isdst and 1 or 0))
shift_m=shift_m*60
local tz=string.format(" (GMT%+05d)", shift_h*100+shift_m)

local reseth=(21+shift_h)
local resetm=(40+shift_m)
local dreseth=reseth%24
local dresetm=resetm%60
dreseth=((resetm>=60) and dreseth+1 or (resetm<0) and dreseth-1 or dreseth)

local dreset, wreset={}, {}

local function refreshldt()
  ldt=os.date("*t", os.time())
end

local function getdreset()
  refreshldt()

  if (ldt.hour>dreseth or (ldt.hour==dreseth and ldt.min>=dresetm)) then
    dreset={year=ldt.year, month=ldt.month, day=ldt.day+1, hour=dreseth, min=dresetm, sec=0}
  else
    dreset={year=ldt.year, month=ldt.month, day=ldt.day, hour=dreseth, min=dresetm, sec=0}
  end
end

local function getwreset()
  refreshldt()

  local weekday=4
  local current=os.date("%w")
  weekday=(reseth>=24 and weekday+1 or reseth<0 and weekday-1 or weekday)
  wreset={year=ldt.year, month=ldt.month, day=ldt.day+weekday-current, hour=dreseth, min=dresetm, sec=0}

  if (os.time()>os.time(wreset)) then
    wreset={year=ldt.year, month=ldt.month, day=ldt.day+weekday-current+7, hour=dreseth, min=dresetm, sec=0}     
  end
end

local function getCD(arr)
  local outStr=""
  local units={modstr.countdown.getCD.a[lang], modstr.countdown.getCD.b[lang], modstr.countdown.getCD.c[lang], modstr.countdown.getCD.d[lang]}

  for i=1, #arr do
    arr[i]=math.floor(arr[i])
  end

  for i=1, #arr do
    local tBool=true

    for j=1, i do
      tBool=tBool and arr[j]==0
    end

    if tBool and i==#arr then
      tBool=false
    end

    if not tBool then
      outStr=outStr.." "..arr[i]..units[i]
    end
  end

  return outStr
end

local function getDiff(period)
  local diff=0

  if (period=="daily") then
    getdreset()
    diff=os.difftime(os.time(dreset),os.time())
    return modstr.countdown.getDiff.a[lang]..getCD({0, (diff/60/60)%24, (diff/60)%60, diff%60})..modstr.countdown.getDiff.c[lang]
  elseif (period=="weekly") then
    getwreset()
    diff=os.difftime(os.time(wreset),os.time())
    return modstr.countdown.getDiff.b[lang]..getCD({(diff/60/60/24)%7, (diff/60/60)%24, (diff/60)%60, diff%60})..modstr.countdown.getDiff.c[lang]
  end
end

local function getNow(format)
  return ldateFormat(os.time(), modstr.units, lang, format, "full")..tz
end

local function getDaily()
  refreshldt()
  local day=ldateFormat(os.time(), modstr.units, lang, format, "md")
  local term=""

  if ((ldt.hour==dreseth and ldt.min==dresetm and ldt.sec==0) or (not pendingGift and IsDailyGiftItemPending())) then
    term=modstr.countdown.getDaily.a[lang]
  elseif (ldt.hour>dreseth or (ldt.hour==dreseth and ldt.min>=dresetm)) then
    if (TheFrontEnd:GetIsOfflineMode() or not TheNet:IsOnlineMode()) then
      term=modstr.countdown.getDaily.b[lang]
    else
      term=modstr.countdown.getDaily.c[lang]
    end
  else
    term=modstr.countdown.getDaily.d[lang]
  end

  return (not family) and (modstr.countdown.getDaily.e[lang]..day..term) or (modstr.countdown.getDaily.f[lang])
end

local function getWeekly()
  getwreset()
  local nreset=os.time(wreset)
  local next=ldateFormat(nreset, modstr.units, lang, format, "md")
  local lreset=os.time(wreset)-7*24*60*60
  local dstnow, dstnext, dstlast=ldt.isdst, os.date("*t", nreset).isdst, os.date("*t", lreset).isdst

  if (dstnow==dstlast and dstnow==dstnext) then
  elseif (dstnow and dstlast and not dstnext) then
    lreset=lreset-60*60
  elseif (not dstnow and not dstlast and dstnext) then
    lreset=lreset+60*60
  end

  local last=ldateFormat(lreset, modstr.units, lang, format, "md")

  return ((not family) and (modstr.countdown.getWeekly.a[lang]..last..modstr.countdown.getWeekly.c[lang]..next..modstr.countdown.getWeekly.d[lang]) or (modstr.countdown.getWeekly.b[lang]..last..modstr.countdown.getWeekly.c[lang]..next..modstr.countdown.getWeekly.d[lang])), lreset
end

local function getTime(period, format)
  getwreset()
  local tod=format=="12" and (dreseth>=12 and modstr.units.time[lang][2] or modstr.units.time[lang][1]) or ""
  local hour=format=="12" and (string.format("%d", dreseth>12 and dreseth-12 or dreseth==0 and 12 or dreseth)) or dreseth
  local day=ldateFormat(os.time(wreset), modstr.units, lang, format, "wd")

  if (lang=="RU" and format=="12") then
    tod=(dreseth>=5 and dreseth<12) and modstr.units.time[lang][1] or (dreseth>=12 and dreseth<17) and modstr.units.time[lang][2] or (dreseth>=17 and dreseth<24) and modstr.units.time[lang][3] or modstr.units.time[lang][4]
  end

  if (period=="daily") then
    if (lang=="ZH" or lang=="ZT") then
      return modstr.countdown.getTime.a[lang]..tod..hour..":"..string.format("%02d", dresetm)..":00"..modstr.countdown.getTime.d[lang]
    else
      return modstr.countdown.getTime.a[lang]..hour..":"..string.format("%02d", dresetm)..":00 "..tod..modstr.countdown.getTime.d[lang]
    end
  elseif (period=="weekly") then
    if (lang=="ZH" or lang=="ZT") then
      return modstr.countdown.getTime.b[lang]..day..modstr.countdown.getTime.c[lang]..tod..hour..":"..string.format("%02d", dresetm)..":00"..modstr.countdown.getTime.d[lang]
    else
      return modstr.countdown.getTime.b[lang]..day..modstr.countdown.getTime.c[lang]..hour..":"..string.format("%02d", dresetm)..":00 "..tod..modstr.countdown.getTime.d[lang]
    end
  end
end

local function shiftY(var, units)
  local vec=var:GetPosition()
  var:SetPosition(vec.x, vec.y+units)
end

local DropsCountdownWidget=Class(Widget, function(self, options)
  Widget._ctor(self, "DropsCountdownWidget")
  self.root=self:AddChild(Widget("root"))

  lang, modstr=options.language, options.strings
  format=options.clock

  self.box=self.root:AddChild(Image("images/ui.xml", "black.tex"))
  self.box:SetTint(1, 1, 1, 0.75)
  self.box:SetSize(boxW, boxH)
  self.box:SetPosition(-boxW*2/3, -boxH/2)

  local dailyFontSize=lang=="RU" and 17.5 or 18

  self.time=self.box:AddChild(Text(font, locScale(22, lang), getNow(format)))
  self.daily=self.box:AddChild(Text(font, locScale(dailyFontSize, lang), getDaily()))
  self.dailytime=self.box:AddChild(Text(font, locScale(16, lang), getTime("daily", format)))
  self.dtimer=self.box:AddChild(Text(font, locScale(16, lang), getDiff("daily")))
  self.weekly=self.box:AddChild(Text(font, locScale(18, lang), getWeekly(), {0, 255/255, 0, 1}))
  self.weeklytime=self.box:AddChild(Text(font, locScale(16, lang), getTime("weekly", format)))
  self.wtimer=self.box:AddChild(Text(font, locScale(16, lang), getDiff("weekly")))

  curWeek=select(2, getWeekly())
  pendingGift=IsDailyGiftItemPending()
  self.counter=self.root:AddChild(DropsCounterWidget(options, curWeek))

  self.time:SetPosition(0, boxH/2-16)
  self.daily:SetPosition(0, boxH/2-38)
  self.dailytime:SetPosition(0, boxH/2-56)
  self.dtimer:SetPosition(0, boxH/2-72)
  self.weekly:SetPosition(0, boxH/2-92)
  self.weeklytime:SetPosition(0, boxH/2-108)
  self.wtimer:SetPosition(0,boxH/2-124)

  if (not options.resettime) then
    self.dailytime:Hide()
    self.weeklytime:Hide()
    shiftY(self.time, -12)
    shiftY(self.daily, -12)
    shiftY(self.weekly, -6)
    shiftY(self.wtimer, 6)
  end

  if (family) then
    self.dailytime:Hide()
    self.dtimer:Hide()

    shiftY(self.time, -12)
    shiftY(self.daily, -14)
    shiftY(self.weekly, 12)

    if (options.resettime) then
      shiftY(self.weeklytime, 12)
      shiftY(self.wtimer, 12)
    else
      shiftY(self.wtimer, 12)

      if (lang=="RU") then
        shiftY(self.time, 8)
        shiftY(self.daily, 6)
      end
    end
  end

  if (not options.datetime) then
    self.time:Hide()
    self.title=self.box:AddChild(Text(font, locScale(22, lang), modstr.title[lang]))
    self.title:SetPosition(self.time:GetPosition().x, self.time:GetPosition().y)
  end

  self:StartUpdating()
  self.inst:ListenForEvent("giftreceiverupdate", function() self.counter:SetWeek(select(2, getWeekly())) self.counter:Drop() end, ThePlayer)
  self.task=self.inst:DoPeriodicTask(2, function()   
    local checkWeek=select(2, getWeekly())

    if (checkWeek~=curWeek) then
      self.counter:SetWeek(checkWeek)
      curWeek=checkWeek
    end
  end)
end)

function DropsCountdownWidget:CloseWeekly()
  self.counter:CloseWeekly()
end

function DropsCountdownWidget:OpenWeekly()
  self.counter:OpenWeekly()
end

function DropsCountdownWidget:GetWeeklyBtnOffset()
  return self.counter:GetWeeklyBtnOffset()
end

function DropsCountdownWidget:GetWeeklyCloseOffset()
  return self.counter:GetWeeklyCloseOffset()
end

function DropsCountdownWidget:RefreshWeekly()
  self.counter:RefreshWeekly()
end

function DropsCountdownWidget:Close()
  self.box:Hide()
  self.counter:Close()
end

function DropsCountdownWidget:Open()
  self.box:Show()
  self.counter:Open()
end

function DropsCountdownWidget:GetFTUE()
  return self.counter:GetFTUE()
end

function DropsCountdownWidget:DisableFTUE()
  self.counter:DisableFTUE()
end

function DropsCountdownWidget:OnUpdate(dt)
  self.dt=self.dt and self.dt-dt or 0.2

  if (self.dt<0) then
    self.time:SetString(getNow(format))
    self.dtimer:SetString(getDiff("daily"))
    self.wtimer:SetString(getDiff("weekly"))
    self.weekly:SetString(getWeekly())

    if ((string.find(self.daily:GetString(), modstr.countdown.onUpdate.a[lang])==nil) or (pendingGift and not IsDailyGiftItemPending())) then
      self.daily:SetString(getDaily())
    end

    if (string.find(self.daily:GetString(), modstr.countdown.onUpdate.a[lang])~=nil or string.find(self.daily:GetString(), modstr.countdown.onUpdate.b[lang])~=nil) then
      self.daily:SetColour(0, 255/255, 0, 1)
    elseif (string.find(getDaily(), modstr.countdown.onUpdate.c[lang])~=nil or string.find(self.daily:GetString(), modstr.countdown.onUpdate.d[lang])~=nil) then
      self.daily:SetColour(255/255, 0, 0, 1)
    else
      self.daily:SetColour(255/255, 255/255, 0, 1)
    end

    self.dt=0.2
  end
end

return DropsCountdownWidget