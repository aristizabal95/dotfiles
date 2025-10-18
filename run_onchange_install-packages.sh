#!/bin/sh
set -e

# --- Helpers ---
has_cmd() { command -v "$1" >/dev/null 2>&1; }

# Set sudo variable once
if has_cmd sudo; then SUDO="sudo"; else SUDO=""; fi

# Track failed packages
FAILED_PACKAGES=""

# Detect available package managers
AVAILABLE_MANAGERS=""
if has_cmd apt; then AVAILABLE_MANAGERS="$AVAILABLE_MANAGERS apt"; fi
if has_cmd brew; then AVAILABLE_MANAGERS="$AVAILABLE_MANAGERS brew"; fi
if has_cmd pacman; then AVAILABLE_MANAGERS="$AVAILABLE_MANAGERS pacman"; fi
if has_cmd dnf; then AVAILABLE_MANAGERS="$AVAILABLE_MANAGERS dnf"; fi

install_pkg() {
  for pkg in "$@"; do
    echo "Installing $pkg..."

    if [ -z "$AVAILABLE_MANAGERS" ]; then
      echo "Error: No supported package manager found. Install $pkg manually."
      FAILED_PACKAGES="$FAILED_PACKAGES $pkg"
      continue
    fi

    installed=0
    for manager in $AVAILABLE_MANAGERS; do
      case "$manager" in
        apt)
          if $SUDO apt install -y "$pkg" 2>/dev/null; then
            installed=1
            break
          else
            echo "  apt failed to install $pkg, trying next manager..."
          fi
          ;;
        brew)
          if brew install "$pkg" 2>/dev/null; then
            installed=1
            break
          else
            echo "  brew failed to install $pkg, trying next manager..."
          fi
          ;;
        pacman)
          if $SUDO pacman -Sy --noconfirm "$pkg" 2>/dev/null; then
            installed=1
            break
          else
            echo "  pacman failed to install $pkg, trying next manager..."
          fi
          ;;
        dnf)
          if $SUDO dnf install -y "$pkg" 2>/dev/null; then
            installed=1
            break
          else
            echo "  dnf failed to install $pkg, trying next manager..."
          fi
          ;;
      esac
    done

    if [ $installed -eq 1 ]; then
      echo "Successfully installed $pkg"
    else
      echo "Warning: Failed to install $pkg with all available package managers"
      FAILED_PACKAGES="$FAILED_PACKAGES $pkg"
    fi
  done
}


# --- eza + neovim (apt-specific) ---
if has_cmd apt; then
  set +e  # Temporarily disable exit on error for repository setup

  # eza (repo version)
  # Try GPG installation and operations, with Termux fallback on failure
  ($SUDO apt install -y gpg && \
        $SUDO mkdir -p /etc/apt/keyrings && \
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | $SUDO gpg --dearmor -o /etc/apt/keyrings/gierens.gpg && \
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | $SUDO tee /etc/apt/sources.list.d/gierens.list && \
        $SUDO chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list)
  EZA_REPO_EXIT_CODE=$?

  if [ $EZA_REPO_EXIT_CODE -ne 0 ]; then
    echo "Warning: Could not set up eza repository. eza may need to be installed manually."
  fi

  # Add Neovim PPA
  $SUDO add-apt-repository -y ppa:neovim-ppa/unstable 2>/dev/null
  NEOVIM_PPA_EXIT_CODE=$?

  if [ $NEOVIM_PPA_EXIT_CODE -ne 0 ]; then
    echo "Warning: Could not add Neovim PPA (add-apt-repository may not be available on this system)."
    echo "Neovim will be installed from system repositories if available."
  fi

  set -e  # Re-enable exit on error

  # Single apt update after adding all repositories
  $SUDO apt update -y
fi
#
# --- Base installs ---
install_pkg fzf direnv git ripgrep bat jq zoxide nodejs npm luarocks eza neovim

# -- npm dependencies --
if has_cmd npm; then
  $SUDO npm i -g @anthropic-ai/claude-code
  $SUDO npm i -g pyright
else
  echo "npm not found. Cannot install claude-code."
fi

# --- uv installer ---
if ! has_cmd uv; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# --- Final Report ---
echo ""
echo "========================================"
echo "Installation Summary"
echo "========================================"
if [ -z "$FAILED_PACKAGES" ]; then
  echo "All packages installed successfully!"
else
  echo "The following packages could not be installed:"
  for pkg in $FAILED_PACKAGES; do
    echo "  - $pkg"
  done
  echo ""
  echo "Please install these packages manually."
fi
echo "========================================"
