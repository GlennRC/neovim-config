#!/usr/bin/env bash
# nvim-remote.sh — Launch Neovim on a remote host via SSH for Neovide
#
# Usage:
#   neovide --neovim-bin /path/to/nvim-remote.sh
#
# Environment variables (set before launching):
#   NVIM_REMOTE_HOST  — SSH host alias or user@host (default: hpnsw6803)
#   NVIM_REMOTE_DIR   — Working directory on remote (default: ~)
#
# Example:
#   NVIM_REMOTE_HOST=hpnsw6803 NVIM_REMOTE_DIR=/ws/contrgle/tasks/macsec-ptp/repos/provision-sdk neovide --neovim-bin ./nvim-remote.sh

set -euo pipefail

HOST="${NVIM_REMOTE_HOST:-hpnsw6803}"
DIR="${NVIM_REMOTE_DIR:-\~}"

exec ssh "$HOST" "cd $DIR && nvim --embed $*"
