local M = {}

M.override = {
  Comment = {
    italic = true,
  },
}

M.add = {
  -- alpha-nvim
  AlphaHeader = { fg = "green", bold = true },
  AlphaButtons = { fg = "light_grey" },
  AlphaSubtitle = { fg = "purple" },
  -- nvim-dap-ui
  DapUIVariable = { fg = "white" },
  DapUIScope = { link = "Title" },
  DapUIType = { link = "Type" },
  DapUIValue = { fg = "red" },
  DapUIModifiedValue = { fg = "sun", bold = true },
  DapUIDecoration = { fg = "grey_fg" },
  DapUIThread = { link = "String" },
  DapUIStoppedThread = { link = "Title" },
  DapUIFrameName = { link = "Normal" },
  DapUISource = { link = "Keyword" },
  DapUILineNumber = { link = "LineNr" },
  DapUIFloatBorder = { link = "FloatBorder" },
  DapUIWatchesEmpty = { fg = "pink" },
  DapUIWatchesValue = { fg = "orange" },
  DapUIWatchesError = { fg = "pink" },
  DapUIBreakpointsPath = { link = "Title" },
  DapUIBreakpointsInfo = { fg = "light_grey" },
  DapUIBreakpointsCurrentLine = { fg = "sun", bold = true },
  DapUIBreakpointsLine = { link = "DapUILineNumber" },
  DapUIBreakpointsDisabledLine = { link = "Comment" },
  DapUIPlayPause = { fg = "green" },
  DapUIStop = { fg = "red" },
  DapUIRestart = { fg = "yellow" },
  DapUIStepOver = { fg = "blue" },
  DapUIStepInto = { fg = "blue" },
  DapUIStepBack = { fg = "blue" },
  DapUIStepOut = { fg = "blue" },
}

return M
