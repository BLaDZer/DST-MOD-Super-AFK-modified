--Drops Reset Countdown Steam Workshop Page: https://steamcommunity.com/sharedfiles/filedetails/?id=1688661034
--Website Version: https://dst-skins-checklist.firebaseapp.com/drops
--Created by Instant Noodles: https://steamcommunity.com/id/instant-noodles
--This mod may not be copied, altered, or reproduced in any way without the explicit and prior permission of the author

local DropsCountdownWidget=require("widgets/dropscountdownwidget")
local DropsFullHistoryWidget=require("widgets/dropsfullhistorywidget")
local DropsHistoryWidget=require("widgets/dropshistorywidget")
local Image=require("widgets/image")
local ImageButton=require("widgets/imagebutton")
local Text=require("widgets/text")
local Widget=require("widgets/widget")
require("drops_func")

local boxW, boxH=370, 20
local font=NUMBERFONT
local lookup={[3]=72, [5]=100, [7]=128, [9]=156, [12]=200}
local lang, modstr="EN", {}
local offset={EN=-45, EU=-45, RU=-105, ZH=15, ZT=15, PT=-45, KO=15}
local toggle=true

local DropsModalWidget=Class(Widget, function(self, options)
  Widget._ctor(self, "DropsModalWidget")
  self.root=self:AddChild(Widget("root"))

  lang, modstr=options.language, options.strings

  self.countdown=self.root:AddChild(DropsCountdownWidget(options))

  if (options.list) then
    self.history=self.root:AddChild(DropsHistoryWidget(options))
  end

  self.more=self.root:AddChild(ImageButton("images/global_redux.xml", "button_carny_long_normal.tex", "button_carny_long_hover.tex", "button_carny_long_disabled.tex", "button_carny_long_down.tex", nil, {0.2, 0.2}, {0, 0}))
  self.more:ForceImageSize(75, 20)
  self.more:SetPosition(-boxW*2/3, -boxH/2-139-lookup[options.size]+12/2-29)
  self.moretxt=self.more:AddChild(Text(font, locScale(13, lang), modstr.modal.moretxt[lang]))
  self.moretxt:SetPosition(0, 0)

  if (not options.list) then
    self.more:Hide()
  end

  local function collapse()
    self.countdown:Close()
    self.box:SetTexture("images/ui.xml", "black.tex")
    self.box:SetSize(boxW, boxH)
    self.box:SetTint(1, 1, 1, 0.75)
    self.togglearr:SetTexture("images/global_redux.xml", "arrow2_right_down.tex")
    self.toggletxt:SetString(modstr.title[lang])

    if (self.history and self.more) then
      self.history:Hide()
      self.more:Hide()
    end

    if (self.weeklybtn and self.weeklyclose) then
      self.weeklybtn:Hide()
      self.weeklyclose:Hide()
    end

    toggle=false
  end

  local function expand()
    self.countdown:Open()
    self.box:SetTexture("images/ui.xml", "blank.tex")
    self.togglearr:SetTexture("images/global_redux.xml", "arrow2_left_down.tex")
    self.toggletxt:SetString("")

    if (self.history and self.more) then
      self.history:Show()
      self.more:Show()
      self.list:Hide()
      TheCamera:SetControllable(true)
    end
	
    if (self.weeklybtn and self.weeklyclose) then
      if (TheFrontEnd:GetIsOfflineMode() or not TheNet:IsOnlineMode()) then
        self.weeklybtn:Hide()
      else
        self.weeklybtn:Show()
      end

      self.weeklyclose:Hide()
      self.countdown:CloseWeekly()
    end

    toggle=true
  end

  self.list=self.root:AddChild(DropsFullHistoryWidget(options))
  self.list:SetVAnchor(ANCHOR_MIDDLE)
  self.list:SetHAnchor(ANCHOR_MIDDLE)
  self.list:SetScaleMode(SCALEMODE_PROPORTIONAL)
  self.close=self.list:AddChild(ImageButton("images/global_redux.xml", "button_carny_square_normal.tex", "button_carny_square_hover.tex", "button_carny_square_disabled.tex", "button_carny_square_down.tex", nil, {0.2, 0.2}, {0, 0}))
  self.close:SetPosition(600/2-25, 400/2-25)
  self.close:SetOnClick(function() self.list:Hide() TheCamera:SetControllable(true) end)
  self.closex=self.close:AddChild(Image("images/global_redux.xml", "close.tex"))
  self.closex:ScaleToSize(15, 15)
  self.list:Hide()

  self.more:SetOnClick(function() if self.countdown:GetFTUE() then self.countdown:DisableFTUE() end self.list:Show() self.list:RefreshData() collapse() TheCamera:SetControllable(false) end)

  if (not TheFrontEnd:GetIsOfflineMode() or TheNet:IsOnlineMode()) then
    self.exportbox=self.list:AddChild(Image("images/ui.xml", "black.tex"))
    self.exportbox:SetTint(1, 1, 1, 0.75)
    self.exportbox:SetSize(600,40)
    self.exportbox:SetPosition(0, -400/2-select(2, self.exportbox:GetSize())*0.5+1)
    self.export=self.exportbox:AddChild(ImageButton("images/global_redux.xml", "button_carny_long_normal.tex", "button_carny_long_hover.tex", "button_carny_long_disabled.tex", "button_carny_long_down.tex", nil, {0.2, 0.3}, {0, 0}))
    self.export:SetPosition(-self.exportbox:GetSize()/2+self.export:GetSize()*0.2-20, 0)
    self.exporttxt=self.export:AddChild(Text(font, locScale(16, lang), modstr.modal.exporttxt[lang]))
    self.exporttxt:SetClickable(false)

    local saveFolder=BRANCH=="release" and "DoNotStarveTogether" or "DoNotStarveTogetherBetaBranch"
    local exportroot="Klei//"..saveFolder.."/"..TheSim:GetSteamIDNumber().."/client_save/"
--    local exportroot=string.find(options.directory, "workshop")~=nil and "steamapps/workshop/content/322330/1688661034/export/" or (string.gsub(options.directory, "%.%.", "")).."export/"

    self.exportresult=self.exportbox:AddChild(Text(font, locScale(16, lang), modstr.modal.exportresult.a[lang]..exportroot.. modstr.modal.exportresult.b[lang]))
    self.exportresult:SetPosition(-self.exportbox:GetSize()/3+self.exportresult:GetRegionSize()*0.5-15, 0)
    self.exportresult:SetHAlign(1)

    local function export()
      local file, status, error=self.list:ExportData()
      local posX, posY=self.exportresult:GetPosition()
      local str=self.exportresult:GetString()
      local delay=60
      self.export:Disable()

      if (status) then
        self.exportresult:SetString(modstr.modal.exportresult.c[lang]..file..modstr.modal.exportresult.d[lang])
      else
        self.exportresult:SetString(modstr.modal.exportresult.e[lang])
        print("[Drops Reset Countdown] Export Failed - "..error)
        delay=15
      end

      self.task=self.inst:DoTaskInTime(delay, function() self.export:Enable() self.exportresult:SetString(str) self.exportresult:SetPosition(posX, posY) end)

      self.exportresult:SetPosition(-self.exportbox:GetSize()/3+self.exportresult:GetRegionSize()*0.5-15, 0)
    end

    self.export:SetOnClick(function() export() end)
  end

  self.box=self.root:AddChild(Image("images/ui.xml", "blank.tex"))
  self.box:SetPosition(-boxW*2/3, -boxH/2)
  self.togglebtn=self.box:AddChild(ImageButton("images/global_redux.xml", "button_carny_square_normal.tex", "button_carny_square_hover.tex", "button_carny_square_disabled.tex", "button_carny_square_down.tex", nil, {0.15, 0.15}, {0, 0}))
  self.togglebtn:SetPosition(boxW/2-99*0.3/2, 0)
  self.togglearr=self.togglebtn:AddChild(Image("images/global_redux.xml", "arrow2_left_down.tex"))
  self.togglearr:ScaleToSize(15, 15)
  self.togglearr:RotateTo(0, 90, 0.1, nil, false)
  self.toggletxt=self.box:AddChild(Text(font, locScale(16, lang), ""))
  self.togglebtn:SetOnClick(function()
    if (toggle) then
      collapse()
    else
      expand()
    end
  end)
  
  local function weeklyclose()
    self.countdown:CloseWeekly()
    self.weeklyclose:Hide()

    if toggle then 
      self.weeklybtn:Show()
    end

    TheCamera:SetControllable(true)
  end
  
  local function weeklyopen()
    collapse()
    self.countdown:OpenWeekly()
    self.weeklybtn:Hide()
    self.weeklyclose:Show()
    TheCamera:SetControllable(false)
  end

  self.weeklybtn=self.root:AddChild(ImageButton("images/global_redux.xml", "button_carny_square_normal.tex", "button_carny_square_hover.tex", "button_carny_square_disabled.tex", "button_carny_square_down.tex", nil, {0.15, 0.15}, {0, 0}))
  self.weeklybtn:SetOnClick(weeklyopen)
  self.weeklyimg=self.weeklybtn:AddChild(Image("images/global_redux.xml", "arrow2_right_down.tex"))
  self.weeklyimg:ScaleToSize(15, 15)

  local weeklybtnoffset=self.countdown:GetWeeklyBtnOffset()
  local weeklycloseoffset=self.countdown:GetWeeklyCloseOffset()
  
  if (lang=="ZH" or lang=="ZT" or lang=="KO") then
    self.weeklybtn:SetPosition(weeklybtnoffset.x+25, weeklybtnoffset.y)
  else
    self.weeklybtn:SetPosition(weeklybtnoffset.x+20, weeklybtnoffset.y)
  end
  
  self.weeklyanchor=self.root:AddChild(Image("images/ui.xml", "blank.tex"))
  self.weeklyanchor:SetVAnchor(ANCHOR_MIDDLE)
  self.weeklyanchor:SetHAnchor(ANCHOR_MIDDLE)
  self.weeklyanchor:SetScaleMode(SCALEMODE_PROPORTIONAL)
 
  self.weeklyclose=self.weeklyanchor:AddChild(ImageButton("images/global_redux.xml", "button_carny_square_normal.tex", "button_carny_square_hover.tex", "button_carny_square_disabled.tex", "button_carny_square_down.tex", nil, {0.2, 0.2}, {0, 0}))
  self.weeklyclose:SetOnClick(weeklyclose)
  self.weeklyclose:SetPosition(weeklycloseoffset.x, weeklycloseoffset.y)
  self.weeklyclose:Hide()
  self.weeklyx=self.weeklyclose:AddChild(Image("images/global_redux.xml", "close.tex"))
  self.weeklyx:ScaleToSize(15, 15)

  if (TheFrontEnd:GetIsOfflineMode() or not TheNet:IsOnlineMode()) then
    self.weeklybtn:Hide()
  end

  if (options.collapse) then
    collapse()
    self.weeklybtn:Hide()
  end
end)

return DropsModalWidget