GLOBAL.setmetatable(
	env,
	{
		__index = function(t, k)
			return GLOBAL.rawget(GLOBAL, k)
		end
	}
)

PrefabFiles = {
	"maxwelllight",
	"maxwelllight_flame",
	"disguiserod"
}
modimport("libs/lib_ver.lua")

Assets = {
	Asset("ANIM", "anim/swap_numbers.zip")
}

-- disable Wormwood's "livinglog" recipe
AllRecipes["livinglog"] = nil

if CLIENT_SIDE then
	local add_gift_count = function(inst)
		local skin_counter = inst.HUD.controls.skin_counter
		if skin_counter then
			skin_counter:CountChanged()
		end
	end
	local on_skin_count = function(inst)
		if inst ~= _G.ThePlayer or inst.HUD == nil or false then
			return
		end
		inst:DoTaskInTime(1.2, add_gift_count)
	end

	--Test this by running TheFrontEnd:PushScreen(require("screens/giftitempopup")(ThePlayer, { "birdcage_pirate" }, { 0 }) )
	AddPlayersPostInit(
		function(inst)
			inst:ListenForEvent("idle_mods.skins_count_changed", on_skin_count)
		end
	)
	--The gift item popup
	AddClassPostConstruct(
		"screens/giftitempopup",
		function(self)
			self.inst:DoTaskInTime(
				177 * _G.FRAMES,
				function()
					self:OnClose()
					self.owner:PushEvent("idle_mods.skins_count_changed")
				end
			)
		end
	)
end

--widget
AddClassPostConstruct(
	"widgets/giftitemtoast",
	function(self)
		local function OpenGift()
			self.owner:DoTaskInTime(
				.5,
				function()
					--фикс визуального бага
					if self.tab_gift.enabled then
						self:DoOpenGift()
					end
				end
			)
		end

		--Да, это не очень хорошо, но по-другому никак...
		self.owner.open_cheat_task = self.owner:DoPeriodicTask(.5, OpenGift)
	end
)

--our own skin counter
local showcounter = GetModConfigData("showcounter")
if showcounter then
	local SkinCouner = require("widgets/skin_counter")
	AddClassPostConstruct(
		"widgets/controls",
		function(self)
			self.skin_counter = self.bottom_root:AddChild(SkinCouner(self.owner))
			self.skin_counter:SetPosition(400, 175, 0) ---355/175/0
			self.skin_counter:SetScale(.4)
		end
	)
end

do
	local s = _G.STRINGS

	s.SKINS_COUNT = "Skins recieved:"

	local rus = mods.RussianLanguagePack or mods.UniversalTranslator
	if rus then
		s.SKINS_COUNT = "Получено скинов:"
	end
end

GetGlobal(
	"PopupTest",
	function()
		local GiftItemPopUp = require "screens/giftitempopup"
		local TEST_ITEM_NAME = "backpack_buckle_grey_pewter"
		_G.TheFrontEnd:PushScreen(GiftItemPopUp(_G.ThePlayer, {TEST_ITEM_NAME}, {0}))
	end
)

