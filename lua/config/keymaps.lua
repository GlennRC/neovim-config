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

-- Copilot CLI integration
vim.keymap.set("v", "<leader>cs", function()
  require("config.copilot-send").send_interactive()
end, { desc = "Send to Copilot CLI" })

vim.keymap.set("v", "<leader>cq", function()
  require("config.copilot-send").quick_ask()
end, { desc = "Quick ask Copilot CLI" })

-- Lazygit floating terminal
vim.keymap.set("n", "<leader>gg", function()
  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.9)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
  })
  vim.fn.termopen("lazygit", {
    on_exit = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end,
  })
  vim.cmd("startinsert")
end, { desc = "Lazygit" })
