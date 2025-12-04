return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      file_ignore_patterns = { "node_modules" },
      vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "--hidden",
        "--glob=!node_modules/*",
      },
      find_command = {
        "fd",
        "--type", "f",
        "--hidden",
        "--exclude", "node_modules",
      },
    },
  },
}
