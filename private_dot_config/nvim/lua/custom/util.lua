local M = {}
local api = vim.api
local tabufline = require "nvchad.tabufline"

-- override default close function to use Bufdelete
M.close_buffer = function(bufnr)
  if vim.bo.buftype == "terminal" then
    vim.cmd(vim.bo.buflisted and "set nobl | enew" or "hide")
  else
    if not vim.t.bufs then
      vim.cmd "Bdelete"
      return
    end

    bufnr = bufnr or api.nvim_get_current_buf()
    local curBufIndex = tabufline.getBufIndex(bufnr)
    local bufhidden = vim.bo.bufhidden
    local filetype = vim.bo.filetype

    -- force close floating wins
    if bufhidden == "wipe" then
      if filetype ~= "alpha" then
        vim.cmd "Bwipeout"
      end
      return

      -- handle listed bufs
    elseif curBufIndex and #vim.t.bufs > 1 then
      local newBufIndex = curBufIndex == #vim.t.bufs and -1 or 1
      vim.cmd("b" .. vim.t.bufs[curBufIndex + newBufIndex])

      -- handle unlisted
    elseif not vim.bo.buflisted then
      local tmpbufnr = vim.t.bufs[1]

      if vim.g.nv_previous_buf and vim.api.nvim_buf_is_valid(vim.g.nv_previous_buf) then
        tmpbufnr = vim.g.nv_previous_buf
      end

      if tmpbufnr then
        vim.cmd("b" .. tmpbufnr .. " | Bwipeout" .. bufnr)
      else
        vim.cmd("Bwipeout")
      end
      return
    else
      vim.cmd "enew"
    end

    if not (bufhidden == "delete") then
      vim.cmd("confirm Bdelete" .. bufnr)
    end
  end

  vim.cmd "redrawtabline"
end

return M
