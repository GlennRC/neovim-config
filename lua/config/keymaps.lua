-- Split navigation (ISRT: n=left, e=up, a=down, o=right) — mirrors tmux pane nav
-- Note: overrides <C-o> (jumplist back) and <C-a> (increment number)
vim.keymap.set("n", "<C-n>", "<C-w>h", { desc = "Move to left split" })
vim.keymap.set("n", "<C-e>", "<C-w>k", { desc = "Move to upper split" })
vim.keymap.set("n", "<C-a>", "<C-w>j", { desc = "Move to lower split" })
vim.keymap.set("n", "<C-o>", "<C-w>l", { desc = "Move to right split" })

-- Select from cursor to next occurrence of word under cursor
vim.keymap.set("n", "<leader>*", function()
  local word = vim.fn.expand("<cword>")
  if word == "" then return end
  local pattern = "\\<" .. word .. "\\>"
  vim.fn.setreg("/", pattern)
  vim.opt.hlsearch = true
  -- Find end of next occurrence without moving cursor
  local save = vim.fn.winsaveview()
  local next_start = vim.fn.searchpos(pattern, "W")
  if next_start[1] == 0 then
    vim.fn.winrestview(save)
    return
  end
  local next_end = vim.fn.searchpos(pattern, "ceW")
  vim.fn.winrestview(save)
  -- Set mark z at end of next occurrence, then visual select to it
  vim.api.nvim_buf_set_mark(0, "z", next_end[1], next_end[2] - 1, {})
  local keys = vim.api.nvim_replace_termcodes("v`z", true, false, true)
  vim.api.nvim_feedkeys(keys, "nx", false)
end, { desc = "Select to next occurrence of word" })

-- Open file under cursor in a vertical split
vim.keymap.set("n", "<leader>wf", "<C-w>vgf", { desc = "Open file under cursor in split" })

-- Jumplist navigation (<C-o>/<C-i> overridden above; use <leader>o/i instead)
vim.keymap.set("n", "<leader>o", "<C-o>", { desc = "Jump back" })
vim.keymap.set("n", "<leader>i", "<C-i>", { desc = "Jump forward" })

-- Clear search highlight
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostics
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic quickfix list" })

-- Exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Toggle mouse (useful for terminal copy)
vim.keymap.set("n", "<leader>m", function()
  vim.o.mouse = (vim.o.mouse == "" and "a" or "")
  print("mouse=" .. (vim.o.mouse == "" and "off" or vim.o.mouse))
end, { desc = "Toggle mouse" })

-- Toggle which-key
vim.keymap.set("n", "<leader>tw", function()
  local wk = require("which-key")
  if wk.is_enabled() then
    wk.disable()
    print("which-key: off")
  else
    wk.enable()
    print("which-key: on")
  end
end, { desc = "[T]oggle [W]hich-key" })

-- Cycle markdown UI theme
vim.keymap.set("n", "<leader>um", function()
  require("config.markdown-themes").cycle()
end, { desc = "Cycle markdown theme" })

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Copilot context export
vim.keymap.set("v", "<leader>cs", function()
  local s = vim.fn.getpos("v")[2]
  local e = vim.fn.getpos(".")[2]
  if s > e then s, e = e, s end
  local buf = vim.api.nvim_get_current_buf()
  local file = vim.fn.expand("%:p")
  local ft = vim.bo.filetype or ""
  local lines = vim.api.nvim_buf_get_lines(buf, s - 1, e, false)
  local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
  vim.api.nvim_feedkeys(esc, "x", false)
  if #lines == 0 then
    vim.notify("No selection", vim.log.levels.WARN)
    return
  end
  local ok, err = pcall(function()
    require("config.copilot-send")._send_to_copilot(lines, s, e, file, ft)
  end)
  if not ok then vim.notify("cs error: " .. tostring(err), vim.log.levels.ERROR) end
end, { desc = "Send to tmux copilot" })

vim.keymap.set("v", "<leader>cw", function()
  require("config.copilot-send").export_context()
end, { desc = "Write context to file" })

vim.keymap.set("n", "<leader>cc", function()
  require("config.copilot-send").clear_context()
end, { desc = "Clear context file" })

vim.keymap.set("n", "<leader>ca", function()
  require("config.copilot-send").toggle_append()
end, { desc = "Toggle append mode" })

vim.keymap.set("v", "<leader>ct", function()
  require("config.copilot-send").send_to_tmux()
end, { desc = "Send to tmux copilot pane" })

-- Git file picker (global — works without gitsigns attached)
vim.keymap.set("n", "<leader>hf", function()
  local base = vim.g.gitsigns_base
  local cmd = base and ("git diff " .. base .. " --name-only") or "git diff --name-only"
  local label = base or "index"
  local result = vim.fn.systemlist(cmd)
  if #result == 0 then
    vim.notify("No files changed vs " .. label, vim.log.levels.INFO)
    return
  end
  require("telescope.pickers").new({}, {
    prompt_title = "Files changed vs " .. label,
    finder = require("telescope.finders").new_table({ results = result }),
    sorter = require("telescope.config").values.generic_sorter({}),
    previewer = require("telescope.config").values.file_previewer({}),
  }):find()
end, { desc = "Files changed vs base" })

vim.keymap.set("n", "<leader>hb", function()
  vim.ui.input({ prompt = "Change base: " }, function(ref)
    if ref and ref ~= "" then
      require("gitsigns").change_base(ref, true)
      vim.g.gitsigns_base = ref
      print("Gitsigns base: " .. ref)
    end
  end)
end, { desc = "Change gitsigns base" })
