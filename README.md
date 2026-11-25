# Omarchy Dotfiles

Personal Omarchy & Hyprland configuration managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

Each top-level directory is a Stow package mirroring `$HOME`:

- `hypr/` — `~/.config/hypr/{bindings.lua,hyprland.lua}` *(excludes machine-specific `monitors.lua`)*
- `omarchy/` — `~/.config/omarchy/{shell.json,shell.toml}` and custom `vanand.workspaces` plugin
- `terminals/` — Alacritty, Foot, Ghostty, and Kitty configs
- `git/` — `~/.config/git/config`
- `fontconfig/` — `~/.config/fontconfig/conf.d/60-armenian.conf` (Armenian glyph fallback to Noto)
- `chrome/` — `~/.config/fontconfig/chrome-fonts.conf`, `~/.local/bin/google-chrome-stable` wrapper, and `~/.local/share/applications/google-chrome.desktop` override
- `bootstrap.sh` — installs packages/themes, sets font, removes unwanted apps, and stows all packages

## Setup on a fresh Omarchy machine

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

To stow only specific packages (e.g. without terminals):

```bash
cd ~/dotfiles
stow hypr omarchy git
```

## Day-to-day workflow

Edit files in `~/.config/...` as usual — they are symlinks into `~/dotfiles`, so changes show up immediately in Git:

```bash
cd ~/dotfiles
git status
git diff
git commit -am "Describe change"
git push
```

## Omarchy gotcha: atomic config writes

Commands like `omarchy bar ...` and `omarchy font set ...` replace `shell.json` or terminal configs with regular files, breaking the symlink. To pull those changes back into this repo and restore the symlink:

```bash
cd ~/dotfiles
stow --adopt omarchy      # or: stow --adopt terminals
git diff                  # inspect what Omarchy changed
```
