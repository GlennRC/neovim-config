-- copilot-send: Send visual selections to copilot-cli with file context
local M = {}

local state = {
  buf = nil,
  chan = nil,
  win = nil,
  cwd = nil,
}

--- Get the visual selection text and metadata
local function get_selection()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)

  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  if #lines == 0 then
    vim.notify("No selection", vim.log.levels.WARN)
    return nil
  end

  local file = vim.fn.expand("%:p")
  if file == "" then file = "[unsaved]" end

  return {
    lines = lines,
    start_line = start_line,
    end_line = end_line,
    file = file,
    ft = vim.bo.filetype or "",
  }
end

--- Detect the task root from a file path.
--- Matches /tasks/<name> and returns everything up to it.
--- Falls back to cwd if no task pattern found.
local function detect_task_root(filepath)
  local task_root = filepath:match("(.*/tasks/[^/]+)")
  if task_root then return task_root end
  return vim.fn.getcwd()
end

--- Make file path relative to a directory
local function make_relative(filepath, base)
  if filepath:sub(1, #base) == base then
    local rel = filepath:sub(#base + 1)
    if rel:sub(1, 1) == "/" then rel = rel:sub(2) end
    if rel ~= "" then return rel end
  end
  return filepath
end

--- Format selection as a context block
local function format_context(sel, task_root, question)
  local rel_file = make_relative(sel.file, task_root)
  local parts = {}
  table.insert(parts, string.format("File: %s (lines %d-%d)", rel_file, sel.start_line, sel.end_line))
  table.insert(parts, "```" .. sel.ft)
  for _, line in ipairs(sel.lines) do
    table.insert(parts, line)
  end
  table.insert(parts, "```")
  if question and question ~= "" then
    table.insert(parts, "")
    table.insert(parts, question)
  end
  return table.concat(parts, "\n")
end

local function terminal_alive()
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) and state.chan then
    local ok, _ = pcall(vim.fn.jobpid, state.chan)
    return ok
  end
  return false
end

--- Open or focus the copilot terminal split.
--- If the task root changed, close the old terminal and open a new one.
local function open_terminal(task_root)
  if terminal_alive() then
    if state.cwd ~= task_root then
      vim.fn.jobstop(state.chan)
      if state.win and vim.api.nvim_win_is_valid(state.win) then
        vim.api.nvim_win_close(state.win, true)
      end
    else
      if not state.win or not vim.api.nvim_win_is_valid(state.win) then
        vim.cmd("vertical botright sbuffer " .. state.buf)
        state.win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_width(state.win, 80)
      end
      vim.cmd("wincmd p")
      return true
    end
  end

  vim.cmd("vertical botright new")
  state.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_width(state.win, 80)
  state.buf = vim.api.nvim_get_current_buf()
  state.cwd = task_root

  local shell_cmd = "cd " .. vim.fn.shellescape(task_root) .. " && /users/contrgle/.config/nvim/scripts/copi-wrapper.sh"
  state.chan = vim.fn.termopen({ "bash", "-c", shell_cmd }, {
    on_exit = function()
      state.buf = nil
      state.chan = nil
      state.win = nil
      state.cwd = nil
    end,
  })
  vim.cmd("wincmd p")
  return false
end

local function send_to_terminal(text)
  if not terminal_alive() then
    vim.notify("Copilot terminal not running", vim.log.levels.ERROR)
    return
  end
  vim.fn.chansend(state.chan, text .. "\n")
end

--- Poll terminal buffer for copilot ready prompt, then send context
local function send_when_ready(text, timeout)
  local elapsed = 0
  local interval = 500

  local function check()
    if elapsed >= timeout then
      vim.notify("Copilot may not be ready, sending anyway", vim.log.levels.WARN)
      send_to_terminal(text)
      return
    end

    if not terminal_alive() then return end

    local lines = vim.api.nvim_buf_get_lines(state.buf, 0, -1, false)
    local content = table.concat(lines, "\n")
    if content:find(">") or content:find("╭") then
      send_to_terminal(text)
      return
    end

    elapsed = elapsed + interval
    vim.defer_fn(check, interval)
  end

  vim.defer_fn(check, interval)
end

--- Send visual selection to copilot interactive terminal
function M.send_interactive()
  local sel = get_selection()
  if not sel then return end

  local task_root = detect_task_root(sel.file)
  local context = format_context(sel, task_root)
  local existing = open_terminal(task_root)

  if existing then
    send_to_terminal(context)
  else
    send_when_ready(context, 15000)
  end
end

--- Quick ask: prompt for question, run ghcs-brain -p non-interactively
function M.quick_ask()
  local sel = get_selection()
  if not sel then return end

  local task_root = detect_task_root(sel.file)

  vim.ui.input({ prompt = "Ask Copilot: " }, function(question)
    if not question or question == "" then return end

    local context = format_context(sel, task_root, question)
    local escaped = context:gsub("'", "'\\''")
    local shell_cmd = "cd " .. vim.fn.shellescape(task_root) .. " && /users/contrgle/.config/nvim/scripts/copi-wrapper.sh -p '" .. escaped .. "' --quiet"

    vim.cmd("vertical botright new")
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_width(win, 80)
    vim.fn.termopen({ "bash", "-c", shell_cmd })
    vim.cmd("wincmd p")
  end)
end

return M
