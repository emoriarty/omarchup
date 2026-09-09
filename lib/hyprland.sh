#!/usr/bin/env bash
# ==============================================================================
# Omarchup Hyprland Input Configuration Module
# ==============================================================================
# Configures Omarchy's ~/.config/hypr/input.lua to remap Caps Lock to Ctrl.
# ==============================================================================

HYPR_INPUT_CONF="${HOME}/.config/hypr/input.lua"
HYPR_MARKER="-- Remap Caps Lock to Ctrl (managed by omarchup)"

is_hyprland_caps_ctrl_configured() {
  [[ -f "$HYPR_INPUT_CONF" ]] && grep -qF -e "$HYPR_MARKER" "$HYPR_INPUT_CONF"
}

is_hyprland_caps_ctrl_active() {
  if command -v hyprctl &>/dev/null; then
    local opt
    opt=$(hyprctl getoption input:kb_options 2>/dev/null | grep "^str:" | awk '{print $2}')
    [[ "$opt" == *"ctrl:nocaps"* ]]
  else
    return 1
  fi
}

apply_hyprland_caps_ctrl_config() {
  local target="$1"

  # Backup first
  cp "$target" "${target}.bak.$(date +%s)"

  cat << 'EOF' >> "$target"

-- Remap Caps Lock to Ctrl (managed by omarchup)
hl.config({
  input = {
    kb_options = "ctrl:nocaps",
  },
})
EOF
}

sync_hyprland() {
  log_header "Synchronizing Hyprland Configuration"

  mkdir -p "$(dirname "$HYPR_INPUT_CONF")"

  if [[ ! -f "$HYPR_INPUT_CONF" ]]; then
    log_info "Creating initial ${HYPR_INPUT_CONF}..."
    cat << 'EOF' > "$HYPR_INPUT_CONF"
-- Remap Caps Lock to Ctrl (managed by omarchup)
hl.config({
  input = {
    kb_options = "ctrl:nocaps",
  },
})
EOF
    log_success "Created ${HYPR_INPUT_CONF} with Caps Lock remapped to Ctrl."
  elif is_hyprland_caps_ctrl_configured; then
    log_success "Caps Lock remap is already configured in ${HYPR_INPUT_CONF}."
  else
    log_info "Applying Caps Lock to Ctrl remap in ${HYPR_INPUT_CONF}..."
    apply_hyprland_caps_ctrl_config "$HYPR_INPUT_CONF"
    log_success "Caps Lock to Ctrl remap added to ${HYPR_INPUT_CONF}."
  fi

  # Reload Hyprland if running
  if command -v hyprctl &>/dev/null; then
    if hyprctl reload &>/dev/null; then
      local errors
      errors=$(hyprctl configerrors 2>/dev/null || true)
      if [[ -z "$errors" ]]; then
        log_success "Hyprland configuration reloaded with zero errors."
      else
        log_warn "Hyprland reported config errors:"
        echo -e "${CLR_DIM}${errors}${CLR_RESET}"
      fi
    fi
  fi
}

status_hyprland() {
  log_header "Hyprland Configuration Status"

  if [[ ! -f "$HYPR_INPUT_CONF" ]]; then
    echo -e "  ${CLR_RED}✖${CLR_RESET} ${HYPR_INPUT_CONF} does not exist"
    return
  fi

  if is_hyprland_caps_ctrl_configured; then
    echo -e "  ${CLR_GREEN}✔${CLR_RESET} Caps Lock remapped to Ctrl in ${HYPR_INPUT_CONF}"
  else
    echo -e "  ${CLR_YELLOW}⚠${CLR_RESET} Caps Lock remap missing in ${HYPR_INPUT_CONF}"
    echo -e "    ${CLR_DIM}Run 'omarchup hyprland' to apply automatically.${CLR_RESET}"
  fi

  if command -v hyprctl &>/dev/null; then
    if is_hyprland_caps_ctrl_active; then
      echo -e "  ${CLR_GREEN}✔${CLR_RESET} Active in Hyprland ${CLR_DIM}(input:kb_options = ctrl:nocaps)${CLR_RESET}"
    else
      local cur_opt
      cur_opt=$(hyprctl getoption input:kb_options 2>/dev/null | grep "^str:" | cut -d' ' -f2- || echo "unknown")
      echo -e "  ${CLR_YELLOW}⚠${CLR_RESET} Live Hyprland options differ ${CLR_DIM}(${cur_opt})${CLR_RESET}"
    fi
  else
    echo -e "  ${CLR_DIM}• hyprctl not found (compositor not running)${CLR_RESET}"
  fi
}
