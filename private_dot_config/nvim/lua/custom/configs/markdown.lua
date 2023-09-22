local M = {}

M.clipboard_image = {
  default = {
    img_dir = "attachments",
    img_dir_txt = "attachments",
    img_name = function()
      return os.date "%Y-%m-%d-%H-%M-%S"
    end,
  },
}

return M