-- despawn command
do
	local reroll_cd = GetModConfigData("reroll_cd") or 600
	local time_mem = {}
	local function can_reroll(caller)
		local userid = type(caller) == "table" and caller.IsValid and caller:IsValid() and caller.userid
		if userid then
			local age = caller.components.age and caller.components.age:GetAge()
			if age then
				local saved = time_mem[userid] or 0
				local cd = reroll_cd - age + saved
				if cd <= 0 then
					time_mem[userid] = age
					return true
				elseif caller.components.talker then
					caller.components.talker:Say(string.format("Reselect Character (CD: %d seconds)", cd))
				end
			end
		end
		return false
	end
	AddUserCommand(
		"afkdespawn",
		{
			permission = _G.COMMAND_PERMISSION.USER,
			params = {},
			emote = false,
			slash = true,
			usermenu = false,
			servermenu = false,
			vote = false,
			serverfn = function(params, caller)
				if can_reroll(caller) then
					if not TheWorld:HasTag("cave") then
						caller:PushEvent("ms_playerreroll")
						local reroll_save = TheWorld.reroll_save or {}
						reroll_save[caller.userid] = caller.SaveForReroll and caller:SaveForReroll()
						TheWorld.reroll_save = reroll_save
					end
					TheWorld:PushEvent("ms_playerdespawnanddelete", caller)
				end
			end
		}
	)

	local temp_time = GetTime()
	local function do_send_cmd()
		local now = GetTime()
		if now - temp_time > 3 then
			temp_time = now
			TheNet:SendSlashCmdToServer("afkdespawn", true)
		end
	end
	local Widget = require "widgets/widget"
	local TEMPLATES = require "widgets/redux/templates"

	-- local MysteryBoxScreen = require "screens/redux/mysteryboxscreen"
	local function AddBtn(self)
		local root = self:AddChild(Widget("left_bottom_root_root"))
		root:SetScaleMode(SCALEMODE_PROPORTIONAL)
		root:SetHAnchor(ANCHOR_LEFT)
		root:SetVAnchor(ANCHOR_BOTTOM)
		root:SetMaxPropUpscale(MAX_HUD_SCALE)

		root = root:AddChild(Widget("left_bottom_root"))
		root:SetScale(TheFrontEnd:GetHUDScale())

		root.inst:ListenForEvent(
			"refreshhudsize",
			function(src, scale)
				self.left_bottom_root:SetScale(scale, scale, scale)
			end,
			ThePlayer.HUD.inst
		)

		-- local btn = root:AddChild(ImageButton("images/avatars.xml", "avatar_bg.tex", nil, nil, nil, nil, {1, 1}, {100, 80}))

		local btn = root:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "undo.tex", "Reselect Character", false, false, do_send_cmd))
		btn:SetPosition(120, 80)

		self.left_bottom_root = root
		self.super_afk_reroll_btn = btn
		-----
		-- local btn2 =
		-- 	root:AddChild(
		-- 	TEMPLATES.IconButton(
		-- 		"images/button_icons.xml",
		-- 		"owned_filter_on.tex",
		-- 		STRINGS.UI.MAINSCREEN.MYSTERYBOX,
		-- 		false,
		-- 		false,
		-- 		function()
		-- 			TheFrontEnd:FadeToScreen(
		-- 				{
		-- 					Hide = function()
		-- 					end
		-- 				},
		-- 				function()
		-- 					return MysteryBoxScreen({Profile})
		-- 				end,
		-- 				nil,
		-- 				"swipe"
		-- 			)
		-- 		end
		-- 	)
		-- )
		-- btn2:SetPosition(200, 80)
		-- self.open_box_btn = btn2
	end

	AddClassPostConstruct("widgets/controls", AddBtn)
