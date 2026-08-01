-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here with `vim.api.nvim_create_autocmd`.

local autosave = vim.api.nvim_create_augroup("user_autosave", { clear = true })

vim.api.nvim_create_autocmd({ "FocusLost", "InsertLeave" }, {
  group = autosave,
  desc = "Save the current buffer when leaving insert mode or losing focus",
  callback = function(event)
    if vim.bo[event.buf].modifiable and not vim.bo[event.buf].readonly and vim.bo[event.buf].modified then
      vim.api.nvim_buf_call(event.buf, function()
        vim.cmd("silent! update")
      end)
    end
  end,
})

