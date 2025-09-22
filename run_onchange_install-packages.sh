#!/bin/sh
set -e

# --- Helpers ---
has_cmd() { command -v "$1" >/dev/null 2>&1; }

install_pkg() {
  if has_cmd apt; then
    if has_cmd sudo; then
      sudo apt update -y && sudo apt install -y "$@"
    else
      apt update -y && apt install -y "$@"
    fi
  elif has_cmd brew; then
    brew install "$@"
  elif has_cmd pacman; then
    if has_cmd sudo; then
      sudo pacman -Sy --noconfirm "$@"
    else
      pacman -Sy --noconfirm "$@"
    fi
  elif has_cmd dnf; then
    if has_cmd sudo; then
      sudo dnf install -y "$@"
    else
      dnf install -y "$@"
    fi
  else
    echo "No supported package manager found. Install $* manually."
    return 1
  fi
}

# --- Core installs ---
install_pkg fzf direnv zoxide bat jq git ripgrep tmux eza

# --- Tmux plugins ---
# start a server but don't attach to it
tmux start-server
# create a new session but don't attach to it either
tmux new-session -d
# install the plugins
~/.tmux/plugins/tpm/scripts/install_plugins.sh
# killing the server is not required, I guess
tmux kill-server

# --- uv installer ---
if ! has_cmd uv; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi
