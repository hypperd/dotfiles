local M = {}

local highlights = require "custom.highlights"

local api = vim.api

M.ui = {
  theme = "nord",
  hl_override = highlights.override,
  hl_add = highlights.add,
  extended_integrations = {
    "trouble",
    "notify",
  },

  statusline = {
    theme = "default",
    separator_style = "round",
  },
}

M.plugins = "custom.plugins"
M.mappings = require "custom.mappings"

return M
