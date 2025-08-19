#!/usr/bin/env bash
# arch-hypr-minimal-install.sh
# Minimal installer: foot, VSCode (Code - OSS), Brave (AUR), JetBrains Mono fonts,
# pipewire + wireplumber + xdg portals for Hyprland.
# Run as your regular user (it will use sudo for privileged ops).

set -euo pipefail

# -------------- CONFIG (edit before running) --------------
INSTALL_MS_VSCODE=false
INSTALL_BRAVE=true
AUR_HELPER="paru"
# ----------------------------------------------------------

# Basic checks
if [ "$EUID" -eq 0 ]; then
  echo "Do NOT run this script as root. Run it as your regular user." >&2
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
  echo "sudo is required but not found. Install sudo and run again." >&2
  exit 1
fi

USER_NAME="${SUDO_USER:-$USER}"
echo "Running as user: $USER_NAME"

# Packages from official repos
PACMAN_PKGS=(
  foot foot-terminfo
  code
  ttf-jetbrains-mono
  pipewire pipewire-pulse wireplumber
  xdg-desktop-portal xdg-desktop-portal-hyprland
  wl-clipboard
  base-devel
)

# If you want ms-vscode via AUR, we will remove 'code' from pacman install and use AUR later.
if [ "$INSTALL_MS_VSCODE" = "true" ]; then
  # remove 'code' from PACMAN_PKGS if present
  PACMAN_PKGS=("${PACMAN_PKGS[@]/code}")
fi

echo "Updating system database..."
sudo pacman -Syu --noconfirm

echo "Installing official repo packages via pacman..."
sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"

# Install AUR helper (paru) if not installed and if we need AUR packages
need_aur=false
if [ "$INSTALL_BRAVE" = "true" ] || [ "$INSTALL_MS_VSCODE" = "true" ]; then
  need_aur=true
fi

install_paru() {
  if command -v "$AUR_HELPER" >/dev/null 2>&1; then
    echo "$AUR_HELPER already installed."
    return
  fi

  echo "Installing AUR helper ($AUR_HELPER)..."
  tmpdir="$(mktemp -d)"
  git clone https://aur.archlinux.org/paru.git "$tmpdir/paru"
  pushd "$tmpdir/paru" >/dev/null
  # build as normal user (not as root)
  makepkg -si --noconfirm
  popd >/dev/null
  rm -rf "$tmpdir"
}

if [ "$need_aur" = true ]; then
  install_paru
fi

# AUR installs
if [ "$INSTALL_BRAVE" = "true" ]; then
  echo "Installing Brave (AUR)..."
  # prefer paru if available, fallback to manual AUR build
  if command -v "$AUR_HELPER" >/dev/null 2>&1; then
    $AUR_HELPER -S --noconfirm brave-bin
  else
    tmpdir="$(mktemp -d)"
    git clone https://aur.archlinux.org/brave-bin.git "$tmpdir/brave-bin"
    pushd "$tmpdir/brave-bin" >/dev/null
    makepkg -si --noconfirm
    popd >/dev/null
    rm -rf "$tmpdir"
  fi
fi

if [ "$INSTALL_MS_VSCODE" = "true" ]; then
  echo "Installing Microsoft VS Code (AUR visual-studio-code-bin)..."
  if command -v "$AUR_HELPER" >/dev/null 2>&1; then
    $AUR_HELPER -S --noconfirm visual-studio-code-bin
  else
    tmpdir="$(mktemp -d)"
    git clone https://aur.archlinux.org/visual-studio-code-bin.git "$tmpdir/vscode-bin"
    pushd "$tmpdir/vscode-bin" >/dev/null
    makepkg -si --noconfirm
    popd >/dev/null
    rm -rf "$tmpdir"
  fi
fi

# Enable system services (network manager is optional - only enable if present)
echo "Enabling system services (pipewire, wireplumber)..."
# pipewire/wireplumber are socket/service-activated — try both system and user
sudo systemctl enable --now pipewire.socket || true
sudo systemctl enable --now wireplumber.service || true

# xdg-desktop-portal-hyprland is normally a user service; try enabling user units (best-effort)
echo "Attempting to enable user services (xdg portals). If you get 'Failed to connect to bus', enable them after logging in."
sudo -u "$USER_NAME" -- bash -c 'systemctl --user enable --now xdg-desktop-portal xdg-desktop-portal-hyprland || true'

# Optionally enable NetworkManager (uncomment if you want it enabled)
# sudo systemctl enable --now NetworkManager

echo ""
echo "Done. Summary:"
echo "- Installed: foot, JetBrains Mono, VSCode (Code-OSS) by default."
if [ "$INSTALL_MS_VSCODE" = "true" ]; then
  echo "- Microsoft VSCode (visual-studio-code-bin) installed from AUR instead of repo 'code'."
fi
if [ "$INSTALL_BRAVE" = "true" ]; then
  echo "- Brave (brave-bin) installed from AUR."
fi
echo "- PipeWire + WirePlumber and xdg portals (attempted to enable) installed."
echo ""
echo "Notes / next steps:"
echo "1) If you prefer NOT to use an AUR helper, remove the AUR steps and build packages manually."
echo "2) If 'systemctl --user' failed during the script, log into your desktop session and run:"
echo "     systemctl --user enable --now xdg-desktop-portal xdg-desktop-portal-hyprland"
echo "3) Configure foot in ~/.config/foot/foot.ini and Hyprland keybinds in ~/.config/hypr/hyprland.conf"
echo ""
echo "If you want, run this script with INSTALL_MS_VSCODE=true to install the Microsoft VSCode binary from AUR."

