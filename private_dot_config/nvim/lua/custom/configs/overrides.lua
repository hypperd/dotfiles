local M = {}

M.nvimtree = {
  renderer = {
    group_empty = true,
    highlight_git = true,
  },
  diagnostics = {
    enable = true,
  },
  git = {
    enable = true,
    ignore = false,
  },
  view = {
    adaptive_size = true,
  },
}

M.treesitter = {
  ensure_installed = {
    "lua",
    "java",
    "python",
    "bash",
    "markdown",
    "json",
    "jsonc",
    "yaml",
    "dockerfile",
    "ini",
    "javascript",
    "typescript",
    "css",
    "html",
    "dart",
    "rasi",
  },
}

M.mason = {
  ensure_installed = {
    -- lsps
    "lua-language-server",
    "bash-language-server",
    "jdtls", -- java
    "lemminx", -- xml
    "json-lsp",
    "css-lsp",
    "html-lsp",
    "typescript-language-server",
    "yaml-language-server",
    "marksman",

    -- linters
    "shellcheck",
    "stylua",
    "cspell",

    -- debug
    "java-test",
    "java-debug-adapter",
  },
}

M.telescope = {
  defaults = {
    mappings = {
      i = {
        ["<C-k>"] = require("telescope.actions").preview_scrolling_up,
        ["<C-j>"] = require("telescope.actions").preview_scrolling_down,
      },
    },
  },
}

M.blankline = function()
  local config = require("plugins.configs.others").blankline
  table.insert(config.filetype_exclude, "alpha")
  return config
end

M.nvim_colorizer = {
  filetypes = { "css", "html", "scss" },
  user_default_options = {
    names = false,
  },
}
local cmp = require "cmp"

M.nvim_cmp = {
  mapping = {
    ["<C-k>"] = cmp.mapping.scroll_docs(-4),
    ["<C-j>"] = cmp.mapping.scroll_docs(4),
  },
}

M.luasnip = function()
  require("plugins.configs.others").luasnip()
  require("luasnip").filetype_extend("dart", { "flutter" })
end

return M
