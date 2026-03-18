if not vim.g.is_remote then
  return {}
end

local plugin_dir = vim.fn.expand("~/.local/share/nvim-plugins/copilot-ide.nvim")
if vim.fn.isdirectory(plugin_dir) == 0 then
  return {}
end

return {
  dir = plugin_dir,
  config = function()
    require("copilot-ide").setup({ auto_start = true })
  end,
}
