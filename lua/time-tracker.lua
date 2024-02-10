local M = {}

local utils = require("utils")

function M.setup(opts)
  opts = opts or {}
  opts.allowed_inactivity = vim.F.if_nil(opts.allowed_inactivity, 60)
  M.opts = opts
  utils.opts = opts

  vim.api.nvim_create_autocmd({ "BufEnter", "VimLeave" }, {
    group = utils.augroup("update-time"),
    callback = function()
      utils.update_project_time()
    end,
  })

  vim.api.nvim_create_user_command("TimeTrackerStats",
    "lua require('time-tracker').update_project_time() require'time-tracker'.stat()", {})
end

M.update_project_time = utils.update_project_time
M.stat = utils.stat

return M
