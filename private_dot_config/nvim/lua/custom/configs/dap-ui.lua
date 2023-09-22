local dap, dapui = require "dap", require "dapui"
local windows = require "dapui.windows"
local tree_api = require "nvim-tree.api"

local M = {}

local opts = {
  icons = { expanded = "", collapsed = "", current_frame = "" },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = { "<CR>", "<2-LeftMouse>" },
    open = "o",
    remove = "d",
    edit = "e",
    repl = "r",
    toggle = "t",
  },
  -- Use this to override mappings for specific elements
  element_mappings = {
    -- Example:
    -- stacks = {
    --   open = "<CR>",
    --   expand = "o",
    -- }
  },
  force_buffers = false,
  -- Expand lines larger than the window
  -- Requires >= 0.7
  expand_lines = vim.fn.has "nvim-0.7" == 1,
  -- Layouts define sections of the screen to place windows.
  -- The position can be "left", "right", "top" or "bottom".
  -- The size specifies the height/width depending on position. It can be an Int
  -- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
  -- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
  -- Elements are the elements shown in the layout (in order).
  -- Layouts are opened in order so that earlier layouts take priority in window sizing.
  layouts = {
    {
      elements = {
        "scopes",
        "breakpoints",
        "stacks",
      },
      size = 40,
      position = "left",
    },
    {
      elements = {
        "repl",
      },
      size = 0.25, -- 25% of total lines
      position = "bottom",
    },
  },
  controls = {
    -- Requires Neovim nightly (or 0.8 when released)
    enabled = true,
    -- Display controls in this element
    element = "repl",
    icons = {
      pause = "",
      play = "",
      step_into = "",
      step_over = "",
      step_out = "",
      step_back = "",
      run_last = "",
      terminate = "",
    },
  },
  floating = {
    max_height = nil, -- These can be integers or a float between 0 and 1.
    max_width = nil, -- Floats will be treated as percentage of your screen.
    border = "single", -- Border style. Can be "single", "double" or "rounded"
    enter = false,
    mappings = {
      close = { "q", "<Esc>" },
    },
  },
  windows = { indent = 1 },
  render = {
    max_type_length = nil, -- Can be integer or nil.
    max_value_lines = 100, -- Can be integer or nil.
  },
}

dapui.setup(opts)

-- close on nvim tree open
local Event = tree_api.events.Event
tree_api.events.subscribe(Event.TreeOpen, function()
  if windows.layouts[1]:is_open() then
    dapui.close { reset = true }
  end
end)

-- open dap console on dap start
dap.listeners.after.event_initialized["dapui_config"] = function()
  M.toggle_console()
end

M.toggle_ui = function()
  local layout = 1
  if windows.layouts[layout]:is_open() then
    dapui.close { layout = layout, reset = true }
  else
    tree_api.tree.close()
    dapui.open { layout = layout, reset = true }
  end
end

M.toggle_repl = function()
  local layout = 2
  if windows.layouts[layout]:is_open() then
    dapui.close { layout = layout, reset = true }
  else
    dapui.open { layout = layout, reset = true }
  end
end

M.toggle_console = function()
  dapui.float_element("console", {
    width = math.ceil(0.7 * vim.o.columns),
    height = math.ceil(0.6 * vim.o.lines),
    position = "center",
  })
end

return M
