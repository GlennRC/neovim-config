-- OSC52 clipboard for remote/SSH sessions only
if not vim.g.is_remote then
  return {}
end

return {
  "ojroques/nvim-osc52",
  config = function()
    local osc52 = require("osc52")
    osc52.setup({ max_length = 0, silent = true, trim = false })

    vim.api.nvim_create_autocmd("TextYankPost", {
      callback = function()
        if vim.v.event.operator == "y" and vim.v.event.regname == "" then
          osc52.copy_register("0")
        end
      end,
    })

    vim.keymap.set({ "n", "v" }, "<leader>y", osc52.copy_operator, { expr = true })
    vim.keymap.set("n", "<leader>yy", function() osc52.copy_register("0") end)
  end,
}
