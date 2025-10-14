#!/bin/sh
set -e

# --- Helpers ---
has_cmd() { command -v "$1" >/dev/null 2>&1; }

# Set sudo variable once
if has_cmd sudo; then SUDO="sudo"; else SUDO=""; fi

install_pkg() {
  if has_cmd apt; then
    $SUDO apt install -y "$@"

  elif has_cmd brew; then
    brew install "$@"

  elif has_cmd pacman; then
    $SUDO pacman -Sy --noconfirm "$@"

  elif has_cmd dnf; then
    $SUDO dnf install -y "$@"

  else
    echo "No supported package manager found. Install $* manually."
    return 1
  fi
}


# --- eza + neovim (apt-specific) ---
if has_cmd apt; then
  set +e  # Temporarily disable exit on error for GPG section

  # eza (repo version)
  # Try GPG installation and operations, with Termux fallback on failure
  ($SUDO apt install -y gpg && \
        $SUDO mkdir -p /etc/apt/keyrings && \
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | $SUDO gpg --dearmor -o /etc/apt/keyrings/gierens.gpg && \
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | $SUDO tee /etc/apt/sources.list.d/gierens.list && \
        $SUDO chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list)
  GPG_EXIT_CODE=$?

  set -e  # Re-enable exit on error

  if [ $GPG_EXIT_CODE -ne 0 ]; then
    echo "Couldn't install GPG for eza - skipping eza installation"
  fi

  # Add Neovim PPA
  $SUDO add-apt-repository -y ppa:neovim-ppa/stable

  # Single apt update after adding all repositories
  $SUDO apt update -y
fi
#
# --- Base installs ---
install_pkg fzf direnv git ripgrep bat jq zoxide nodejs npm luarocks eza neovim

# -- npm dependencies --
if has_cmd npm; then
  npm i -g @anthropic-ai/claude-code
  npm i -g pyright
else
  echo "npm not found. Cannot install claude-code."
fi

# --- uv installer ---
if ! has_cmd uv; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

