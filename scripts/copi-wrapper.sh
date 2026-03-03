#!/usr/bin/env bash
# Wrapper for copilot-send.lua — dynamically loads brainctl shell-init
# so it stays in sync with brainctl updates.
export PATH="/users/contrgle/.nvm/versions/node/v22.22.0/bin:$PATH"
eval "$(brainctl shell-init)"
exec ghcs-brain --allow-all "$@"
