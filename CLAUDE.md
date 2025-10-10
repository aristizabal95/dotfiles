# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a chezmoi dotfiles repository that manages personal development environment configuration across macOS and Linux systems. Chezmoi is a dotfile manager that tracks configuration files in a source directory (`~/.local/share/chezmoi`) and applies them to the home directory.

## Key Architecture

### Chezmoi Naming Conventions
- `dot_*` files → `.` prefixed files in home directory (e.g., `dot_zshrc` → `~/.zshrc`)
- `run_onchange_*` scripts → Execute automatically when the script content changes
- `.chezmoiexternal.toml` → Manages external dependencies (git repos, archives, files)
- `.chezmoiignore` → Excludes files from being managed

### External Dependencies Management
The `.chezmoiexternal.toml` file manages:
- **Oh My Zsh** with custom plugins (zsh-syntax-highlighting, zsh-autosuggestions, fzf-tab)
- **Powerlevel10k** and custom **Oxide theme** for Zsh
- **tmux plugin manager (tpm)** with plugins (catppuccin theme, vim-tmux-navigator, sessionx)
- **NvChad** Neovim configuration from custom fork

### Shell Environment (dot_zshrc)
- Theme: Oxide (custom theme in `custom_themes/oxide.zsh-theme`)
- Key plugins: zsh-autosuggestions, fzf-tab, direnv, pyenv, docker, chezmoi
- Shell integrations: direnv, zoxide
- Custom alias: `ls` → `eza --icons=always --git --color`
- Editor: nvim (SSH: vim)

### Tmux Configuration (dot_tmux.conf)
- Navigation: Seamless vim-tmux split navigation with Ctrl+hjkl
- Window switching: Custom keybindings with ≤/≥ symbols
- Pane resizing: Alt+direction (with special character bindings)
- Plugins: catppuccin theme, vim-tmux-navigator, sessionx

### Neovim Setup
- Base: NvChad framework (external git repo)
- Custom configs in `custom_nvim/`:
  - `mappings.lua`: Tmux navigation integration, jk to escape
  - `plugins/vim-tmux-navigator.lua`: Seamless tmux-vim navigation

## Common Commands

### Applying Changes
```bash
# Preview what will change
chezmoi diff

# Apply all changes
chezmoi apply

# Apply changes verbosely
chezmoi apply -v
```

### Editing Configuration
```bash
# Edit a dotfile in chezmoi source
chezmoi edit ~/.zshrc

# Edit and apply immediately
chezmoi edit --apply ~/.zshrc
```

### Managing External Dependencies
```bash
# Update all external dependencies
chezmoi update

# Force re-download external dependencies
chezmoi apply --force
```

### Package Installation
The `run_onchange_install-packages.sh` script automatically installs:
- **Base packages**: fzf, direnv, git, ripgrep, bat, jq
- **Special handling**: eza (via PPA on apt), neovim (via PPA on apt)
- **Python tooling**: uv installer

This script supports multiple package managers: apt (Debian/Ubuntu), brew (macOS), pacman (Arch), dnf (Fedora).

### Re-running Installation
```bash
# Force re-run the package installer
chezmoi apply --force ~/.local/share/chezmoi/run_onchange_install-packages.sh
```

### Testing Changes
```bash
# Check what would change without applying
chezmoi diff

# Verify chezmoi state
chezmoi status

# Check for issues
chezmoi doctor
```

## Important File Paths

### Source Directory
- Chezmoi source: `~/.local/share/chezmoi/`
- Custom nvim configs: `~/.local/share/chezmoi/custom_nvim/`
- Custom zsh themes: `~/.local/share/chezmoi/custom_themes/`

### Managed Destinations
- Zsh config: `~/.zshrc`
- Tmux config: `~/.tmux.conf`
- Neovim: `~/.config/nvim/` (managed externally via git)
- Oh My Zsh: `~/.oh-my-zsh/` (managed externally)

## Development Workflow

1. **Making Changes**: Edit files in the chezmoi source directory or use `chezmoi edit`
2. **Testing**: Use `chezmoi diff` to preview changes
3. **Applying**: Use `chezmoi apply` to sync to home directory
4. **Version Control**: The source directory is a git repository - commit changes after testing

## Special Considerations

- **Oh My Zsh updates are disabled** - managed by chezmoi instead (`.chezmoiignore` excludes cache and some custom dirs)
- **NvChad config** is maintained in a separate fork: https://github.com/aristizabal95/NvChad.git
- **Custom tmux keybindings** use macOS Option+key special characters - may need adjustment on different systems
- **Package installation** runs automatically when `run_onchange_install-packages.sh` content changes
