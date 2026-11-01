GLOBAL.setmetatable(
	env,
	{
		__index = function(t, k)
			return GLOBAL.rawget(GLOBAL, k)
		end
	}
)

local Layouts = require("map/layouts").Layouts
local StaticLayout = require("map/static_layout")
require("constants")
require("map/tasks")
require("map/level")
require("map/lockandkey")

Layouts["TinyOasisLakeLayout"] =
	StaticLayout.Get(
	"map/static_layouts/room34",
	{
		start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
		fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
		layout_position = LAYOUT_POSITION.CENTER
	}
)

AddStartLocation(
	"EmptyStart",
	{
		name = STRINGS.UI.SANDBOXMENU.DEFAULTSTART,
		location = "forest",
		start_setpeice = "TinyOasisLakeLayout",
		start_node = "Blank"
	}
)

AddTask(
	"EmptyMap",
	{
		locks = {},
		keys_given = {},
		room_choices = {
			["Blank"] = 1
		},
		room_bg = GROUND.IMPASSABLE,
		background_room = "Blank",
		colour = {r = 0, g = 1, b = 0, a = 1}
	}
)

AddTaskSet(
	"emptytaskset",
	{
		name = "",
		location = "forest",
		tasks = {
			"EmptyMap"
		},
		numoptionaltasks = 0,
		optionaltasks = {},
		valid_start_tasks = {"EmptyMap"},
		set_pieces = {},
		ocean_prefill_setpieces = {},
		ocean_population = {}
	}
)

local extraoverrides = {
	start_location = "EmptyStart",
	task_set = "emptytaskset",
	wormhole_prefab = "wormhole",
	islands = "never",
	layout_mode = "LinkNodesByKeys",
	keep_disconnected_tiles = true,
	-- layout_mode = "RestrictNodesByKey",
	--weather  =  "never",
	creepyeyes = "always",
	boons = "never",
	day = "onlynight", --"onlynight",onlyday
	deerclops = "never",
	dragonfly = "never",
	bearger = "never",
	birds = "never",
	goosemoose = "never",
	hounds = "never",
	world_size = "small",
	autumn = "noseason",
	winter = "noseason",
	spring = "noseason",
	summer = "default",
	season_start = "summer",
	wildfires = "never",
	has_ocean = true,
	roads = "never",
	regrowth = "veryslow",
	krampus = "never",
	weather = "never"
}

local function Task(Level)
	-- if tasksetdata.location ~= "forest" then
	-- 	return tasksetdata
	-- end

	-- tasksetdata.numoptionaltasks = 0
	-- tasksetdata.optionaltasks = {}
	-- tasksetdata.valid_start_tasks = {"EmptyMap"}
	-- tasksetdata.set_pieces = {}
	-- tasksetdata.random_set_pieces = {}
	-- -- tasksetdata.ordered_story_setpieces = {}
	-- tasksetdata.ocean_prefill_setpieces = {}
	-- tasksetdata.ocean_population = {}
	-- tasksetdata.numrandom_set_pieces = 0

	-- -- tasksetdata.background_node_range = {0, 0}

	-- tasksetdata.required_prefabs = {}
	-- tasksetdata.required_setpieces = {}

	local overrides = Level.overrides or {}
	for k, v in pairs(extraoverrides) do
		overrides[k] = v
	end
	Level.overrides = overrides

	return Level
end
-- AddTaskSetPreInitAny(Task)

AddGlobalClassPostConstruct(
	"map/level",
	"Level",
	-- function(tasksetdata)
	Task
	-- end
)

-- fix world settings
local WorldSettings_Overrides = require("worldsettings_overrides")

local Pre = WorldSettings_Overrides.Pre
local Post = WorldSettings_Overrides.Post

for k, v in pairs(extraoverrides) do
	local target = Pre
	local oldfn = target[k]
	if oldfn == nil then
		target = Post
		oldfn = target[k]
	end
	if oldfn then
		target[k] = function(difficulty)
			print("force overriding world setting", k, difficulty, "-->", v)
			return oldfn(v)
		end
	end
end
