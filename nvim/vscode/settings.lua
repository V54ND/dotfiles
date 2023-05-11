local function split(direction, file)
  if direction == "h" then
    vim.api.nvim_command("call VSCodeCall('workbench.action.splitEditorDown')")
  else
    vim.api.nvim_command("call VSCodeCall('workbench.action.splitEditorRight')")
  end
  if file ~= "" then
    vim.api.nvim_command("call VSCodeExtensionNotify('open-file', expand('" .. file .. "'), 'all')")
  end
end

local function split_new(direction, file)
  split(direction, file == "" and "__vscode_new__" or file)
end

local function close_other_editors()
  vim.fn.execute("only")
end

local function manage_editor_size(count, to)
  count = count or 1
  for i = 1, count do
    if to == 'increase' then
      vim.api.nvim_command("call VSCodeNotify('workbench.action.increaseViewSize')")
    else
      vim.api.nvim_command("call VSCodeNotify('workbench.action.decreaseViewSize')")
    end
  end
end

_G.split = split
_G.split_new = split_new
_G.manage_editor_size = manage_editor_size
_G.Comment = Comment

vim.cmd("command! -complete=file -nargs=? Split call v:lua.split('h', <q-args>)")
vim.cmd("command! -complete=file -nargs=? Vsplit call v:lua.split('v', <q-args>)")
vim.cmd("command! -complete=file -nargs=? New call v:lua.split_new('h', '__vscode_new__')")
vim.cmd("command! -complete=file -nargs=? Vnew call v:lua.split_new('v', '__vscode_new__')")

-- Split horisontaly
vim.api.nvim_set_keymap("n", "<C-w>s", "<cmd>lua split('h', '')<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("x", "<C-w>s", "<cmd>lua split('h', '')<CR>", { noremap = true, silent = true })

-- Split vertically
vim.api.nvim_set_keymap("n", "<C-w>v", "<cmd>lua split('v', '')<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("x", "<C-w>v", "<cmd>lua split('v', '')<CR>", { noremap = true, silent = true })

-- Split and create new file
vim.api.nvim_set_keymap("n", "<C-w>n", "<cmd>lua split_new('h', '__vscode_new__')<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("x", "<C-w>n", "<cmd>lua split_new('h', '__vscode_new__')<CR>", { noremap = true, silent = true })

-- Equal editor widths
vim.api.nvim_set_keymap('n', '<C-w>=', ':<C-u>call VSCodeNotify("workbench.action.evenEditorWidths")<CR>',
  { silent = true })
vim.api.nvim_set_keymap('x', '<C-w>=', ':<C-u>call VSCodeNotify("workbench.action.evenEditorWidths")<CR>',
  { silent = true })

vim.api.nvim_set_keymap("n", "<C-w>>", "<cmd>lua manage_editor_size(vim.v.count, 'increase')<CR>",
  { noremap = true, silent = true })
vim.api.nvim_set_keymap("x", "<C-w>>", "<cmd>lua manage_editor_size(vim.v.count, 'increase')<CR>",
  { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C->+", "<cmd>lua manage_editor_size(vim.v.count, 'increase')<CR>",
  { noremap = true, silent = true })
vim.api.nvim_set_keymap("x", "<C-w>+", "<cmd>lua manage_editor_size(vim.v.count, 'increase')<CR>",
  { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-w><", "<cmd>lua manage_editor_size(vim.v.count, 'decrease')<CR>",
  { noremap = true, silent = true })
vim.api.nvim_set_keymap("x", "<C-w><", "<cmd>lua manage_editor_size(vim.v.count, 'decrease')<CR>",
  { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-w>-", "<cmd>lua manage_editor_size(vim.v.count, 'decrease')<CR>",
  { noremap = true, silent = true })
vim.api.nvim_set_keymap("x", "<C-w>-", "<cmd>lua manage_editor_size(vim.v.count, 'decrease')<CR>",
  { noremap = true, silent = true })

-- Better navigation
vim.api.nvim_set_keymap('n', '<C-j>', "<cmd>call VSCodeNotify('workbench.action.navigateDown')<CR>",
  { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', '<C-j>', "<cmd>call VSCodeNotify('workbench.action.navigateDown')<CR>",
  { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-k>', "<cmd>call VSCodeNotify('workbench.action.navigateUp')<CR>",
  { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', '<C-k>', "<cmd>call VSCodeNotify('workbench.action.navigateUp')<CR>",
  { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-h>', "<cmd>call VSCodeNotify('workbench.action.navigateLeft')<CR>",
  { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', '<C-h>', "<cmd>call VSCodeNotify('workbench.action.navigateLeft')<CR>",
  { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-l>', "<cmd>call VSCodeNotify('workbench.action.navigateRight')<CR>",
  { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', '<C-l>', "<cmd>call VSCodeNotify('workbench.action.navigateRight')<CR>",
  { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', '<S-l>', "<cmd>call VSCodeNotify('workbench.action.navigateRight')<CR>",
  { noremap = true, silent = true })

-- Bind C-/ to vscode commentary since calling from vscode produces double comments due to multiple cursors
vim.api.nvim_set_keymap('x', '<C-/>', "lua VSCodeNotifyVisual('editor.action.blockComment')<CR>", { silent = true })
vim.api.nvim_set_keymap('n', '<C-/>', "lua VSCodeNotifyVisual('editor.action.blockComment')<CR>", { silent = true })

-- After triggeting equal width return to custtom widths
vim.api.nvim_set_keymap("n", "<C-w>_", ":<C-u>call VSCodeNotify('workbench.action.toggleEditorWidths')<CR>",
  { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<Space>", "<cmd>call VSCodeNotify('whichkey.show')<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("x", "<Space>", "<cmd>call VSCodeNotify('whichkey.show')<CR>", { noremap = true, silent = true })
