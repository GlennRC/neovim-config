return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
  ft = { "markdown" },
  opts = {
    heading = {
      backgrounds = { "RenderMarkdownH1Bg", "RenderMarkdownH2Bg", "RenderMarkdownH3Bg", "", "", "" },
    },
    bullet = { icons = { "•", "◦", "▸", "▹" } },
    code = { border = "thin", width = "block", left_pad = 2, right_pad = 2, min_width = 40 },
    dash = { icon = "─" },
    link = { enabled = false },
    sign = { enabled = false },
  },
  config = function(_, opts)
    local set = vim.api.nvim_set_hl
    -- Gruvbox-tuned heading colors
    set(0, "RenderMarkdownH1", { fg = 0xfb4934, bold = true })
    set(0, "RenderMarkdownH2", { fg = 0xfe8019, bold = true })
    set(0, "RenderMarkdownH3", { fg = 0xfabd2f, bold = true })
    set(0, "RenderMarkdownH4", { fg = 0xb8bb26, bold = true })
    set(0, "RenderMarkdownH5", { fg = 0x8ec07c, bold = true })
    set(0, "RenderMarkdownH6", { fg = 0x83a598, bold = true })
    set(0, "RenderMarkdownH1Bg", { bg = 0x442222 })
    set(0, "RenderMarkdownH2Bg", { bg = 0x443322 })
    set(0, "RenderMarkdownH3Bg", { bg = 0x3a3a22 })
    set(0, "RenderMarkdownCode", { bg = 0x1d2021 })
    set(0, "RenderMarkdownCodeBorder", { fg = 0x665c54 })
    set(0, "RenderMarkdownCodeInline", { bg = 0x1d2021 })
    set(0, "RenderMarkdownDash", { fg = 0x665c54 })
    require("render-markdown").setup(opts)
  end,
}
