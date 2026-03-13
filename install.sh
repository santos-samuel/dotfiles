#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[dotfiles]${NC} $*"; }
warn()  { echo -e "${YELLOW}[dotfiles]${NC} $*"; }
error() { echo -e "${RED}[dotfiles]${NC} $*"; exit 1; }

# ---------------------------------------------------------------------------
# Dependencies
# ---------------------------------------------------------------------------

install_homebrew() {
  if command -v brew &>/dev/null; then
    info "Homebrew already installed"
    return
  fi
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

brew_install() {
  local pkg="$1"
  if brew list --formula | grep -q "^${pkg}$"; then
    info "already installed: $pkg"
  else
    info "Installing $pkg..."
    brew install "$pkg"
  fi
}

brew_cask_install() {
  local cask="$1"
  if brew list --cask | grep -q "^${cask}$"; then
    info "already installed (cask): $cask"
  else
    info "Installing $cask..."
    brew install --cask "$cask"
  fi
}

install_tpm() {
  local tpm_dir="$HOME/.tmux/plugins/tpm"
  if [ -d "$tpm_dir" ]; then
    info "TPM already installed"
    return
  fi
  info "Installing Tmux Plugin Manager..."
  git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
}

install_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    info "oh-my-zsh already installed"
    return
  fi
  info "Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

install_homebrew

brew_cask_install iterm2
brew_cask_install karabiner-elements

brew_install tmux
brew_install fzf

install_tpm
install_oh_my_zsh

# ---------------------------------------------------------------------------
# Symlinks
# ---------------------------------------------------------------------------

symlink() {
  local src="$1"
  local dst="$2"

  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    warn "already linked: $dst"
    return
  fi

  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    warn "backing up existing file: $dst -> ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi

  mkdir -p "$(dirname "$dst")"
  ln -sf "$src" "$dst"
  info "linked: $dst -> $src"
}

# --- Karabiner ---
symlink "$DOTFILES_DIR/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"

# --- tmux ---
symlink "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

# --- rom.sh ---
symlink "$DOTFILES_DIR/scripts/rom.sh" "$HOME/rom.sh"
chmod +x "$HOME/rom.sh"

# --- zsh theme ---
symlink "$DOTFILES_DIR/zsh/robbyrussell.zsh-theme" "$HOME/.oh-my-zsh/custom/themes/robbyrussell.zsh-theme"

# ---------------------------------------------------------------------------
# iTerm2
# ---------------------------------------------------------------------------

ITERM2_PREFS_DIR="$DOTFILES_DIR/iterm2"

defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$ITERM2_PREFS_DIR"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
info "iTerm2 configured to load prefs from: $ITERM2_PREFS_DIR"
warn "Restart iTerm2 for the preference change to take effect."
warn "Update iTerm2 Preferences so that it saves new changes to the \`com.googlecode.iterm2.plist\` file. Read the \`README.md\` file for more info"

info "Done."
