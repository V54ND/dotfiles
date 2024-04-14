-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here


vim.api.nvim_set_option("clipboard", "unnamed")

vim.api.nvim_exec([[
  augroup autosave
    autocmd!
    autocmd InsertLeave,FocusLost * silent! w
  augroup END
]], false) -- autosave
