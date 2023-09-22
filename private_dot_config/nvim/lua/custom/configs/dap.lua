local dap = require "dap"

dap.defaults.fallback.external_terminal = {
  command = "/usr/bin/kitty",
  args = { "-e" },
}

-- dap signs
local icons = {
  DapBreakpoint = {
    text = "",
    texthl = "DiagnosticSignError",
  },
  DapBreakpointRejected = {
    text = "",
    texthl = "DiagnosticSignError",
  },
  DapStopped = {
    text = "",
    texthl = "DiagnosticSignWarn",
    linehl = "Visual",
    numhl = "DiagnosticSignWarn",
  },
}

for key, value in pairs(icons) do
  vim.fn.sign_define(key, value)
end

-- configs
dap.adapters.firefox = {
  type = "executable",
  command = "firefox-debug-adapter",
}

-- local script = {
--   "typescriptreact",
--   "typescript",
--   "javascript",
--   "javascriptreact"
-- }

dap.configurations.typescriptreact = {
  {
    name = "Debug with Firefox",
    type = "firefox",
    request = "launch",
    reAttach = true,
    url = "http://localhost:3000",
    webRoot = "${workspaceFolder}",
    firefoxExecutable = "/usr/bin/firefox",
  },
}

-- dap.adapters.dart = {
--   type = "executable",
--   command = "dart-debug-adapter",
-- }

require("dap.ext.vscode").load_launchjs()
