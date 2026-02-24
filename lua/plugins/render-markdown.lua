return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
  ft = { "markdown" },
  config = function()
    local themes = require("config.markdown-themes")
    themes.get_highlights()
    require("render-markdown").setup(themes.get_opts())
  end,
}