end
if SERVER_SIDE then
	-- no start item

	for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT) do
		for i = #v, 1, -1 do
			table.remove(v, i)
		end
	end

	--Тут очень хитро. К игроку привязываем научку, чтоб не парится с компонентом
	local COLLISION = _G.COLLISION

	local function ToggleOffPhysics(inst)
		inst.is_physics_disabled = true
		inst.Physics:ClearCollisionMask()
		inst.Physics:CollidesWith(COLLISION.GROUND)
	end

	-- open gift without science machine
	local function SetGiftMachine(self, ...)
		self.giftmachine = self.inst
	end
	AddComponentPostInit(
		"giftreceiver",
		function(GiftReceiver)
			GiftReceiver.giftmachine = GiftReceiver.inst
			GiftReceiver.SetGiftMachine = SetGiftMachine
		end
	)

	local function SetGodMode(inst)
		local cmps = inst.components
		if cmps.health then
			local cmp = cmps.health
			cmp:SetInvincible(true)
			if cmp:GetPercent() < 1 then
				cmp:SetPercent(1)
			end
		end

		if cmps.sanity then
			local cmp = cmps.sanity
			if cmp:GetRealPercent() < 1 then
				cmp:SetPercent(1)
			end
		end

		if cmps.hunger then
			local cmp = cmps.hunger
			if cmp:GetPercent() < 1 then
				cmp:SetPercent(1)
			end
		end

		if cmps.moisture then
			cmps.moisture:SetPercent(0)
		end

		if cmps.temperature then
			cmps.temperature:SetTemperature(37)
		end
	end

	AddPlayersAfterInit(
		function(inst)
			-- if inst.giftreciever_machine == nil then
			-- 	inst.giftreciever_machine = SpawnPrefab("researchlab2")
			-- end

			-- if inst.giftreciever_machine then
			-- 	inst:AddChild(inst.giftreciever_machine)
			-- 	ToggleOffPhysics(inst.giftreciever_machine)
			-- 	inst.giftreciever_machine:Hide()
			-- end

			--god
			SetGodMode(inst)
			inst:ListenForEvent("healthdelta", SetGodMode)
			inst:ListenForEvent("hungerdelta", SetGodMode)
			-- inst:ListenForEvent("sanitydelta", SetGodMode)

			--if inst.components.builder then
			--	inst.components.builder:GiveAllRecipes()
			--end
		end
	)

	-- --Если включён говно-мод, то отрубаем его
	-- AddWorldPostInit(
	-- 	function(w)
	-- 		w:DoTaskInTime(
	-- 			2,
	-- 			function()
	-- 				if _G.KnownModIndex:IsModEnabled("workshop-747335073") then
	-- 					_G.KnownModIndex:DisableBecauseIncompatibleWithMode("workshop-747335073")

	-- 					_G.ForceAssetReset()
	-- 					_G.KnownModIndex:Save(
	-- 						function()
	-- 							_G.c_reset()
	-- 						end
	-- 					)
	-- 				end
	-- 			end
	-- 		)
	-- 	end
	-- )
	----------
	local function remove_burnable(inst)
		inst:RemoveComponent("burnable")
	end
	AddPrefabPostInit(
		"wardrobe",
		function(inst)
			inst:DoTaskInTime(0, remove_burnable)
		end
	)
	local new_remove_tag = function(inst, tag, ...)
		if tag == "NOCLICK" then
			return
		end
		return inst:_sa_old_RemoveTag(tag, ...)
	end
	AddPrefabPostInit(
		"fireflies",
		function(inst)
			inst._sa_old_RemoveTag = inst.RemoveTag
			inst.RemoveTag = new_remove_tag
			inst:AddTag("NOCLICK")
		end
	)
	-------------
	if GetModConfigData("undestroyable") then
		-- make structures unworkable
		local false_fn = function()
			return false
		end
		local SetWorkable = function(self)
			self.workable = false
		end
		local SetWorkAction = function(self)
			self.action = nil
		end
		AddComponentPostInit(
			"workable",
			function(workable, inst)
				workable.CanBeWorked = false_fn
				workable.SetWorkable = SetWorkable
				workable.SetWorkAction = SetWorkable
			end
		)
	end

	-- Woodie wereness
	local SetWereMode = function(self)
		self.weremode = nil
	end

	local DoDelta = function(self, delta, overtime)
		self.current = self.max
		self._old = self.current
		self:StopDraining()
	end
	AddComponentPostInit(
		"wereness",
		function(Wereness, inst)
			Wereness.DoDelta = DoDelta
			Wereness.SetWereMode = SetWereMode
			Wereness.GetWereMode = SetWereMode
		end
	)
	-------------
	-- clean items on groun
	local function OnPickedUp(inst)
		inst._clean_count = nil
	end
	AddComponentPostInit(
		"inventoryitem",
		function(_, inst)
			inst:ListenForEvent("onputininventory", OnPickedUp)
		end
	)
	local CLEAN_MUST_TAGS = {"_inventoryitem"}
	local CLEAN_CANT_TAGS = {"locomotor", "INLIMBO"}

	GLOBAL.sa_clean = function()
		local allitems = TheSim:FindEntities(0, 0, 0, 9001, CLEAN_MUST_TAGS, CLEAN_CANT_TAGS)
		if allitems then
			for _, v in ipairs(allitems) do
				v:Remove()
			end
		end
	end

	local function do_clean()
		local allitems = TheSim:FindEntities(0, 0, 0, 9001, CLEAN_MUST_TAGS, CLEAN_CANT_TAGS)
		if allitems then
			for _, v in ipairs(allitems) do
				-- v:DoTaskInTime(0, v.Remove)
				local c = v._clean_count or 0
				if c >= 1 then
					v:Remove()
				else
					v._clean_count = c + 1
				end
			end
		end
	end
	local cleaning_interval = GetModConfigData("clean_interval") or 240
	AddWorldPostInit(
		function(inst)
			if inst then
				inst:DoPeriodicTask(cleaning_interval, do_clean)
				inst.reroll_save = {}
				-- resume reroll save
				inst:ListenForEvent(
					"ms_newplayerspawned",
					function(world, player)
						if world.reroll_save[player.userid] and player.LoadForReroll then
							player:LoadForReroll(world.reroll_save[player.userid])
							world.reroll_save[player.userid] = nil
						end
					end
				)
			end
		end
	)
	---------------
	-- delete multiplayer_portal
	AddPrefabPostInit(
		"multiplayer_portal",
		function(inst)
			inst:DoTaskInTime(0, inst.Remove)
		end
	)
