local jdtls = require "jdtls"
local data_dir = vim.fn.stdpath "data" .. "/mason/packages"

local function get_config_dir()
  local xdg_dir = os.getenv "XDG_CONFIG_HOME"

  if not xdg_dir then
    return os.getenv "HOME" .. "/.config/jdtls"
  end

  return xdg_dir .. "/jdtls"
end

local root_files = {
  -- Single-module  projects
  "build.xml", -- Ant
  "pom.xml", -- Maven
  "settings.gradle", -- Gradle
  "settings.gradle.kts", -- Gradle

  -- Multi-module projects
  "build.gradle",
  "build.gradle.kts",
}

-- extensions
local java_test = vim.fn.glob(data_dir .. "/java-test/extension/server/*.jar")
local java_debug = "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"

local bundles = { vim.fn.glob(data_dir .. java_debug) }
vim.list_extend(bundles, vim.fn.split(java_test, "\n"))

local config = {
  filetypes = { "java" },
  autostart = true,
  cmd = {
    "jdtls",
    "--jvm-arg=-javaagent:" .. data_dir .. "/jdtls/lombok.jar",
    "-pluginCustomization",
    get_config_dir() .. "/plugin_customization.ini",
  },
  root_dir = jdtls.setup.find_root(root_files),
  capabilities = require("plugins.configs.lspconfig").capabilities,
  on_attach = function(client, bufnr)
    require("plugins.configs.lspconfig").on_attach(client, bufnr)
    jdtls.setup.add_commands()
    jdtls.setup_dap { hotcodereplace = "auto" }
    require("jdtls.dap").setup_dap_main_class_configs()
  end,
  init_options = {
    bundles = bundles,
  },
  settings = {
    java = {
      rename = true,
      configuration = {
        runtimes = {
          {
            name = "JavaSE-1.8",
            path = "/usr/lib/jvm/java-8-openjdk",
          },
          {
            name = "JavaSE-17",
            path = "/usr/lib/jvm/java-17-openjdk",
          },
          {
            name = "JavaSE-11",
            path = "/usr/lib/jvm/java-11-openjdk",
          },
        },
      },
    },
  },
}

-- load only on java files
vim.api.nvim_create_autocmd("FileType", {
  pattern = table.concat(config.filetypes, ","),
  group = "lspconfig",
  callback = function()
    jdtls.start_or_attach(config)
  end,
})
