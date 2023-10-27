local present, alpha = pcall(require, "alpha")

if not present then
  return
end

local api = vim.api
local fn = vim.fn

local function button(sc, txt)
  local sc_ = sc:gsub("%s", ""):gsub("SPC", "<leader>")

  local opts = {
    position = "center",
    text = txt,
    shortcut = sc,
    cursor = 5,
    width = 36,
    align_shortcut = "right",
    hl = "AlphaButtons",
  }

  return {
    type = "button",
    val = txt,
    on_press = function()
      local key = vim.api.nvim_replace_termcodes(sc_, true, false, true) or ""
      vim.api.nvim_feedkeys(key, "normal", false)
    end,
    opts = opts,
  }
end

local function info_text()
  local datetime = os.date " %Y-%m-%d"
  local total_plugins = " 󰂖 " .. require("lazy").stats().count .. " plugins"
  local version = vim.version()
  local nvim_version_info = ""

  if version ~= nil then
    local value = { version.major, version.minor, version.patch }
    nvim_version_info = "  " .. table.concat(value, ".")
  end

  return datetime .. total_plugins .. nvim_version_info
end

local function body_height(layout)
  local total = 0
  for _, value in pairs(layout) do
    if value.type == "padding" then
      total = total + value.val
    else
      if type(value.val) == "string" then
        total = total + 1
      else
        total = total + #value.val
        if value.opts ~= nil and value.opts.spacing ~= nil then
          total = total + (#value.val - 1) * value.opts.spacing
        end
      end
    end
  end

  return total
end

local options = {
  header = {
    type = "text",
    val = {
      [[　　　 　　/＾>》, -―‐‐＜＾}]],
      [[　　　 　./:::/,≠´::::::ヽ.]],
      [[　　　　/::::〃::::／}::丿ハ]],
      [[　　　./:::::i{l|／　ﾉ／ }::}]],
      [[　　 /:::::::瓜イ＞　´＜ ,:ﾉ]],
      [[　 ./::::::|ﾉﾍ.{､　(_ﾌ_ノﾉイ＿]],
      [[　 |:::::::|／}｀ｽ /          /]],
      [[ 　|::::::|(_:::つ/ ThinkPad /]],
      [[ ￣￣￣￣￣￣￣＼/＿＿＿＿＿/￣￣￣￣￣]],
    },
    opts = {
      position = "center",
      hl = "AlphaHeader",
    },
  },
  buttons = {
    type = "group",
    val = {
      button("SPC f f", "  Find File"),
      button("SPC f o", "󰈙  Recent File"),
      button("SPC f w", "󰈭  Find Word"),
      button("SPC m a", "  Bookmarks"),
      button("SPC t h", "  Themes"),
      button("SPC c h", "  Mappings"),
    },
    opts = {
      spacing = 1,
    },
  },
  section_info = {
    type = "text",
    val = info_text(),
    opts = {
      hl = "AlphaSubtitle",
      position = "center",
    },
  },
}

local layout = {
  options.headerPaddingTop,
  options.header,
  { type = "padding", val = 1 },
  options.section_info,
  { type = "padding", val = 1 },
  options.buttons,
}

-- dynamic header padding
local topPadding = fn.max { 1, fn.floor((fn.winheight(0) - body_height(layout)) / 2) }
table.insert(layout, 1, { type = "padding", val = topPadding })

alpha.setup {
  layout = layout,
}

-- open on empty buffer
api.nvim_create_augroup("alpha_on_empty", { clear = true })
api.nvim_create_autocmd("User", {
  pattern = "BDeletePost*",
  group = "alpha_on_empty",
  callback = function(event)
    local fallback_name = api.nvim_buf_get_name(event.buf)
    local fallback_ft = api.nvim_buf_get_option(event.buf, "filetype")
    local fallback_on_empty = fallback_name == "" and fallback_ft == ""

    if fallback_on_empty then
      vim.cmd "Alpha"
      vim.cmd(event.buf .. "bdelete")
    end
  end,
})
