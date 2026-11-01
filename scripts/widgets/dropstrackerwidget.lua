--Drops Reset Countdown Steam Workshop Page: https://steamcommunity.com/sharedfiles/filedetails/?id=1688661034
--Website Version: https://dst-skins-checklist.firebaseapp.com/drops
--Created by Instant Noodles: https://steamcommunity.com/id/instant-noodles
--This mod may not be copied, altered, or reproduced in any way without the explicit and prior permission of the author

local DropsCountdownWidget=require("widgets/dropscountdownwidget")
local Widget=require("widgets/widget")

local DropsTrackerWidget=Class(Widget, function(self, options)
  Widget._ctor(self, "DropsTrackerWidget")
  self.root=self:AddChild(Widget("root"))

  self.countdown=self.root:AddChild(DropsCountdownWidget(options))
  self.countdown:StopUpdating()
  self.countdown:Hide()
end)

return DropsTrackerWidget