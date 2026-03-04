# Neovide Remote Editing

Use Neovide (local GUI) to edit files on a remote server via SSH.

## How It Works

`nvim-remote.sh` tells Neovide to spawn `nvim --embed` on the remote host over SSH.
Neovide communicates with remote Neovim via msgpack-rpc over the SSH pipe — no TCP
ports or tunnels needed.

## Quick Start

```bash
# Default: hpnsw6803, home directory
nv-remote

# Specific directory on hpnsw6803
nv-remote hpnsw6803 /ws/contrgle/tasks/macsec-ptp/repos/provision-sdk

# Different host
nv-remote otherserver /home/user/project
```

## Shell Function (in ~/.zshrc)

```bash
nv-remote() {
  NVIM_REMOTE_HOST="${1:-hpnsw6803}" \
  NVIM_REMOTE_DIR="${2:-~}" \
  neovide --neovim-bin ~/ws.nosync/repos/neovim-config/nvim-remote.sh
}
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `NVIM_REMOTE_HOST` | `hpnsw6803` | SSH host alias or user@host |
| `NVIM_REMOTE_DIR` | `~` | Working directory on remote |

## Requirements

- Neovide installed (`brew install --cask neovide`)
- SSH key auth to remote host (no password prompts)
- Neovim installed on the remote host
- Config deployed to remote via `deploy.sh`

## Troubleshooting

- **Window doesn't appear**: Ensure SSH can connect without prompts (`ssh hpnsw6803 echo ok`)
- **Slow startup**: First connection may be slow if SSH multiplexing isn't configured
- **Plugins missing on remote**: Run `./deploy.sh` to sync config and update plugins
