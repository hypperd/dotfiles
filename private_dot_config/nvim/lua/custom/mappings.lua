local M = {}

-- remove showing :noh
M.general = {
  n = {
    ["gx"] = { '<Cmd>call jobstart(["xdg-open", expand("<cfile>")], {"detach": v:true})<CR>', "" },
    ["<Esc>"] = { "<cmd> noh <CR>", "no highlight" },
  },
  t = {
    ["<Esc>"] = { "<C-\\><C-n>", "normal mode" },
  },
}

M.lspconfig = {
  n = {
    ["<leader>oi"] = {
      function()
        vim.lsp.buf.code_action { context = { only = { "source.organizeImports" } }, apply = true }
      end,
      "lsp organize imports",
    },
    ["<leader>wd"] = { "<cmd> TroubleToggle workspace_diagnostics <CR>", "workspace diagnostics" },
  },
}

M.flutter = {
  plugin = true,
  n = {
    ["<leader>fc"] = {
      function()
        require("telescope").extensions.flutter.commands()
      end,
      "flutter commands",
    },
    ["<leader>ft"] = { "<cmd> FlutterOutlineToggle <CR>", "flutter widget tree" },
  },
}

M.markdown = {
  n = {
    ["<leader>mp"] = {
      function()
        local peek = require "peek"
        if peek.is_open() then
          peek.close()
        else
          peek.open()
        end
      end,
      "toggle markdown previewer",
    },
    ["<leader>pi"] = {
      function()
        require("clipboard-image.paste").paste_img()
      end,
      "paste image in markdown",
    },
  },
}

M.telescope = {
  n = {
    ["<leader>ff"] = {
      function()
        if require("zk.util").notebook_root(vim.fn.getcwd()) ~= nil then
          require("zk.commands").get "ZkNotes"()
        else
          vim.cmd [[Telescope find_files]]
        end
      end,
      "Find files/notes",
    },
  },
}

M.zk = {
  n = {
    ["<leader>zn"] = {
      function()
        require("zk").new {
          dir = vim.fn.expand "%:p:h",
        }
      end,
      "create a new zk note",
    },
  },
}

M.tabufline = {
  n = {
    ["<leader>x"] = {
      function()
        require("custom.util").close_buffer()
      end,
      "close buffer",
    },
  },
}

M.dap = {
  plugin = true,
  n = {
    ["tb"] = {
      function()
        require("dap").toggle_breakpoint()
      end,
      "dap toggle breakpoint",
    },
    ["dK"] = {
      function()
        require("dapui").eval()
      end,
      "dap hover",
    },
    ["dc"] = {
      function()
        require("dap").continue {}
      end,
      "dap continue/start",
    },
    ["<leader>dU"] = {
      function()
        require("custom.configs.dap-ui").toggle_ui()
      end,
      "dap toggle ui",
    },
    ["<leader>dc"] = {
      function()
        require("custom.configs.dap-ui").toggle_console()
      end,
      "dap toggle console",
    },
    ["<leader>dr"] = {
      function()
        require("custom.configs.dap-ui").toggle_repl()
      end,
      "dap toggle repl",
    },
  },
}

M.nvterm = {
  plugin = false,
  n = {
    ["<A-i>"] = { "<cmd> 1ToggleTerm direction=float <CR>", "toggle floating term" },
    ["<A-h>"] = { "<cmd> 2ToggleTerm direction=horizontal <CR>", "toggle horizontal term" },
    ["<A-v>"] = { "<cmd> 3ToggleTerm direction=vertical <CR>", "toggle vertical term" },
  },
  t = {
    ["<A-i>"] = { "<cmd> 1ToggleTerm direction=float <CR>", "toggle floating term" },
    ["<A-h>"] = { "<cmd> 2ToggleTerm direction=horizontal <CR>", "toggle horizontal term" },
    ["<A-v>"] = { "<cmd> 3ToggleTerm direction=vertical <CR>", "toggle vertical term" },
  },
}

M.zen = {
  n = {
    ["<leader>zm"] = {"<cmd> ZenMode <Cr>", "Zen mode"}
  }
}

M.disabled = {
  n = {
    ["<leader>h"] = "",
    ["<leader>v"] = "",
  },
}

return M
