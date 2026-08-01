local function goto_source_definition()
  local window = vim.api.nvim_get_current_win()
  local params = vim.lsp.util.make_position_params(window, "utf-16")

  LazyVim.lsp.execute({
    command = "typescript.goToSourceDefinition",
    arguments = { params.textDocument.uri, params.position },
    open = true,
  })
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local vtsls = opts.servers.vtsls
      vtsls.keys = vtsls.keys or {}

      table.insert(vtsls.keys, 1, {
        "gd",
        goto_source_definition,
        desc = "Goto Source Definition",
      })
    end,
  },
}
