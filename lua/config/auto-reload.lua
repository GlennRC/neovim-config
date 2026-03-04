-- Auto-reload: detect external file changes and refresh buffers
-- Layer 1: autoread + autocommands (catches buffer switches)
-- Layer 2: libuv fs_event watchers (real-time OS notifications)

vim.opt.autoread = true

local group = vim.api.nvim_create_augroup("auto-reload", { clear = true })

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  group = group,
  command = "silent! checktime",
})

-- Layer 2: libuv fs_event watchers per buffer
local watchers = {} -- bufnr → fs_event handle
local enabled = true
local debounce_ms = 200

local function watch_buffer(bufnr)
  if watchers[bufnr] then return end
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == "" or not vim.uv.fs_stat(path) then return end

  local handle = vim.uv.new_fs_event()
  if not handle then return end

  local debounce_timer = nil
  handle:start(path, {}, function(err)
    if err then return end
    if debounce_timer then return end
    debounce_timer = true
    vim.defer_fn(function()
      debounce_timer = nil
      if vim.api.nvim_buf_is_valid(bufnr) then
        vim.cmd("silent! checktime")
      end
    end, debounce_ms)
  end)
  watchers[bufnr] = handle
end

local function unwatch_buffer(bufnr)
  local handle = watchers[bufnr]
  if handle then
    handle:stop()
    handle:close()
    watchers[bufnr] = nil
  end
end

local function watch_all()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[bufnr].buflisted and vim.bo[bufnr].buftype == "" then
      watch_buffer(bufnr)
    end
  end
end

local function unwatch_all()
  for bufnr, _ in pairs(watchers) do
    unwatch_buffer(bufnr)
  end
end

vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  callback = function(ev)
    if enabled then watch_buffer(ev.buf) end
  end,
})

vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
  group = group,
  callback = function(ev)
    unwatch_buffer(ev.buf)
  end,
})

-- Watch existing buffers on load
watch_all()

vim.keymap.set("n", "<leader>tr", function()
  if enabled then
    unwatch_all()
    enabled = false
    vim.notify("Auto-reload: OFF", vim.log.levels.INFO)
  else
    enabled = true
    watch_all()
    vim.notify("Auto-reload: ON", vim.log.levels.INFO)
  end
end, { desc = "[T]oggle auto-[R]eload" })
