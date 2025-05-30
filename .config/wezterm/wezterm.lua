local wezterm = require("wezterm")
local gitbash = { "C:\\Program Files\\Git\\bin\\bash.exe", "-i", "-l" }

local mux = wezterm.mux

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
	pane:split { direction = 'Right', size = 0.5 }
end)

local config = wezterm.config_builder()

config.color_scheme = 'Ayu Mirage (Gogh)'
config.color_scheme = 'Catppuccin Mocha (Gogh)'


config.window_close_confirmation = 'NeverPrompt'
config.prefer_to_spawn_tabs = true
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
