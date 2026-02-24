-- Switchable markdown UI themes for render-markdown.nvim
-- Cycle with <Space>um
local M = {}

-- One Dark palette
local od = {
  bg_d = 0x21252b, bg0 = 0x282c34, bg1 = 0x31353f,
  bg2 = 0x393f4a, bg3 = 0x3b3f4c, black = 0x181a1f,
  fg = 0xabb2bf, grey = 0x5c6370, light_grey = 0x848b98,
  red = 0xe86671, orange = 0xd19a66, yellow = 0xe5c07b,
  green = 0x98c379, cyan = 0x56b6c2, blue = 0x61afef, purple = 0xc678dd,
}

-- Tinted heading backgrounds (~12% fg color over dark bg)
local tint = {
  red = 0x2e2025, orange = 0x2e2820, yellow = 0x2e2c22,
  green = 0x232e25, cyan = 0x1f2c2e, blue = 0x1f2738, purple = 0x281f32,
}

local theme_order = { "github", "hybrid", "obsidian" }
M.current = "github"

local function set(group, val)
  vim.api.nvim_set_hl(0, group, val)
end

-- Shared heading foregrounds (same across all themes)
local function set_heading_fg()
  set("RenderMarkdownH1", { fg = od.red, bold = true })
  set("RenderMarkdownH2", { fg = od.orange, bold = true })
  set("RenderMarkdownH3", { fg = od.yellow, bold = true })
  set("RenderMarkdownH4", { fg = od.green, bold = true })
  set("RenderMarkdownH5", { fg = od.cyan, bold = true })
  set("RenderMarkdownH6", { fg = od.blue, bold = true })
end

---------------------------------------------------------------------------
-- Theme: Obsidian — rich colored banners, immersive note-app feel
---------------------------------------------------------------------------
local obsidian = {}

function obsidian.highlights()
  set_heading_fg()
  set("RenderMarkdownH1Bg", { bg = tint.red })
  set("RenderMarkdownH2Bg", { bg = tint.orange })
  set("RenderMarkdownH3Bg", { bg = tint.yellow })
  set("RenderMarkdownH4Bg", { bg = tint.green })
  set("RenderMarkdownH5Bg", { bg = tint.cyan })
  set("RenderMarkdownH6Bg", { bg = tint.blue })
  set("RenderMarkdownCode", { bg = od.bg0 })
  set("RenderMarkdownCodeBorder", { fg = od.bg3 })
  set("RenderMarkdownCodeInline", { bg = od.bg1 })
  set("RenderMarkdownDash", { fg = od.bg3 })
  set("RenderMarkdownQuote", { fg = od.grey })
  set("RenderMarkdownQuote1", { fg = od.grey })
  set("RenderMarkdownQuote2", { fg = od.blue })
  set("RenderMarkdownQuote3", { fg = od.cyan })
  set("RenderMarkdownQuote4", { fg = od.green })
  set("RenderMarkdownBullet", { fg = od.light_grey })
  set("RenderMarkdownTableHead", { fg = od.yellow, bold = true })
  set("RenderMarkdownTableRow", { fg = od.light_grey })
end

obsidian.opts = {
  heading = {
    border = { true, true, false, false, false, false },
    border_virtual = true,
    width = "full",
    backgrounds = {
      "RenderMarkdownH1Bg", "RenderMarkdownH2Bg", "RenderMarkdownH3Bg",
      "RenderMarkdownH4Bg", "RenderMarkdownH5Bg", "RenderMarkdownH6Bg",
    },
  },
  bullet = {
    icons = { "•", "◦", "▸", "▹" },
    highlight = "RenderMarkdownBullet",
  },
  code = {
    border = "thick",
    width = "full",
    left_pad = 2,
    right_pad = 2,
    min_width = 40,
  },
  dash = { icon = "─" },
  link = { enabled = false },
  sign = { enabled = false },
  pipe_table = {
    preset = "round",
    cell = "padded",
  },
  quote = {
    highlight = "RenderMarkdownQuote",
  },
}

---------------------------------------------------------------------------
-- Theme: GitHub — clean, minimal, web-doc feel
---------------------------------------------------------------------------
local github = {}

function github.highlights()
  set_heading_fg()
  -- Only H1 gets a very subtle bg
  set("RenderMarkdownH1Bg", { bg = tint.red })
  set("RenderMarkdownH2Bg", {})
  set("RenderMarkdownH3Bg", {})
  set("RenderMarkdownH4Bg", {})
  set("RenderMarkdownH5Bg", {})
  set("RenderMarkdownH6Bg", {})
  set("RenderMarkdownCode", { bg = od.bg1 })
  set("RenderMarkdownCodeBorder", { fg = od.bg2 })
  set("RenderMarkdownCodeInline", { bg = od.bg1 })
  set("RenderMarkdownDash", { fg = od.bg2 })
  set("RenderMarkdownQuote", { fg = od.bg3 })
  set("RenderMarkdownBullet", { link = "Normal" })
  set("RenderMarkdownTableHead", { fg = od.fg, bold = true })
  set("RenderMarkdownTableRow", { link = "Normal" })
