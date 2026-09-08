# Omarchup (omarchyup)

Personal add-on layer for **[Omarchy OS](https://omarchy.org/)** managing personal packages (`1password`, `vlc`, and `vlc-plugin-upnp`), dotfiles (`editorconfig`), and Omarchy configuration enhancements (such as vim-style tmux navigation).

Everything else (Hyprland, status bar, notifications, terminal themes, LazyVim, prompt, audio, Bluetooth, and core system utilities) is completely managed and comprehended by Omarchy OS.

---

## What Omarchup Manages

1. **Personal Applications ([config/packages.conf](config/packages.conf))**:
   - `1password`
   - `vlc`
   - `vlc-plugin-upnp`
2. **Personal Dotfiles ([config/dotfiles.conf](config/dotfiles.conf))**:
   - Safe dotfiles modules from `emoriarty/dotfiles`:
     - `editorconfig` (`~/.editorconfig`)
   - **Excluded / Conflicting Modules**:
     - `tmux` (managed via `omarchup tmux` directly on Omarchy's config)
     - `nvim` (Omarchy provides its own tuned LazyVim setup in `~/.config/nvim/`)
     - `kitty` / `alacritty` (Omarchy manages terminal themes dynamically)
     - `starship` (Omarchy provides its own prompt defaults)
     - `hyprland` / `waybar` / `wofi` / `bash_arch` (managed by Omarchy core)
3. **Omarchy Configuration Tuning ([lib/tmux.sh](lib/tmux.sh))**:
   - Idempotently applies vim-style pane navigation (`PREFIX + h/j/k/l`) to `~/.config/tmux/tmux.conf`.
   - Remaps vertical split to `PREFIX + s` and kill window to `PREFIX + X`.
   - Preserves all Omarchy system theming, mouse support, and terminal features.

---

## Project Structure

```
~/Work/omarchup/
├── bin/
│   └── omarchup            # Main CLI runner
├── config/
│   ├── packages.conf       # 1password, vlc, vlc-plugin-upnp
│   └── dotfiles.conf       # emoriarty/dotfiles repo & module definitions (editorconfig)
├── lib/
│   ├── ui.sh               # Styling, banners, and logging
│   ├── packages.sh         # Package synchronization module
│   ├── dotfiles.sh         # GNU Stow manager with Omarchy safety guards
│   ├── tmux.sh             # Omarchy tmux configuration enhancer
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

### 2. Synchronize (Packages, Dotfiles, and Tmux)
```bash
omarchup sync
```

### 3. (Optional) Register with `omarchy update`
To have your personal packages, dotfiles, and tmux configurations re-verified after every `omarchy update`:
```bash
omarchup hook install
```

---

## Commands

| Command | Description |
| :--- | :--- |
| `omarchup` or `omarchup sync` | Synchronize packages, editorconfig, and tmux config |
| `omarchup packages [sync\|status]` | Check status or install 1password, vlc, and vlc-plugin-upnp |
| `omarchup dotfiles [sync\|status]` | Clone/pull dotfiles and stow editorconfig |
| `omarchup tmux [sync\|status]` | Check status or apply vim navigation to Omarchy tmux |
| `omarchup hook [install\|remove\|status]` | Manage Omarchy post-update hook integration |
| `omarchup status` | Display overview of packages, dotfiles, tmux, and hook |
| `omarchup update` | Runs `omarchy update`, followed by `omarchup sync` |
