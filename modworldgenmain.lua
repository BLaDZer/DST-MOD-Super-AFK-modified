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

AddTask("MinimalCaveStart", {
	locks = {},
	keys_given = {
		KEYS.CAVE,
		KEYS.TIER1,
		-- MoonCaveForest (locks MOONMUSH) -> gives ARCHIVE -> ArchiveMaze (archive_start has the archive_portal needed by the Vault layout)
		KEYS.MOONMUSH,
	},

	room_choices = {
		["LightPlantField"] = 1,
		["FernGully"] = 1,
		["PitRoom"] = 1,
	},

	background_room = "BGMud",
	room_bg = WORLD_TILES.MUD,

	colour = {
		r = 0.6,
		g = 0.4,
		b = 0.0,
		a = 0.9,
	},
})

AddTask("MinimalCaveExit", {
	locks = { LOCKS.CAVE },
	keys_given = {},

	room_choices = {
		["CaveExitRoom"] = 1,
		["RabbitArea"] = 1,
	},

	background_room = "BGSinkhole",
	room_bg = WORLD_TILES.SINKHOLE,

	colour = {
		r = 0.0,
		g = 0.5,
		b = 0.0,
		a = 0.9,
	},
})

AddTaskSet("minimal_caves", {
	name = "Minimal Caves",
	location = "cave",

	tasks = {
		"MinimalCaveStart",
		"MoonCaveForest",
		"ArchiveMaze",
		"MinimalCaveExit",
	},

	numoptionaltasks = 0,
	optionaltasks = {},

	valid_start_tasks = {
		"MinimalCaveStart",
	},

	-- required prefabs are already declared by the ArchiveMaze task; duplicating them here doubles the expected counts
	required_prefabs = {},
	set_pieces = {},
})

local forest_overrides = {
	start_location = "EmptyStart",
	task_set = "emptytaskset",
	wormhole_prefab = "wormhole",
	islands = "never",
	layout_mode = "LinkNodesByKeys",
	keep_disconnected_tiles = true,
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

local cave_overrides = {
	task_set = "minimal_caves",

	world_size = "small",
	branching = "least",
	loop = "never",

	touchstone = "never",
	boons = "never",
	regrowth = "never",
	basicresource_regrowth = "none",
	sinkhole_lights = "veryslow",
	traps = "never",
	poi = "never",
	protected = "never"
}

local location_overrides = {
	forest = forest_overrides,
	cave = cave_overrides
}

local function Task(Level)
	local overrides = Level.overrides or {}

	for k, v in pairs(location_overrides[Level.location] or {}) do
		overrides[k] = v
	end

	Level.overrides = overrides

	return Level
end

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

for k, v in pairs(forest_overrides) do
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
