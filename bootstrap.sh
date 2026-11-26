#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_PACKAGES=(hypr omarchy terminals git fontconfig chrome)

# ---------------------------------------------------------------------------
# 1. Install extra packages & set defaults (before dropping foot / chromium)
# ---------------------------------------------------------------------------
ADD_PKGS=(
  stow
  ghostty
  google-chrome
  ttf-iosevkaterm-nerd
)

if (( ${#ADD_PKGS[@]} > 0 )); then
  echo "==> Ensuring packages are installed..."
  omarchy pkg add "${ADD_PKGS[@]}"
fi

echo "==> Setting default terminal and browser..."
omarchy default terminal ghostty
omarchy default browser chrome

# ---------------------------------------------------------------------------
# 2. Remove unwanted preinstalled apps, web apps, services & tools
# ---------------------------------------------------------------------------
echo "==> Removing all preinstalled web apps..."
omarchy webapp remove all

if omarchy pkg present superwhisper-bin; then
  echo "==> Removing Superwhisper dictation..."
  omarchy remove dictation superwhisper
fi

echo "==> Disabling unwanted services..."
sudo systemctl disable --now cups.service cups.socket cups-browsed.service docker.service docker.socket 2>/dev/null || true
systemctl --user disable --now omarchy-fcitx5.service 2>/dev/null || true

REMOVE_PKGS=(
  # Omarchy mini-apps (keeping omacalc, disktree-bin, omasnap, signed)
  hype
  monologue
  omacut
  omawrite
  aether

  # Office & notes (keeping Papers via Nautilus sushi previewer)
  libreoffice-fresh
  obsidian
  evince

  # Media (keeping mpv, imv, gpu-screen-recorder)
  pinta
  dotnet-runtime
  cliamp
  yt-dlp

  # Remote & dictation (keeping localsend)
  moonlight-qt
  gliff
  superwhisper-bin

  # Preinstalled browser & terminal (replaced by google-chrome & ghostty)
  chromium
  foot

  # Disks & printing (keeping Files / nautilus + sushi)
  gnome-disk-utility
  system-config-printer
  cups
  cups-filters
  cups-pk-helper

  # Dev & CLI tools (keeping neovim, mise-bin, ttfx)
  omarchy-nvim
  docker
  docker-buildx
  docker-compose
  ufw-docker
  herdr
  lazygit
  btop
  tmux
  fastfetch
  tobi-try
  ruby
  lua51
  luarocks
  qemu-user-static-binfmt

  # CJK fonts & Fcitx5 input method stack
  fcitx5
  fcitx5-chewing
  fcitx5-chinese-addons
  fcitx5-gtk
  fcitx5-hangul
  fcitx5-mozc
  fcitx5-qt
  fcitx5-table-extra
  noto-fonts-cjk
)

if (( ${#REMOVE_PKGS[@]} > 0 )); then
  echo "==> Removing unwanted packages..."
  omarchy pkg drop "${REMOVE_PKGS[@]}"
fi

if command -v mise &>/dev/null && mise ls --installed gh &>/dev/null; then
  echo "==> Removing gh from mise..."
  mise uninstall gh || true
fi

# Clean up leftover desktop/D-Bus/MIME entries for removed apps
rm -f "$HOME/.local/share/applications/foot.desktop"
rm -f "$HOME/.local/share/dbus-1/services/org.fcitx.Fcitx5.service"
if [[ -f "$HOME/.config/mimeapps.list" ]]; then
  sed -i '/=HEY\.desktop$/d; /=superwhisper-url\.desktop$/d' "$HOME/.config/mimeapps.list"
fi
update-desktop-database "$HOME/.local/share/applications" &>/dev/null || true

# ---------------------------------------------------------------------------
# 3. Install custom Omarchy themes (skip if already installed)
# ---------------------------------------------------------------------------
declare -A THEMES=(
  [japan-night]="https://github.com/devgtv/omarchy-japan-night-theme"
  [minimalist]="https://github.com/athoulmuwafiq/omarchy-minimalist-theme"
)

for name in "${!THEMES[@]}"; do
  if [[ ! -d "$HOME/.config/omarchy/themes/$name" ]]; then
    echo "==> Installing theme: $name"
    omarchy theme install "${THEMES[$name]}"
  fi
done

# ---------------------------------------------------------------------------
# 4. Set system font (run BEFORE stowing terminals so symlinks aren't broken)
# ---------------------------------------------------------------------------
echo "==> Setting Omarchy font..."
omarchy font set "IosevkaTerm Nerd Font Mono"

# ---------------------------------------------------------------------------
# 5. Back up conflicting non-symlink files, then stow packages into $HOME
# ---------------------------------------------------------------------------
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
for pkg in "${STOW_PACKAGES[@]}"; do
  while IFS= read -r -d '' src; do
    rel="${src#"$DOTFILES_DIR/$pkg/"}"
    dst="$HOME/$rel"
    if [[ -e "$dst" && ! -L "$dst" ]]; then
      echo "==> Backing up existing $dst -> ${dst}.bak.${TIMESTAMP}"
      mv "$dst" "${dst}.bak.${TIMESTAMP}"
    fi
  done < <(find "$DOTFILES_DIR/$pkg" -type f -print0)
done

echo "==> Stowing packages: ${STOW_PACKAGES[*]}"
stow --dir="$DOTFILES_DIR" --target="$HOME" --no-folding "${STOW_PACKAGES[@]}"

echo "==> Done! Reload Hyprland or restart shell if needed:"
echo "    hyprctl reload && omarchy restart shell"
