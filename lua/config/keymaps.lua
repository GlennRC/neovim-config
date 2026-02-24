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
