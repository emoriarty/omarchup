# Omarchup (omarchyup)

Personal add-on layer for **[Omarchy OS](https://omarchy.org/)** managing solely personal dotfiles and apps (`1password` and `vlc`).

Everything else (Hyprland, status bar, notifications, terminal, prompt, audio, Bluetooth, and core system utilities) is completely managed and comprehended by Omarchy OS.

---

## What Omarchup Manages

1. **Personal Applications**:
   - `1password`
   - `vlc`
2. **Personal Dotfiles**:
   - Safe dotfiles modules from `emoriarty/dotfiles` (`nvim`, `kitty`, `alacritty`, `starship`, `tmux`, `backgrounds`, `editorconfig`).
   - Automatically skips desktop shell and window manager components already owned by Omarchy (`hyprland`, `waybar`, `wofi`, `bash_arch`).

---

## Project Structure

```
~/Work/omarchup/
├── bin/
│   └── omarchup            # Main CLI runner
├── config/
│   ├── packages.conf       # 1password and vlc
│   └── dotfiles.conf       # emoriarty/dotfiles repo & module definitions
├── lib/
│   ├── colors.sh           # Styling, banners, and logging
│   ├── packages.sh         # Package synchronization module
│   ├── dotfiles.sh         # GNU Stow manager with Omarchy safety guards
│   └── hook.sh             # Omarchy hook manager (post-update.d)
├── hooks/
│   └── 50-omarchup.hook    # Hook for ~/.config/omarchy/hooks/post-update.d/
├── install.sh              # Links 'omarchup' & 'omarchyup' into ~/.local/bin
└── README.md
```

---

## Quick Start

### 1. Check Current Status
```bash
omarchup status
```

### 2. Synchronize (Packages & Dotfiles)
```bash
omarchup sync
```

### 3. (Optional) Register with `omarchy update`
To have your personal packages and dotfiles re-verified after every `omarchy update`:
```bash
omarchup hook install
```

---

## Commands

| Command | Description |
| :--- | :--- |
| `omarchup` or `omarchup sync` | Synchronize 1password, vlc, and safe dotfiles |
| `omarchup packages [sync\|status]` | Check status or install 1password and vlc |
| `omarchup dotfiles [sync\|status]` | Clone/pull dotfiles and stow safe modules |
| `omarchup hook [install\|remove\|status]` | Manage Omarchy post-update hook integration |
| `omarchup status` | Display overview of packages, dotfiles, and hook |
| `omarchup update` | Runs `omarchy update`, followed by `omarchup sync` |
