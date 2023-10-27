local overrides = require "custom.configs.overrides"
local markdown = require "custom.configs.markdown"

local M = {
  -- override plugin configuration
  { "nvim-telescope/telescope.nvim",       opts = overrides.telescope },
  { "williamboman/mason.nvim",             opts = overrides.mason },
  { "lukas-reineke/indent-blankline.nvim", opts = overrides.blankline() },
  { "NvChad/nvim-colorizer.lua",           opts = overrides.nvim_colorizer },
  { "hrsh7th/nvim-cmp",                    opts = overrides.nvim_cmp },
  { "L3MON4D3/LuaSnip",                    config = overrides.luasnip() },
  {
    "nvim-treesitter/nvim-treesitter",
    ft = { "man" },
    opts = overrides.treesitter,
  },
  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
    dependencies = {
      {
        "antosha417/nvim-lsp-file-operations",
        opts = {},
      },
    },
  },

  -- ui
  {
    "stevearc/stickybuf.nvim",
    event = { "VeryLazy" },
    opts = {
      get_auto_pin = function (bufnr)
        return require("stickybuf").should_auto_pin(bufnr)
      end
    },
  },
  {
    "stevearc/dressing.nvim",
    event = { "VeryLazy" },
    config = function()
      require "custom.configs.dressing"
    end,
  },

  -- eager loading
  { "famiu/bufdelete.nvim", lazy = false },
  {
    "goolord/alpha-nvim",
    lazy = false,
    config = function()
      require "custom.configs.alpha"
    end,
  },
  {
    "rcarriga/nvim-notify",
    lazy = false,
    config = function()
      dofile(vim.g.base46_cache .. "notify")

      notify = require "notify"

      notify.setup {
        fps = 0,
        max_width = 60,
        max_height = 250,
        render = "wrapped-compact",
        stages = "static",
      }

      vim.notify = notify
    end,
  },

  -- lsp stuff
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "folke/neodev.nvim",
        config = function()
          require("neodev").setup()
        end,
      },
      {
        "mfussenegger/nvim-jdtls",
        config = function()
          require "custom.configs.jdtls"
        end,
      },
      {
        "stevearc/conform.nvim",
        opts = {
          formatters_by_ft = {
            lua = { "stylelua" },
            sh = { "shfmt" },
          }
        },
      },
    },
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },

  -- dap stuff
  {
    "mfussenegger/nvim-dap",
    init = require("core.utils").lazy_load "nvim-dap",
    dependencies = {
      {
        "nvim-telescope/telescope-dap.nvim",
        config = function()
          require("telescope").load_extension "dap"
        end,
      },
      {
        "rcarriga/nvim-dap-ui",
        config = function()
          require "custom.configs.dap-ui"
        end,
      },
      {
        "mfussenegger/nvim-dap-python",
        config = function()
          require("dap-python").setup "/home/hypper/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
        end,
      },
    },
    config = function()
      require("core.utils").load_mappings "dap"
      require "custom.configs.dap"
    end,
  },

  -- misc things
  {
    "folke/trouble.nvim",
    cmd = { "Trouble", "TroubleToggle" },
    config = function()
      dofile(vim.g.base46_cache .. "trouble")
      require "custom.configs.trouble"
    end,
  },
  {
    "akinsho/toggleterm.nvim",
    cmd = "ToggleTerm",
    config = function()
      require "custom.configs.toggleterm"
    end,
  },

  -- disable plugins
  { "NvChad/nvterm",        enabled = false },

  -- markdown/note taking
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = require "custom.configs.zen",
  },
  {
    "postfen/clipboard-image.nvim",
    config = function()
      require("clipboard-image").setup(markdown.clipboard_image)
    end,
  },
  {
    "toppair/peek.nvim",
    build = "deno task --quiet build:fast",
    dependencies = {},
    config = function()
      require("peek").setup {
        app = { "firefox", "--new-window" },
      }
    end,
  },
  {
    "mickael-menu/zk-nvim",
    config = function()
      require "custom.configs.zk-nvim"
    end,
  },
}

return M
