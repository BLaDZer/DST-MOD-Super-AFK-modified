name = " 󰀮 Super AFK 󰀮 (modified)"
description = [[
This mod have all for you need to drop yours skins!
- Godmode (without creative mode)
- Disable idle kick (afk forever)
- Auto open Gifts (without machine machine)
- Use small memory (3s to generating world)
- Displays the number of gifts received when afk
- Change clothes immediately with Wardrobe
- Have fun with an infinite fishing rod.

Modifications:
- Smaller map (only one island now)
- Wardrobes are no longer burnable
- Fireflies are unclickable
- Clean items on the ground automatically (or use sa_clean() manually)
- Remove sound effects from scientific machines
- Remove starting items of characters
- Add a reselect character button
- Woodie no longer becomes a monster
- Move the spawn point to outside the oasis lake.
- Make architectures undestroyable (disabled by default)

original mod: https://steamcommunity.com/sharedfiles/filedetails/?id=1981709850

]]
author = "Nana ツ & Instant Noodles & other excellent modders"
version = "1.0.7"
version_compatible = "1.0.6"
all_clients_require_mod = true
dst_compatible = true
client_only_mod = false
api_version = 10
priority = 8
icon_atlas = "modicon.xml"
icon = "modicon.tex"
server_filter_tags = {"nanasora", "superX", "afk1", "idle"}
folder_name = folder_name or "workshop-"
if not folder_name:find("workshop-") then
  name = name .. " - dev"
end
configuration_options = {
  {
    name = "dsc",
    label = "Drops Reset Countdown ",
    options = {
      {description = "Enable", data = true, hover = ""},
      {description = "Disable", data = false, hover = ""}
    },
    default = true
  },
  {
    name = "showcounter",
    label = "Show Skin Counter",
    options = {
      {description = "Enable", data = true, hover = ""},
      {description = "Disable", data = false, hover = ""}
    },
    default = true
  },
  {
    name = "undestroyable",
    label = "Structures Undestroyable",
    options = {
      {description = "Enable", data = true, hover = ""},
      {description = "Disable", data = false, hover = ""}
    },
    default = false
  },
  {
    -- The time interval between when an item is dropped on the ground and when it is cleaned may be 1 to 2 times this value.
    name = "clean_interval",
    label = "Cleaning Interval",
    options = {
      {description = "30s", data = 30},
      {description = "1min", data = 60},
      {description = "2min", data = 120},
      {description = "3min", data = 180},
      {description = "4min", data = 240},
      {description = "5min", data = 300},
      {description = "8min", data = 480},
      {description = "10min", data = 600},
      {description = "15min", data = 900},
      {description = "20min", data = 1200}
    },
    default = 240
  },
  {
    name = "reroll_cd",
    label = "Reroll Cooldown",
    options = {
      {description = "30s", data = 30},
      {description = "1min", data = 60},
      {description = "2min", data = 120},
      {description = "3min", data = 180},
      {description = "4min", data = 240},
      {description = "5min", data = 300},
      {description = "8min", data = 480},
      {description = "10min", data = 600},
      {description = "15min", data = 900},
      {description = "20min", data = 1200},
      {description = "30min", data = 1800},
      {description = "45min", data = 2700},
      {description = "60min", data = 3600}
    },
    default = 600
  },
  {
    name = "language",
    label="Language/Язык/语言/Idioma/언어",
    options={
      {description="English (US)", data="EN", hover="Sets the interface to English (US Date Format)"},
      {description="English (UK)", data="EU", hover="Sets the interface to English (UK Date Format)"},
      {description="Русский", data="RU", hover="Sets the interface to Russian"},
      {description="简体中文", data="ZH", hover="Sets the interface to Simplified Chinese"},
      {description="繁體中文", data="ZT", hover="Sets the interface to Traditional Chinese"},
      {description="Português do Brasil", data="PT", hover="Sets the interface to Brazilian Portuguese"},
      {description="한국어", data="KO", hover="Sets the interface to Korean"}
    },
    default = "EN"
  }
}
