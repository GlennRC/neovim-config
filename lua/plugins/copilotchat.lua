return {
  "CopilotC-Nvim/CopilotChat.nvim",
  branch = "main",
  cmd = {
    "CopilotChat", "CopilotChatToggle", "CopilotChatExplain",
    "CopilotChatFix", "CopilotChatOptimize", "CopilotChatDocs",
    "CopilotChatCommit", "CopilotChatModels", "CopilotChatAgents",
  },
  dependencies = {
    { "zbirenbaum/copilot.lua" },
    { "nvim-lua/plenary.nvim" },
  },
  opts = {
    model = "claude-opus-4.6",
  },
}
