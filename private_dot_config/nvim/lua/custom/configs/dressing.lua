local opts = {
  select = {
    backend = { "builtin" },
    builtin = {
      show_numbers = false,
      relative = "cursor",
      win_options = {
        winblend = 0,
      },
      mappings = {
        ["q"] = "Close",
      },
    },
  },
}

require("dressing").setup(opts)
