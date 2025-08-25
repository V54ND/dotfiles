local wezterm = require("wezterm")
local gitbash = { "C:\\Program Files\\Git\\bin\\bash.exe", "-li" }

local mux = wezterm.mux

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
	pane:split { direction = 'Right', size = 0.5 }
end)

local config = wezterm.config_builder()

-- 🎨 Цветовые схемы
config.color_scheme = 'Catppuccin Mocha (Gogh)'

-- -- 🖥 Tab Bar
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true

-- 🔧 Поведение окна
config.window_close_confirmation = 'NeverPrompt'
config.prefer_to_spawn_tabs = true
config.window_background_opacity = 0.9

-- 🚀 Меню запуска
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

-- 🐚 По умолчанию — Git Bash
config.default_prog = gitbash

-- 🔤 Шрифт
config.font = wezterm.font("Iosevka Nerd Font")
config.font_size = 14

-- -- 📜 Scrollback
config.scrollback_lines = 5000

-- -- 🌈 TERM для Git Bash
config.term = "xterm-256color"

-- ⌨️ Горячие клавиши
config.keys = {
	{ key = "d", mods = "CTRL|ALT", action = wezterm.action { SplitHorizontal = { domain = "CurrentPaneDomain" } } },
	{ key = "D", mods = "CTRL|ALT", action = wezterm.action { SplitVertical = { domain = "CurrentPaneDomain" } } },
	{ key = "t", mods = "CTRL|ALT", action = wezterm.action { SpawnTab = "CurrentPaneDomain" } },
	{ key = "w", mods = "CTRL|ALT", action = wezterm.action { CloseCurrentPane = { confirm = true } } },
	{ key = "c", mods = "CTRL|SHIFT", action = wezterm.action { CopyTo = "Clipboard" } },
	{ key = "v", mods = "CTRL|SHIFT", action = wezterm.action { PasteFrom = "Clipboard" } },
}

-- 🏷 Динамические заголовки табов
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = tab.active_pane.title
	local cwd_uri = tab.active_pane.current_working_dir
	local cwd = ""

	if cwd_uri then
		cwd = cwd_uri.file_path:gsub("^.+\\", "") -- только имя папки
	end

	if cwd ~= "" then
		title = cwd
	end

	-- пробуем достать git ветку (асинхронно в shell)
	if tab.active_pane.domain_name == "local" and cwd_uri then
		local success, stdout, _ = wezterm.run_child_process({
			"git", "-C", cwd_uri.file_path, "rev-parse", "--abbrev-ref", "HEAD"
		})
		if success and stdout and #stdout > 0 then
			local branch = stdout:gsub("%s+", "")
			if branch ~= "HEAD" then
				title = title .. "  " .. branch
			end
		end
	end

	return {
		{ Attribute = { Intensity = "Bold" } },
		{ Background = { Color = "rgba(0,0,0,0)" } }, -- прозрачный фон
		{ Text = " " .. title .. " " },
	}
end)

return config
