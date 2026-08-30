-- Autocmds are loaded on the VeryLazy event. The group below saves modified,
-- writable file buffers when insert mode is left.
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here with `vim.api.nvim_create_autocmd`.

local autosave = vim.api.nvim_create_augroup("user_autosave", { clear = true })

vim.api.nvim_create_autocmd("InsertLeave", {
  group = autosave,
  desc = "Save the current buffer when leaving insert mode or losing focus",
  callback = function(event)
    if vim.api.nvim_buf_is_valid(event.buf)
      and vim.bo[event.buf].buftype == ""
      and vim.bo[event.buf].modifiable
      and not vim.bo[event.buf].readonly
      and vim.bo[event.buf].modified then
      vim.api.nvim_buf_call(event.buf, function()
        vim.cmd("silent! update")
      end)
    end
  end,
})
