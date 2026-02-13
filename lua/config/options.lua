-- Line numbers
vim.opt.number = true

-- Mouse
vim.opt.mouse = "a"

-- Don't show mode (mini.statusline shows it)
vim.opt.showmode = false

-- Sync clipboard (deferred for startup perf)
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

-- Indentation
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.breakindent = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- UI
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.inccommand = "split"

-- Whitespace display
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Persistent undo
vim.opt.undofile = true
