-- copilot-send: Send visual selections to copilot-cli with file context
local M = {}

local state = {
  buf = nil,
  chan = nil,
  win = nil,
  cwd = nil,
  append_mode = false,
  tmux_pane = nil, -- cached target pane ID
}

--- Get the visual selection text and metadata
local function get_selection()
  -- Use current visual marks directly from the '< and '> positions
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")

  -- If marks are not set (both 0), no previous visual selection
  if start_line == 0 or end_line == 0 then
    vim.notify("No selection (marks not set)", vim.log.levels.WARN)
    return nil
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  if #lines == 0 then
    vim.notify("No selection (empty)", vim.log.levels.WARN)
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

  -- Hint if context file exists for external copilot sessions
  local ctx_file = task_root .. "/" .. CONTEXT_FILE
  if vim.fn.filereadable(ctx_file) == 1 then
    vim.notify("📎 " .. CONTEXT_FILE .. " available for @-reference", vim.log.levels.INFO)
  end

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
  local min_startup = 3000 -- minimum wait before checking (let brainctl init finish)

  local function check()
    if elapsed >= timeout then
      vim.notify("Copilot may not be ready, sending anyway", vim.log.levels.WARN)
      send_to_terminal(text)
      return
    end

    if not terminal_alive() then return end

    elapsed = elapsed + interval

    -- Don't check until minimum startup time has passed
    if elapsed < min_startup then
      vim.defer_fn(check, interval)
      return
    end

    -- Check last non-empty line for copilot prompt ("> " at start of line)
    local lines = vim.api.nvim_buf_get_lines(state.buf, 0, -1, false)
    local last_line = ""
    for i = #lines, 1, -1 do
      local l = lines[i]:gsub("%s+$", "")
      if l ~= "" then
        last_line = l
        break
      end
    end
    if last_line:match("^%s*>%s*$") or last_line:match("^❯") then
      send_to_terminal(text)
      return
    end

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

local CONTEXT_FILE = ".nvim-context.md"

--- Check if running inside tmux
local function in_tmux()
  return vim.env.TMUX ~= nil and vim.env.TMUX ~= ""
end

--- Find a tmux pane running copilot CLI, preferring one in the task root
local function find_copilot_pane(task_root)
  if state.tmux_pane then return state.tmux_pane end
  local result = vim.fn.systemlist("tmux list-panes -a -F '#{pane_id} #{pane_current_path} #{pane_current_command}' 2>/dev/null")
  local candidates = {}
  for _, line in ipairs(result) do
    local pane_id, pane_path, cmd = line:match("^(%S+)%s+(%S+)%s+(.+)$")
    if cmd and (cmd:match("ghcs") or cmd:match("copilot") or cmd:match("node")) then
      table.insert(candidates, { id = pane_id, path = pane_path, cmd = cmd })
    end
  end
  if #candidates == 0 then return nil end
  -- Prefer pane whose cwd matches the task root
  if task_root then
    for _, c in ipairs(candidates) do
      if c.path and c.path:find(task_root, 1, true) then
        return c.id
      end
    end
  end
  -- If no path match, prefer ghcs/copilot over generic node
  for _, c in ipairs(candidates) do
    if c.cmd:match("ghcs") or c.cmd:match("copilot") then
      return c.id
    end
  end
  return candidates[1].id
end

--- Send text to a tmux pane via load-buffer + paste-buffer.
--- If send_enter is true, follows up with a real Enter keypress.
local function tmux_send(text, target, task_root, send_enter)
  if not in_tmux() then
    vim.notify("Not in a tmux session", vim.log.levels.ERROR)
    return false
  end
  target = target or find_copilot_pane(task_root) or "!"
  local tmpfile = os.tmpname()
  local f = io.open(tmpfile, "w")
  if not f then
    vim.notify("Failed to create temp file", vim.log.levels.ERROR)
    return false
  end
  f:write(text)
  f:close()
  local escaped_tmp = vim.fn.shellescape(tmpfile)
  local escaped_target = vim.fn.shellescape(target)
  vim.fn.system(string.format("tmux load-buffer %s", escaped_tmp))
  vim.fn.system(string.format("tmux paste-buffer -t %s", escaped_target))
  vim.fn.system(string.format("rm -f %s", escaped_tmp))
  if send_enter then
    vim.fn.system(string.format("tmux send-keys -t %s C-s", escaped_target))
  end
  if vim.v.shell_error ~= 0 then
    vim.notify("tmux send failed (target: " .. target .. ")", vim.log.levels.ERROR)
    return false
  end
  return true
end

--- Send visual selection to a tmux pane running copilot CLI
function M.send_to_tmux()
  local sel = get_selection()
  if not sel then return end
  local task_root = detect_task_root(sel.file)
  local context = format_context(sel, task_root)
  if tmux_send(context .. "\n", nil, task_root) then
    vim.notify("Sent to tmux pane", vim.log.levels.INFO)
  end
end

