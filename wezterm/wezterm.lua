local wezterm = require("wezterm")
local gitbash = { "C:\\Program Files\\Git\\bin\\bash.exe", "-i", "-l" }

local config = wezterm.config_builder()

config.color_scheme = "AdventureTime"

config.window_background_opacity = 0.9

config.launch_menu = {
	{
		label = "Powershell",
		args = { "powershell" },
	},
	{
		label = "Git Bash",
		args = gitbash,
	},
}

config.default_prog = gitbash

config.font = wezterm.font("Iosevka Nerd Font")

config.font_size = 14

return config
