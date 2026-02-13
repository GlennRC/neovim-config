local M = {}

local function brain_path()
  return vim.env.BRAINCTL_BRAIN_PATH or "/ws/contrgle/brain"
end

local function open_scratch(title, lines)
  vim.cmd("vnew")
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = true
  vim.bo[buf].filetype = "markdown"
  vim.api.nvim_buf_set_name(buf, title)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
end

local function run(cmd, title)
  if vim.fn.executable(cmd[1]) ~= 1 then
    vim.notify("brainctl not found in PATH", vim.log.levels.ERROR)
    return
  end
  vim.system(cmd, { text = true }, function(obj)
    local out = (obj.stdout or "") .. (obj.stderr or "")
    local lines = vim.split(out, "\n", { plain = true })
    vim.schedule(function()
      open_scratch(title, lines)
    end)
  end)
end

function M.setup()
  local cmds = {
    BrainState   = { "brainctl", "brain", "state",   "--path", brain_path() },
    BrainHot     = { "brainctl", "brain", "hot",     "--path", brain_path() },
    BrainRecords = { "brainctl", "brain", "records", "--path", brain_path() },
    BrainSkills  = { "brainctl", "brain", "skills",  "--path", brain_path() },
    BrainDoctor  = { "brainctl", "brain", "doctor",  "--path", brain_path() },
  }
  for name, cmd in pairs(cmds) do
    vim.api.nvim_create_user_command(name, function()
      run(cmd, "brainctl://" .. name:lower():gsub("^brain", ""))
    end, {})
  end

  -- Commands that take an argument
  vim.api.nvim_create_user_command("BrainRead", function(opts)
    run({ "brainctl", "brain", "read", "--path", brain_path(), opts.args }, "brainctl://read/" .. opts.args)
  end, { nargs = 1 })

  vim.api.nvim_create_user_command("BrainSkill", function(opts)
    run({ "brainctl", "brain", "skill", "--path", brain_path(), opts.args }, "brainctl://skill/" .. opts.args)
  end, { nargs = 1 })

  vim.api.nvim_create_user_command("BrainOpen", function()
    vim.cmd("edit " .. vim.fn.fnameescape(brain_path() .. "/STATE.md"))
  end, {})
end

return M
