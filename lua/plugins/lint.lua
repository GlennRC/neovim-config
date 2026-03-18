return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    -- Vale uses exit code 2 for "errors found" — that's normal, not a failure
    lint.linters.vale.ignore_exitcode = true

    lint.linters_by_ft = {
      markdown = { "vale" },
      text = { "vale" },
      rst = { "vale" },
    }

    -- Lint on save and when entering a buffer
    vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
      group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
      callback = function()
        lint.try_lint()
      end,
    })

    -- Manual lint keymap
    vim.keymap.set("n", "<leader>cl", function()
      lint.try_lint()
    end, { desc = "[C]ode [L]int" })
  end,
}
