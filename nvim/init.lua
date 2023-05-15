local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.coc_global_extensions = { 'coc-tsserver', 'coc-prettier' }
-- use system clipboard
vim.api.nvim_set_option("clipboard", "unnamed")

if vim.g.vscode ~= nil then
  -- VS Code extension
  vim.cmd('source ' .. vim.fn.stdpath 'config' .. '/vscode/settings.lua')

  vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct

  require("lazy").setup({ "nvim-treesitter/nvim-treesitter", "machakann/vim-sandwich", 'numToStr/Comment.nvim', })
  require('Comment').setup()
else

end
