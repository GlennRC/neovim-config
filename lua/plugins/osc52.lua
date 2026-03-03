-- OSC52 clipboard for remote/SSH sessions only
-- Uses nvim 0.10+ native osc52 clipboard provider
if not vim.g.is_remote then
  return {}
end

-- Native osc52 clipboard (auto-handles tmux passthrough)
vim.g.clipboard = {
  name = "osc52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
    ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
  },
}

-- Auto-copy yanks to system clipboard
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    if vim.v.event.operator == "y" and vim.v.event.regname == "" then
      vim.fn.setreg("+", vim.fn.getreg("0"))
    end
  end,
})

-- Utility keymaps
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })
vim.keymap.set("n", "<leader>yy", '"+yy', { desc = "Yank line to clipboard" })
vim.keymap.set("n", "<leader>cf", function()
  local name = vim.fn.expand("%:t")
  vim.fn.setreg("+", name)
  print("Copied: " .. name)
end, { desc = "Copy filename to clipboard" })
vim.keymap.set("n", "<leader>cp", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  print("Copied: " .. path)
end, { desc = "Copy full path to clipboard" })

return {}
