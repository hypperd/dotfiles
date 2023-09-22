local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

require("telescope").load_extension "flutter"

local opts = {
  flutter_lookup_cmd = "asdf where flutter",
  lsp = {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      showTodos = true,
      completeFunctionCalls = true,
      enableSnippets = true,
    },
  },
  decorations = {
    statusline = {
      app_version = false,
      device = true,
    },
  },
  debugger = {
    enabled = true,
    run_via_dap = true, -- use dap instead of a plenary job to run flutter apps
    -- if empty dap will not stop on any exceptions, otherwise it will stop on those specified
    -- see |:help dap.set_exception_breakpoints()| for more info
    exception_breakpoints = {},
    register_configurations = function(paths)
      local config = {
        type = "dart",
        request = "launch",
        name = "Launch flutter",
        dartSdkPath = paths.dart_sdk,
        flutterSdkPath = paths.flutter_sdk,
        program = "${workspaceFolder}/lib/main.dart",
        cwd = "${workspaceFolder}",
      }

      local env_file = vim.fn.getcwd() .. "/flutter_env.json"

      if io.open(env_file, "r") then
        local aux = {
          toolArgs = {
            "--dart-define-from-file",
            env_file,
          },
        }
        config = vim.tbl_deep_extend("force", config, aux)
      end

      require("dap").configurations.dart = { config }
    end,
  },
  dev_log = {
    enabled = false,
  },
}

require("flutter-tools").setup(opts)