end

github.opts = {
  heading = {
    border = { true, false, false, false, false, false },
    border_virtual = true,
    width = "block",
    right_pad = 4,
    backgrounds = {
      "RenderMarkdownH1Bg", "RenderMarkdownH2Bg", "RenderMarkdownH3Bg",
      "RenderMarkdownH4Bg", "RenderMarkdownH5Bg", "RenderMarkdownH6Bg",
    },
  },
  bullet = {
    icons = { "•", "◦", "▸", "▹" },
    highlight = "RenderMarkdownBullet",
  },
  code = {
    border = "thin",
    width = "block",
    left_pad = 2,
    right_pad = 2,
    min_width = 40,
  },
  dash = { icon = "─" },
  link = { enabled = false },
  sign = { enabled = false },
  pipe_table = {},
  quote = {
    highlight = "RenderMarkdownQuote",
  },
}

---------------------------------------------------------------------------
-- Theme: Hybrid — Obsidian headings + GitHub-clean body
---------------------------------------------------------------------------
local hybrid = {}

function hybrid.highlights()
  set_heading_fg()
  set("RenderMarkdownH1Bg", { bg = tint.red })
  set("RenderMarkdownH2Bg", { bg = tint.orange })
  set("RenderMarkdownH3Bg", { bg = tint.yellow })
  set("RenderMarkdownH4Bg", { bg = tint.green })
  set("RenderMarkdownH5Bg", { bg = tint.cyan })
  set("RenderMarkdownH6Bg", { bg = tint.blue })
  set("RenderMarkdownCode", { bg = od.bg1 })
  set("RenderMarkdownCodeBorder", { fg = od.bg2 })
  set("RenderMarkdownCodeInline", { bg = od.bg1 })
  set("RenderMarkdownDash", { fg = od.bg3 })
  set("RenderMarkdownQuote", { fg = od.grey })
  set("RenderMarkdownQuote1", { fg = od.grey })
  set("RenderMarkdownQuote2", { fg = od.blue })
  set("RenderMarkdownQuote3", { fg = od.cyan })
  set("RenderMarkdownQuote4", { fg = od.green })
  set("RenderMarkdownBullet", { fg = od.bg3 })
  set("RenderMarkdownTableHead", { fg = od.yellow, bold = true })
  set("RenderMarkdownTableRow", { fg = od.light_grey })
end

hybrid.opts = {
  heading = {
    border = { true, false, false, false, false, false },
    border_virtual = true,
    width = "full",
    backgrounds = {
      "RenderMarkdownH1Bg", "RenderMarkdownH2Bg", "RenderMarkdownH3Bg",
      "RenderMarkdownH4Bg", "RenderMarkdownH5Bg", "RenderMarkdownH6Bg",
    },
  },
  bullet = {
    icons = { "•", "◦", "▸", "▹" },
    highlight = "RenderMarkdownBullet",
  },
  code = {
    border = "thin",
    width = "block",
    left_pad = 2,
    right_pad = 2,
    min_width = 40,
  },
  dash = { icon = "─" },
  link = { enabled = false },
  sign = { enabled = false },
  pipe_table = {
    preset = "round",
    cell = "padded",
  },
  quote = {
    highlight = "RenderMarkdownQuote",
  },
}

---------------------------------------------------------------------------
-- Theme engine
---------------------------------------------------------------------------
local themes = {
  obsidian = obsidian,
  github = github,
  hybrid = hybrid,
}

function M.apply(name)
  name = name or M.current
  local theme = themes[name]
  if not theme then
    vim.notify("Unknown markdown theme: " .. name, vim.log.levels.ERROR)
    return
  end
  M.current = name
  theme.highlights()
  require("render-markdown").setup(theme.opts)
  vim.notify("Markdown theme: " .. name, vim.log.levels.INFO)
end

function M.get_opts(name)
  name = name or M.current
  return themes[name] and themes[name].opts or hybrid.opts
end

function M.get_highlights(name)
  name = name or M.current
  local theme = themes[name]
  if theme then theme.highlights() end
end

function M.cycle()
  local idx
  for i, t in ipairs(theme_order) do
    if t == M.current then idx = i; break end
  end
  idx = (idx % #theme_order) + 1
  M.apply(theme_order[idx])
end

return M
