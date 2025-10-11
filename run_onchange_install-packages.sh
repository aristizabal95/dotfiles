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
install_pkg fzf direnv git ripgrep bat jq zoxide

# --- eza + neovim ---
if has_cmd apt; then
  if has_cmd sudo; then SUDO="sudo"; else SUDO=""; fi

  # eza (repo version)
  # Try GPG installation and operations, with Termux fallback on failure
  if ! ($SUDO apt update -y && \
        $SUDO apt install -y gpg && \
        $SUDO mkdir -p /etc/apt/keyrings && \
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | $SUDO gpg --dearmor -o /etc/apt/keyrings/gierens.gpg && \
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | $SUDO tee /etc/apt/sources.list.d/gierens.list && \
        $SUDO chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list && \
        $SUDO apt update && \
        $SUDO apt install -y eza); then

    echo "GPG operations failed, attempting Termux recovery..."

    # Try Termux-specific recovery
    if ! ($SUDO apt update && \
          $SUDO apt install -y termux-tools termux-keyring && \
          $SUDO pkg upgrade -y); then
      echo "Termux recovery also failed. You may need to manually fix GPG/keyring issues."
      exit 1
    fi

    # Retry eza installation after Termux recovery
    echo "Retrying eza installation after Termux recovery..."
    $SUDO mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | $SUDO gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | $SUDO tee /etc/apt/sources.list.d/gierens.list
    $SUDO chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    $SUDO apt update
    $SUDO apt install -y eza
  fi

  # Neovim (latest via PPA)
  $SUDO add-apt-repository -y ppa:neovim-ppa/stable
  $SUDO apt update -y
  $SUDO apt install -y neovim

else
  # For non-apt package managers just install directly
  install_pkg eza neovim
fi

# --- uv installer ---
if ! has_cmd uv; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

