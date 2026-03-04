#!/usr/bin/env bash
# Wrapper for copilot-send.lua — dynamically loads brainctl shell-init
# so it stays in sync with brainctl updates.
export PATH="/users/contrgle/.nvm/versions/node/v22.22.0/bin:$PATH"
eval "$(brainctl shell-init)"

# Hint if nvim exported context is available (prints alongside 🧠 messages)
if [ -f ".nvim-context.md" ]; then
  echo "📎 nvim context available — use @.nvim-context.md to include" >&2
fi

ghcs-brain --allow-all "$@"
