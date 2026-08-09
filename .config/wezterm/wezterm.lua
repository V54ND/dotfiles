local wezterm = require("wezterm")
local mux = wezterm.mux
local target = wezterm.target_triple
local is_windows = target:find("windows") ~= nil
local is_macos = target:find("apple") ~= nil

local git_bash = { "C:\\Program Files\\Git\\bin\\bash.exe", "-li" }
local zsh = { "/bin/zsh", "-l" }

wezterm.on("gui-startup", function(cmd)
	local _, _, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

local config = wezterm.config_builder()

-- 🎨 Цветовые схемы
config.color_scheme = 'Kanagawa (Gogh)'


-- -- 🖥 Tab Bar
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = true

-- 🔧 Поведение окна
config.window_close_confirmation = 'NeverPrompt'
config.prefer_to_spawn_tabs = true
config.window_background_opacity = 0.9

-- 🚀 Меню запуска и shell по умолчанию для каждой ОС
if is_windows then
	config.default_prog = git_bash
	config.launch_menu = {
		{
			label = "PowerShell",
			args = { "powershell.exe", "-NoLogo" },
		},
		{
			label = "Git Bash",
			args = git_bash,
		},
	}
elseif is_macos then
	config.default_prog = zsh
	config.launch_menu = {
		{
			label = "Zsh",
			args = zsh,
		},
		{
			label = "Bash",
			args = { "/bin/bash", "-l" },
		},
	}
end


-- 🔤 Шрифт
config.font = wezterm.font("MonaspiceNe Nerd Font Mono")
config.font_size = 12

-- -- 📜 Scrollback
config.scrollback_lines = 5000

-- ⌨️ Горячие клавиши
config.keys = {
	{ key = "d", mods = "CTRL|ALT",   action = wezterm.action { SplitHorizontal = { domain = "CurrentPaneDomain" } } },
	{ key = "D", mods = "CTRL|ALT",   action = wezterm.action { SplitVertical = { domain = "CurrentPaneDomain" } } },
	{ key = "t", mods = "CTRL|ALT",   action = wezterm.action { SpawnTab = "CurrentPaneDomain" } },
	{ key = "w", mods = "CTRL|ALT",   action = wezterm.action { CloseCurrentPane = { confirm = true } } },
	{ key = "c", mods = "CTRL|SHIFT", action = wezterm.action { CopyTo = "Clipboard" } },
	{ key = "v", mods = "CTRL|SHIFT", action = wezterm.action { PasteFrom = "Clipboard" } },
}

-- 🏷 Имя текущей директории в заголовке таба
wezterm.on("format-tab-title", function(tab)
	local title = tab.active_pane.title
	local cwd_uri = tab.active_pane.current_working_dir

	if cwd_uri then
		local path = cwd_uri.file_path:gsub("\\", "/"):gsub("/+$", "")
		local cwd = path:match("([^/]+)$")
		if cwd and cwd ~= "" then
			title = cwd
		end
	end

	return {
		{ Attribute = { Intensity = "Bold" } },
		{ Background = { Color = "rgba(0,0,0,0)" } }, -- прозрачный фон
		{ Text = " " .. title .. " " },
	}
end)

return config