end

--keep player online via sending dummy rpc
do
	--dummy func
	local function nopFn()
		-- local o
	end
	AddModRPCHandler("NOP", "NOP", nopFn)
	if CLIENT_SIDE then
		AddWorldPostInit(
			function(inst)
				-- if inst then
				inst:DoPeriodicTask(
					30,
					function()
						SendModRPCToServer(MOD_RPC["NOP"]["NOP"])
					end
				)
				-- end
			end
		)
	end
end

----------------------

do
	if SERVER_SIDE then
		-- give fishing rod to new players

		local OnPlayerSpawn = function(src, player)
			player.prev_OnNewSpawn = player.OnNewSpawn or function()
					return true
				end
			player.OnNewSpawn = function(...)
				player.components.inventory.ignoresound = true
				for i = 1, 1, 1 do
					local item = GLOBAL.SpawnPrefab("fishingrod")
					local itemequipslot = item.components.equippable.equipslot
					if not player.components.inventory:IsFull() then
						player.components.inventory:GetEquippedItem(itemequipslot)
						player.components.inventory:Equip(item)
					end
				end
				player.components.inventory.ignoresound = false
				return player.prev_OnNewSpawn(...)
			end
		end

		local Init = function(inst)
			inst:ListenForEvent("ms_playerspawn", OnPlayerSpawn, inst)
		end
		AddPrefabPostInit("world", Init)

		---------------

		-- let fishing rod be infinite

		local old_onequip
		local old_onunequip

		local function new_onequip(inst, owner)
			inst.components.finiteuses = {
				StartConsuming = function()
				end
			}
			old_onequip(inst, owner)
			inst.components.finiteuses = nil
		end

		local function new_onunequip(inst, owner)
			inst.components.finiteuses = {
				StopConsuming = function()
				end
			}
			old_onunequip(inst, owner)
			inst.components.finiteuses = nil
		end

		local function new_fishingrod_fn(inst)
			if GLOBAL.TheWorld.ismastersim then
				inst:RemoveComponent("finiteuses")
				inst:RemoveComponent("weapon")

				old_onequip = inst.components.equippable.onequipfn
				old_onunequip = inst.components.equippable.onunequipfn
				inst.components.equippable:SetOnEquip(new_onequip)
				inst.components.equippable:SetOnUnequip(new_onunequip)
			end
		end

		AddPrefabPostInit("fishingrod", new_fishingrod_fn)
	end

	-----

	-- Add a recipe to allow conversion between disguiserod and fishingrod.
	local CHARACTER_INGREDIENT = GLOBAL.CHARACTER_INGREDIENT
	local require = GLOBAL.require
	local STRINGS = GLOBAL.STRINGS
	local RECIPETABS = GLOBAL.RECIPETABS
	local TECH = GLOBAL.TECH

	AddRecipe("disguiserod", {Ingredient("fishingrod", 1)}, RECIPETABS.MAGIC, TECH.NONE, nil, nil, nil, nil, nil, "images/inventoryimages/disguiserod.xml", "disguiserod.tex")
	AddRecipe("fishingrod", {Ingredient("disguiserod", 1, "images/inventoryimages/disguiserod.xml")}, RECIPETABS.MAGIC, TECH.NONE, nil, nil, nil, nil, nil, "images/inventoryimages.xml", "fishingrod.tex")

	-- Add disguiserod action
	-- disguiserod can be used to copy the appearance of other players

	AddComponentAction(
		"EQUIPPED",
		"disguiserod_component",
		function(inst, doer, target, actions, right)
			if right then
				if target:HasTag("character") then
					table.insert(actions, GLOBAL.ACTIONS.DISGUISEROD)
				end
			end
		end
	)

	local DISGUISEROD = GLOBAL.Action({priority = 10, rmb = true, distance = 20, mount_valid = true})
	DISGUISEROD.str = "Disguise"
	DISGUISEROD.id = "DISGUISEROD"
	DISGUISEROD.fn = function(act)
		if act.doer ~= nil and act.invobject ~= nil and act.target ~= nil then
			act.invobject.components.disguiserod_component:DoCopy(act.doer, act.target)
			return true
		else
			return false
		end
	end
	AddAction(DISGUISEROD)

	AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.DISGUISEROD, "quickcastspell"))
	AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.DISGUISEROD, "quickcastspell"))
