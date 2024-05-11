local wezterm = require("wezterm")
local gitbash = { "C:\\Program Files\\Git\\bin\\bash.exe", "-i", "-l" }

local mux = wezterm.mux

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

local config = wezterm.config_builder()

config.color_scheme = 'Website (Gogh)'

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
