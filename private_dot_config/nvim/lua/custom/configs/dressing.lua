local opts = {
  input = {
    enabled = false,
  },
  select = {
    backend = { "builtin" },
    builtin = {
      relative = "cursor",
      win_options = {
        winblend = 0,
      },
    },
  },
}

require("dressing").setup(opts)
