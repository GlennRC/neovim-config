-- Leader must be set before lazy.nvim loads
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Nerd Font detection (set to true if your terminal uses one)
vim.g.have_nerd_font = false

require("config.platform")
require("config.options")
require("config.keymaps")
require("config.lazy")

-- Remote-only integrations
if vim.g.is_remote then
  require("config.brainctl").setup()
end
