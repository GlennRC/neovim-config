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
  require("config.copilot-send").export_context()
end, { desc = "Write context to file" })

vim.keymap.set("n", "<leader>cc", function()
  require("config.copilot-send").clear_context()
end, { desc = "Clear context file" })

vim.keymap.set("n", "<leader>ca", function()
  require("config.copilot-send").toggle_append()
end, { desc = "Toggle append mode" })

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
