#!/bin/sh
set -e

# --- Helpers ---
has_cmd() { command -v "$1" >/dev/null 2>&1; }

install_pkg() {
  if has_cmd apt; then
    if has_cmd sudo; then SUDO="sudo"; else SUDO=""; fi
    $SUDO apt update -y
    $SUDO apt install -y "$@"

  elif has_cmd brew; then
    brew install "$@"

  elif has_cmd pacman; then
    if has_cmd sudo; then SUDO="sudo"; else SUDO=""; fi
    $SUDO pacman -Sy --noconfirm "$@"

  elif has_cmd dnf; then
    if has_cmd sudo; then SUDO="sudo"; else SUDO=""; fi
    $SUDO dnf install -y "$@"

  else
    echo "No supported package manager found. Install $* manually."
    return 1
  fi
}

# --- Base installs ---
install_pkg fzf direnv git ripgrep bat jq

# --- eza + neovim ---
if has_cmd apt; then
  if has_cmd sudo; then SUDO="sudo"; else SUDO=""; fi

  # eza (repo version)
  $SUDO apt install -y eza

  # Neovim (latest via PPA)
  if ! has_cmd nvim; then
    $SUDO add-apt-repository -y ppa:neovim-ppa/stable
    $SUDO apt update -y
    $SUDO apt install -y neovim
  fi

else
  # For non-apt package managers just install directly
  install_pkg eza neovim
fi

# --- uv installer ---
if ! has_cmd uv; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

