-- Platform detection helpers
local hostname = vim.fn.hostname()

vim.g.is_remote = vim.env.SSH_CLIENT ~= nil or vim.env.SSH_TTY ~= nil
vim.g.is_macos = vim.fn.has("macunix") == 1
vim.g.is_linux = vim.fn.has("unix") == 1 and not vim.g.is_macos

-- Remote-specific provider config
if vim.g.is_remote then
  local venv_python = "/ws/contrgle/xdg/data/venvs/nvim-py3/bin/python"
  if vim.fn.filereadable(venv_python) == 1 then
    vim.g.python3_host_prog = venv_python
  end
end

-- Disable unused providers
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
