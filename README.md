# Omarchup (omarchyup)

Personal on-demand setup and synchronization layer for **[Omarchy OS](https://omarchy.org/)** managing personal packages (`1password`, `vlc`, and `vlc-plugin-upnp`), dotfiles (`editorconfig`), and system configuration enhancements (vim-style tmux navigation & VLC UPnP service discovery).

Everything else (Hyprland, status bar, notifications, terminal themes, LazyVim, prompt, audio, Bluetooth, and core system utilities) is completely managed and comprehended by Omarchy OS.

---

## What Omarchup Manages

1. **Personal Applications ([config/packages.conf](config/packages.conf))**:
   - `1password`
   - `vlc`
   - `vlc-plugin-upnp`
2. **Personal Dotfiles ([config/dotfiles.conf](config/dotfiles.conf))**:
   - Modules from `emoriarty/dotfiles`:
     - `editorconfig` (`~/.editorconfig`)
3. **Omarchy Tmux Tuning ([lib/tmux.sh](lib/tmux.sh))**:
   - Idempotently applies vim-style pane navigation (`PREFIX + h/j/k/l`) to `~/.config/tmux/tmux.conf`.
   - Remaps vertical split to `PREFIX + s` and kill window to `PREFIX + X`.
   - Preserves all Omarchy system theming, mouse support, and terminal features.
4. **VLC UPnP Service Discovery ([lib/vlc.sh](lib/vlc.sh))**:
   - Enables UPnP service discovery in `~/.config/vlc/vlcrc`.
   - Checks and verifies UFW firewall rules for UPnP/SSDP traffic (UDP port 1900 / local subnet).

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
│   ├── dotfiles.sh         # GNU Stow manager
│   ├── tmux.sh             # Omarchy tmux configuration enhancer
│   └── vlc.sh              # VLC UPnP configuration & firewall verifier
├── install.sh              # Links 'omarchup' & 'omarchyup' into ~/.local/bin
└── README.md
```

---

## Quick Start

### 1. Install CLI Symlinks
Run once to create `~/.local/bin/{omarchup, omarchyup}`:
```bash
cd ~/Work/omarchup
./install.sh
```

### 2. Check Current Status
```bash
omarchup status
```

### 3. Synchronize All
```bash
omarchup sync
```

---

## Commands

| Command | Description |
| :--- | :--- |
| `omarchup` or `omarchup sync` | Synchronize packages, editorconfig, tmux, and VLC |
| `omarchup packages [sync\|status]` | Check status or install 1password, vlc, and vlc-plugin-upnp |
| `omarchup dotfiles [sync\|status]` | Clone/pull dotfiles and stow editorconfig |
| `omarchup tmux [sync\|status]` | Check status or apply vim navigation to Omarchy tmux |
| `omarchup vlc [sync\|status]` | Check status or configure UPnP discovery for VLC |
| `omarchup status` | Display overview of packages, dotfiles, tmux, and VLC |
| `omarchup help` | Show help and usage instructions |
