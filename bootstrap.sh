#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_PACKAGES=(hypr omarchy terminals git)

# ---------------------------------------------------------------------------
# 1. Remove unwanted preinstalled apps (edit these lists as you debloat)
# ---------------------------------------------------------------------------
REMOVE_PKGS=(
  # Examples:
  # signal-desktop
  # obsidian
  # spotify
)

REMOVE_WEBAPPS=(
  # Examples:
  # "HEY"
  # "Basecamp"
  # "X"
)

REMOVE_TUIS=(
  # Examples:
  # "Disk Usage"
)

if (( ${#REMOVE_PKGS[@]} > 0 )); then
  echo "==> Removing unwanted packages..."
  omarchy pkg drop "${REMOVE_PKGS[@]}"
fi

for app in "${REMOVE_WEBAPPS[@]}"; do
  echo "==> Removing webapp: $app"
  omarchy webapp remove "$app" || true
done

for app in "${REMOVE_TUIS[@]}"; do
  echo "==> Removing TUI: $app"
  omarchy tui remove "$app" || true
done

# ---------------------------------------------------------------------------
# 2. Install extra packages
# ---------------------------------------------------------------------------
ADD_PKGS=(
  stow
)

if (( ${#ADD_PKGS[@]} > 0 )); then
  echo "==> Ensuring packages are installed..."
  omarchy pkg add "${ADD_PKGS[@]}"
fi

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
