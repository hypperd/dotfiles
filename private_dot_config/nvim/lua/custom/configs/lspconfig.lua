local lspconfig = require "lspconfig"
local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local servers = {
  "html",-- bun?
  "cssls",-- bun?
  "yamlls",-- bun?
  "tsserver",-- bun?
  "jsonls",-- bun?
  "marksman",
  -- "pylsp",
  "jedi_language_server",
  "rust_analyzer",
  "clangd",
  "bashls" -- bun?
}

-- standard config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

lspconfig.yamlls.setup {
  settings = {
    yaml = {
      schemaStore = {
        enable = true,
      },
    },
  },
}

-- custom config
lspconfig.lemminx.setup {
  on_attach = on_attach,
  settings = {
    xml = {
      catalogs = { "/etc/xml/catalog" },
      server = {
        workDir = vim.fn.stdpath "cache" .. "/lemminx",
      },
    },
  },
}

local project_library_path = vim.fn.getcwd()

local cmd = {
  "ngserver",
  "--stdio",
  "--tsProbeLocations",
  project_library_path,
  "--ngProbeLocations",
  project_library_path,
}

lspconfig.angularls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = cmd,
  on_new_config = function(new_config, new_root_dir)
    new_config.cmd = cmd
  end,
}
