return {
  "karb94/neoscroll.nvim",
  opts = {
    easing = "quadratic",
    duration_multiplier = 0.6,
  },
  keys = {
    { "<C-d>", function() require("neoscroll").scroll(math.floor(vim.api.nvim_win_get_height(0) * 0.75), { duration = 300, easing = "quadratic" }) end, mode = { "n", "v" }, desc = "Scroll down 75%" },
    { "<C-u>", function() require("neoscroll").scroll(-math.floor(vim.api.nvim_win_get_height(0) * 0.75), { duration = 300, easing = "quadratic" }) end, mode = { "n", "v" }, desc = "Scroll up 75%" },
    { "<PageDown>", function() require("neoscroll").scroll(math.floor(vim.api.nvim_win_get_height(0) * 0.75), { duration = 300, easing = "quadratic" }) end, mode = { "n", "v" }, desc = "Page down 75%" },
    { "<PageUp>", function() require("neoscroll").scroll(-math.floor(vim.api.nvim_win_get_height(0) * 0.75), { duration = 300, easing = "quadratic" }) end, mode = { "n", "v" }, desc = "Page up 75%" },
    { "<S-PageDown>", function() require("neoscroll").scroll(math.floor(vim.api.nvim_win_get_height(0) * 0.25), { duration = 200, easing = "quadratic" }) end, mode = { "n", "v" }, desc = "Page down 25%" },
    { "<S-PageUp>", function() require("neoscroll").scroll(-math.floor(vim.api.nvim_win_get_height(0) * 0.25), { duration = 200, easing = "quadratic" }) end, mode = { "n", "v" }, desc = "Page up 25%" },
    { "<C-f>", function() require("neoscroll").ctrl_f({ duration = 400 }) end, mode = { "n", "v" }, desc = "Scroll full down" },
    { "<C-b>", function() require("neoscroll").ctrl_b({ duration = 400 }) end, mode = { "n", "v" }, desc = "Scroll full up" },
  },
}
