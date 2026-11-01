return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 10,
  height = 10,
  tilewidth = 64,
  tileheight = 64,
  properties = {},
  tilesets = {
    {
      name = "tiles",
      firstgid = 1,
      tilewidth = 64,
      tileheight = 64,
      spacing = 0,
      margin = 0,
      image = "../../../../../../Don't Starve Mod Tools/mod_tools/Tiled/dont_starve/tiles.png",
      imagewidth = 512,
      imageheight = 384,
      properties = {},
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "BG_TILES",
      x = 0,
      y = 0,
      width = 10,
      height = 10,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 1, 1, 1, 2, 2, 2, 1, 1, 1,
        0, 1, 2, 2, 2, 2, 2, 2, 2, 1,
        0, 1, 2, 2, 2, 2, 2, 2, 2, 1,
        0, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        0, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        0, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        0, 1, 2, 2, 2, 2, 2, 2, 2, 1,
        0, 1, 2, 2, 2, 2, 2, 2, 2, 1,
        0, 1, 1, 1, 2, 2, 2, 1, 1, 1,
        0, 1, 1, 1, 1, 1, 1, 1, 1, 1
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "multiplayer_portal",
          shape = "rectangle",
          x = 208,
          y = 208,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "spawnpoint_master",
          shape = "rectangle",
          x = 460, --349
          y = 285,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "maxwelllight_area",
          shape = "rectangle",
          x = 256,
          y = 193,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "maxwelllight_area",
          shape = "rectangle",
          x = 256,
          y = 379,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "maxwelllight_area",
          shape = "rectangle",
          x = 448,
          y = 381,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "maxwelllight_area",
          shape = "rectangle",
          x = 448,
          y = 191,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "oasislake",
          shape = "rectangle",
          x = 349,
          y = 285,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wardrobe",
          shape = "rectangle",
          x = 349,
          y = 93,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wardrobe",
          shape = "rectangle",
          x = 349,
          y = 477,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wardrobe",
          shape = "rectangle",
          x = 149,
          y = 285,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wardrobe",
          shape = "rectangle",
          x = 549,
          y = 285,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
      }
    }
  }
}