end

----------------
-- The functionality and related code below come from another MOD. It was originally a pure client-side MOD.

--Drops Reset Countdown Steam Workshop Page: https://steamcommunity.com/sharedfiles/filedetails/?id=1688661034
--Website Version: https://dst-skins-checklist.firebaseapp.com/drops
--Created by Instant Noodles: https://steamcommunity.com/id/instant-noodles
--This mod may not be copied, altered, or reproduced in any way without the explicit and prior permission of the author

if GetModConfigData("dsc") then
	local Controls = GLOBAL.require("widgets/controls")
	local DropsModalWidget = GLOBAL.require("widgets/dropsmodalwidget")
	local DropsTrackerWidget = GLOBAL.require("widgets/dropstrackerwidget")
	-- local Widget = GLOBAL.require("widgets/widget")
	modimport("scripts/drops_strings.lua")

	local boxW = 370
	local mmscale, mgscale = 1, 1
	local MSN = Controls.MakeScalingNodes
	local options = {
		autoopen = false,
		clock = "24",
		collapse = false,
		datetime = true,
		directory = MODROOT,
		language = GetModConfigData("language"),
		list = true,
		modname = modinfo.name,
		strings = ModStrings,
		modversion = modinfo.version,
		resettime = true,
		size = 12
	}

	Controls.MakeScalingNodes = function(self)
		MSN(self)

		-- if (GetModConfigData("ingame")) then -- here asume ingame is always true
		self.modal = self.topleft_root:AddChild(DropsModalWidget(options))

		if (mgscale > 1) then
			self.modal:SetPosition((boxW + boxW / 6) * mgscale + 176, 0)
			self.modal:SetScale(mgscale, mgscale, mgscale)
		else
			self.modal:SetPosition(boxW + 238, 0)
		end
		-- else
		-- 	self.tracker = self.topleft_root:AddChild(DropsTrackerWidget(options))
		-- 	self.tracker:SetPosition(boxW + 238, 0)
		-- end
	end
end

----------------------
