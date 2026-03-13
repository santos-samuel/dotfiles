# dotfiles

Personal machine configuration for macOS.

## Contents

| Path in repo | Symlink target |
|---|---|
| `iterm2/com.googlecode.iterm2.plist` | loaded directly by iTerm2 via `PrefsCustomFolder` |
| `karabiner/karabiner.json` | `~/.config/karabiner/karabiner.json` |
| `tmux/.tmux.conf` | `~/.tmux.conf` |
| `scripts/rom.sh` | `~/rom.sh` |
| `zsh/robbyrussell.zsh-theme` | `~/.oh-my-zsh/custom/themes/robbyrussell.zsh-theme` |

## Install

```bash
chmod +x install.sh
./install.sh
```

The script will:
- Symlink each config file to its expected location
- Back up any existing file to `<file>.bak` before overwriting
- Point iTerm2 at the `iterm2/` folder via `defaults write` (restart iTerm2 after)

## Keeping iTerm2 in sync

To make iTerm2 write preference changes back to `PrefsCustomFolder` automatically you need to enable **"Save changes when quitting"** on (Preferences > General > Settings).
The settings file will be stored as XML so that diffs are readable.
