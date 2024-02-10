local M = {}

local time_file_path = vim.fn.stdpath('data') .. '/time-tracker.json'

function M.augroup(name)
  return vim.api.nvim_create_augroup("time-tracker:" .. name, { clear = true })
end

--- @return table
function M.load_data()
  local file = io.open(time_file_path, "r")
  if file == nil then
    return {}
  end

  local content = file:read("*a")
  file:close()

  local time_data = vim.fn.json_decode(content)
  if time_data == nil then
    return {}
  end

  return time_data
end

function M.update_project_time()
  local project_path = vim.fn.getcwd()

  local data = M.load_data()
  if data[project_path] == nil then
    data[project_path] = { start_time = os.time(), time = 0 }
  end

  local current_time = os.time()
  local start_time = data[project_path].start_time
  local diff = current_time - start_time

  if diff <= M.opts.allowed_inactivity then
    data[project_path].time = data[project_path].time + diff
  end

  data[project_path].start_time = current_time

  local file = io.open(time_file_path, "w")
  file:write(vim.fn.json_encode(data))
  file:close()
end

function M.stat()
  local file = io.open(time_file_path, "r")
  if file == nil then
    vim.notify("No time tracking data found", vim.log.levels.INFO, {
      title = "Time Tracker",
    })
    return
  end
  local content = file:read("*a")
  file:close()
  vim.notify(content, vim.log.levels.INFO, {
    title = "Time Tracker",
  })
end

return M
