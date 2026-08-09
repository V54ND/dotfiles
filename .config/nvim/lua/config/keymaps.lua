-- Keymaps are loaded on the VeryLazy event. "jj" is an insert-mode escape
-- shortcut that avoids reaching for Escape.
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode" })
