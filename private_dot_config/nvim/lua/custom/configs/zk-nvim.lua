local zk = require("zk")
local commands = require("zk.commands")

local config = {
  picker = "telescope",
}

zk.setup(config)

commands.add("ZkOrphans", function(options)
  options = vim.tbl_extend("force", { orphan = true }, options or {})
  zk.edit(options, { title = "Zk Orphans" })
end)