--- Send visual selection + prompt to a tmux pane, then press Enter.
--- Writes code context to .nvim-context.md, sends only the prompt as a single line.
function M.send_to_tmux_prompted()
  local sel = get_selection()
  if not sel then
    vim.notify("No selection", vim.log.levels.WARN)
    return
  end
  local task_root = detect_task_root(sel.file)

  vim.ui.input({ prompt = "Prompt for Copilot: " }, function(prompt)
    if not prompt or prompt == "" then
      vim.notify("Cancelled (no prompt)", vim.log.levels.INFO)
      return
    end

    -- Write code context to file so copilot can read it
    local rel_file = make_relative(sel.file, task_root)
    local context_parts = {}
    table.insert(context_parts, string.format("File: %s (lines %d-%d)", rel_file, sel.start_line, sel.end_line))
    table.insert(context_parts, "```" .. sel.ft)
    for _, line in ipairs(sel.lines) do
      table.insert(context_parts, line)
    end
    table.insert(context_parts, "```")
    local filepath = task_root .. "/" .. CONTEXT_FILE
    local f = io.open(filepath, "w")
    if f then
      f:write("<!-- This file contains code highlighted by the user in neovim for you to investigate. Do NOT delete or ignore this file. Treat each block as code the user is asking about. -->\n\n")
      f:write(table.concat(context_parts, "\n") .. "\n")
      f:close()
    end

    -- Find target pane
    local target = find_copilot_pane(task_root) or "!"
    vim.notify("Target pane: " .. target .. " | task: " .. task_root, vim.log.levels.INFO)

    -- Send just the prompt as single-line text + Enter via send-keys
    local escaped_target = vim.fn.shellescape(target)
    local escaped_prompt = vim.fn.shellescape(prompt)
    local cmd1 = string.format("tmux send-keys -t %s -l %s", escaped_target, escaped_prompt)
    local cmd2 = string.format("tmux send-keys -t %s Enter", escaped_target)
    local out1 = vim.fn.system(cmd1)
    local err1 = vim.v.shell_error
    local out2 = vim.fn.system(cmd2)
    local err2 = vim.v.shell_error
    if err1 ~= 0 or err2 ~= 0 then
      vim.notify(string.format("tmux failed: cmd1=%d cmd2=%d | %s | %s", err1, err2, out1, out2), vim.log.levels.ERROR)
    else
      vim.notify("Sent: " .. prompt, vim.log.levels.INFO)
    end
  end)
end

--- Send pre-captured selection to tmux copilot pane and switch focus there.
function M._send_to_copilot(lines, start_line, end_line, file, ft)
  if file == "" then file = "[unsaved]" end
  local task_root = detect_task_root(file)

  -- Build code context block
  local rel_file = make_relative(file, task_root)
  local parts = {}
  table.insert(parts, string.format("File: %s (lines %d-%d)", rel_file, start_line, end_line))
  table.insert(parts, "```" .. ft)
  for _, line in ipairs(lines) do
    table.insert(parts, line)
  end
  table.insert(parts, "```")
  local text = table.concat(parts, "\n")

  -- Paste into tmux copilot pane
  local target = find_copilot_pane(task_root) or "!"
  if not tmux_send(text, target, task_root) then return end

  -- Switch focus to the copilot pane so user can type their prompt
  local escaped_target = vim.fn.shellescape(target)
  vim.fn.system(string.format("tmux select-pane -t %s", escaped_target))

  vim.notify("Sent → " .. target, vim.log.levels.INFO)
end

--- Set tmux target pane manually
function M.set_tmux_pane(pane_id)
  state.tmux_pane = pane_id
  vim.notify("tmux target: " .. (pane_id or "auto"), vim.log.levels.INFO)
end

--- Reset tmux target pane to auto-detect
function M.reset_tmux_pane()
  state.tmux_pane = nil
  vim.notify("tmux target: auto-detect", vim.log.levels.INFO)
end

--- Write visual selection to .nvim-context.md in task root
function M.export_context()
  local sel = get_selection()
  if not sel then return end

  local task_root = detect_task_root(sel.file)
  local context = format_context(sel, task_root)
  local filepath = task_root .. "/" .. CONTEXT_FILE

  local mode = state.append_mode and "a" or "w"
  local f = io.open(filepath, mode)
  if not f then
    vim.notify("Failed to write " .. filepath, vim.log.levels.ERROR)
    return
  end

  if state.append_mode then
    f:write("\n---\n\n")
  else
    f:write("<!-- This file contains code highlighted by the user in neovim for you to investigate. Do NOT delete or ignore this file. Treat each block as code the user is asking about. -->\n\n")
  end
  f:write(context .. "\n")
  f:close()

  local label = state.append_mode and "appended" or "written"
  vim.notify("Context " .. label .. " → " .. CONTEXT_FILE, vim.log.levels.INFO)
end

--- Clear the context file
function M.clear_context()
  local task_root = detect_task_root(vim.fn.expand("%:p"))
  local filepath = task_root .. "/" .. CONTEXT_FILE

  if vim.fn.filereadable(filepath) == 1 then
    os.remove(filepath)
    vim.notify(CONTEXT_FILE .. " cleared", vim.log.levels.INFO)
  else
    vim.notify(CONTEXT_FILE .. " not found", vim.log.levels.WARN)
  end
end

--- Toggle append mode
function M.toggle_append()
  state.append_mode = not state.append_mode
  local mode = state.append_mode and "append" or "overwrite"
  vim.notify("Context export: " .. mode .. " mode", vim.log.levels.INFO)
end

return M
