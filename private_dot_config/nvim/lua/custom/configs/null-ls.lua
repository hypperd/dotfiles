local null_ls = require "null-ls"
local builtin = null_ls.builtins

local sources = {
  -- formaters
  -- builtin.formatting.deno_fmt,
  builtin.formatting.stylua,
  -- builtin.formatting.google_java_format

  -- diagnotics
  -- builtin.diagnostics.cspell

}

null_ls.setup {
  debug = true,
  sources = sources,
}
