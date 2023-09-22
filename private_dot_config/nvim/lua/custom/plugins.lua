local overrides = require "custom.configs.overrides"
local markdown = require "custom.configs.markdown"

local M = {
  -- oerrde plugin configs
  { "nvim-telescope/telescope.nvim", opts = overrides.telescope },
  { "nvim-treesitter/nvim-treesitter", opts = overrides.treesitter },
  { "williamboman/mason.nvim", opts = overrides.mason },
  { "nvim-tree/nvim-tree.lua", opts = overrides.nvimtree },
  { "lukas-reineke/indent-blankline.nvim", opts = overrides.blankline() },
  { "NvChad/nvim-colorizer.lua", opts = overrides.nvim_colorizer },
  { "hrsh7th/nvim-cmp", opts = overrides.nvim_cmp },
  { "L3MON4D3/LuaSnip", config = overrides.luasnip() },
  {
    "NvChad/ui",
    branch = "v2.0",
    lazy = false,
    config = function()
      -- vim.api.nvim_del_user_command("Nvdash")
    end,
  },

  -- eager loading
  {
    "goolord/alpha-nvim",
    lazy = false,
    config = function()
      require "custom.configs.alpha"
    end,
  },
  {
    "stevearc/dressing.nvim",
    lazy = false,
    config = function()
      require "custom.configs.dressing"
    end,
  },
  { "elkowar/yuck.vim", lazy = false },
  { "famiu/bufdelete.nvim", lazy = false },

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
        dependencies = {
          "tobias-z/java-util.nvim",
          config = function()
            require("java_util").setup {}
          end,
        },
      },
      {
        "akinsho/flutter-tools.nvim",
        config = function()
          require("core.utils").load_mappings "flutter"
          require "custom.configs.flutter"
        end,
      },
      {
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
          require "custom.configs.null-ls"
        end,
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
  { "NvChad/nvterm", enabled = false },

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
        app = {"firefox", "--new-window"},
      }
    end,
  },
  {
    "mickael-menu/zk-nvim",
    config = function()
      require "custom.configs.zk-nvim"
    end,
  },
  {
    "ThePrimeagen/vim-be-good",
    lazy = false,
  },
}

return M
