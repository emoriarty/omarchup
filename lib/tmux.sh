#!/usr/bin/env bash
# ==============================================================================
# Omarchup Tmux Configuration Module
# ==============================================================================
# Configures Omarchy's native ~/.config/tmux/tmux.conf with vim-style pane
# navigation (h, j, k, l) while preserving all Omarchy defaults.
# ==============================================================================

TMUX_CONF="${HOME}/.config/tmux/tmux.conf"
OMARCHY_DEFAULT_TMUX="/usr/share/omarchy/config/tmux/tmux.conf"
MARKER="# Vim-like pane navigation (managed by omarchup)"

is_tmux_vim_configured() {
  [[ -f "$TMUX_CONF" ]] && grep -qF "$MARKER" "$TMUX_CONF"
}

apply_tmux_vim_config() {
  local target="$1"

  # 1. Rebind vertical split from 'h' to 's' so 'h' can be used for left navigation
  sed -i 's/bind -N "Split pane vertically" h /bind -N "Split pane vertically" s /' "$target"

  # 2. Rebind kill window from 'k' to 'X' so 'k' can be used for up navigation
  sed -i 's/bind -N "Kill window" k /bind -N "Kill window" X /' "$target"

  # 3. Insert vim pane navigation bindings right after the pane control section
  local vim_block
  vim_block=$(cat << 'VIM_EOF'
# Vim-like pane navigation (managed by omarchup)
bind -N "Focus pane left" -r h select-pane -L
bind -N "Focus pane down" -r j select-pane -D
bind -N "Focus pane up" -r k select-pane -U
bind -N "Focus pane right" -r l select-pane -R
VIM_EOF
)

  # Check if insertion point exists
  if grep -qF 'bind -N "Kill pane" x kill-pane' "$target"; then
    awk -v marker="$MARKER" -v block="$vim_block" '
      { print }
      /bind -N "Kill pane" x kill-pane/ {
        print ""
        print block
      }
    ' "$target" > "${target}.tmp" && mv "${target}.tmp" "$target"
  else
    # Fallback append
    echo -e "\n${vim_block}" >> "$target"
  fi
}

sync_tmux() {
  log_header "Synchronizing Tmux Configuration"

  # Ensure directory exists
  mkdir -p "$(dirname "$TMUX_CONF")"

  # If tmux.conf does not exist, copy from Omarchy default
  if [[ ! -f "$TMUX_CONF" ]]; then
    if [[ -f "$OMARCHY_DEFAULT_TMUX" ]]; then
      log_info "Bootstrapping ~/.config/tmux/tmux.conf from Omarchy defaults..."
      cp "$OMARCHY_DEFAULT_TMUX" "$TMUX_CONF"
    else
      touch "$TMUX_CONF"
    fi
  fi

  if is_tmux_vim_configured; then
    log_success "Tmux vim navigation is already configured in ${TMUX_CONF}."
    return 0
  fi

  log_info "Applying vim-style pane navigation (h, j, k, l) to ${TMUX_CONF}..."
  cp "$TMUX_CONF" "${TMUX_CONF}.bak.$(date +%s)"
  apply_tmux_vim_config "$TMUX_CONF"

  # Reload tmux configuration if server is active
  if tmux list-sessions &>/dev/null; then
    tmux source-file "$TMUX_CONF" 2>/dev/null || true
    log_info "Reloaded running tmux server configuration."
  fi

  log_success "Tmux configuration updated successfully!"
}

status_tmux() {
  log_header "Tmux Configuration Status"

  if [[ ! -f "$TMUX_CONF" ]]; then
    echo -e "  ${CLR_RED}✖${CLR_RESET} ${TMUX_CONF} does not exist"
    return
  fi

  if is_tmux_vim_configured; then
    echo -e "  ${CLR_GREEN}✔${CLR_RESET} Vim-style navigation active ${CLR_DIM}(PREFIX + h/j/k/l)${CLR_RESET}"
    echo -e "  ${CLR_GREEN}✔${CLR_RESET} Vertical split remapped ${CLR_DIM}(PREFIX + s)${CLR_RESET}"
    echo -e "  ${CLR_GREEN}✔${CLR_RESET} Kill window remapped ${CLR_DIM}(PREFIX + X)${CLR_RESET}"
  else
    echo -e "  ${CLR_YELLOW}⚠${CLR_RESET} Vim-style navigation missing in ${TMUX_CONF}"
    echo -e "    ${CLR_DIM}Run 'omarchup tmux' to apply automatically.${CLR_RESET}"
  fi
}
