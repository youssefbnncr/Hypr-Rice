# Hypr-Rice

A minimal, opinionated Arch Linux setup script for **Hyprland** with a focus on zen tools, Catppuccin theming, and system-wide font configuration.  

---

## ✨ Features
- **Window Manager**: [Hyprland](https://hyprland.org/) with Hyprpaper + Wayland utilities
- **Login Manager**: [SDDM](https://github.com/sddm/sddm)
- **Terminal**: [foot](https://codeberg.org/dnkl/foot)
- **Browser**: [Zen Browser](https://zen-browser.app/)
- **Editor**: [Zed](https://zed.dev/)
- **File Manager**: Nautilus
- **Theming**: [Catppuccin](https://catppuccin.com/) for GTK, Qt, cursors, and apps
- **Fonts**:
  - [Noto Sans](https://fonts.google.com/noto) (system-wide default)
  - [JetBrains Mono](https://www.jetbrains.com/lp/mono/) (for coding/terminal)

---

## 📂 Repository Structure

```
hypr-rice/
│── install.sh          # main entrypoint script
│── scripts/            # helper scripts (fonts, theming, etc.)
│── configs/            # dotfiles/configs (hyprland, foot, zed, sddm…)
│── themes/             # Catppuccin assets (gtk, qt, cursors)
│── docs/               # documentation / usage guide
```

---

## 🚀 Installation

### 1. Clone the repo
```bash
git clone https://github.com/youssefbnncr/hypr-rice.git
cd hypr-rice
```

### 2. Run the installer
```bash
chmod +x install.sh
./install.sh
```

This will:
- Update your system
- Install base + Hyprland + core applications
- Set system-wide fonts (Noto Sans + JetBrains Mono)
- Deploy configs (Hyprland, foot, Zed, SDDM)

---

## 🖌️ Theming

Catppuccin theme is applied to:
- GTK apps (Nautilus, Zen)
- Qt apps (via Kvantum)
- Cursors
- SDDM login screen

You can tweak theme variants (Latte, Mocha, etc.) by editing configs in `configs/`.

---

## 🔤 Fonts

System-wide defaults are set via `/etc/fonts/local.conf`:
- **Sans-serif** → Noto Sans
- **Serif** → Noto Serif
- **Monospace** → JetBrains Mono

Rebuild font cache:
```bash
fc-cache -fv
```
