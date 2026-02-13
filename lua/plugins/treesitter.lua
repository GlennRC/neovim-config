return {
  "nvim-treesitter/nvim-treesitter",
  build = function()
    -- Use the new API if available, fall back to legacy :TSUpdate
    local ok, ts = pcall(require, "nvim-treesitter")
    if ok and ts.update then
      ts.update()
    else
      vim.cmd("TSUpdate")
    end
  end,
  lazy = false,
  config = function()
    -- New API (nvim-treesitter main branch / nvim 0.11+)
    local ok, ts = pcall(require, "nvim-treesitter")
    if ok and ts.setup then
      ts.setup({})
      -- Enable highlighting per filetype
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "bash", "c", "css", "diff", "go", "html", "javascript", "json",
          "lua", "luadoc", "markdown", "markdown_inline", "python", "query",
          "regex", "rust", "toml", "typescript", "vim", "vimdoc", "yaml",
        },
        callback = function() pcall(vim.treesitter.start) end,
      })
    else
      -- Legacy API (nvim 0.10.x)
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash", "c", "css", "diff", "go", "html", "javascript", "json",
          "lua", "luadoc", "markdown", "markdown_inline", "python", "query",
          "regex", "rust", "toml", "typescript", "vim", "vimdoc", "yaml",
        },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = { "ruby" },
        },
        indent = { enable = true, disable = { "ruby" } },
      })
    end
  end,
}
