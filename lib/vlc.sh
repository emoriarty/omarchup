#!/usr/bin/env bash
# ==============================================================================
# Omarchup VLC UPnP Configuration Module
# ==============================================================================

VLC_DIR="${HOME}/.config/vlc"
VLCRC="${VLC_DIR}/vlcrc"

is_vlc_upnp_configured() {
  [[ -f "$VLCRC" ]] && grep -qE "^services-discovery=.*upnp" "$VLCRC"
}

is_ufw_upnp_allowed() {
  # Check if UFW is not running (nothing blocked)
  if ! systemctl is-active ufw &>/dev/null; then
    return 0
  fi

  # Check before.rules for multicast SSDP (standard UFW UPnP rule)
  if [[ -r /etc/ufw/before.rules ]] && grep -qE "239\.255\.255\.250.*1900" /etc/ufw/before.rules 2>/dev/null; then
    return 0
  fi

  # Check user.rules for local subnet or port 1900 allow rules
  if [[ -r /etc/ufw/user.rules ]] && grep -qE "(dport 1900|192\.168\.[0-9]+\.[0-9]+/24.*ACCEPT)" /etc/ufw/user.rules 2>/dev/null; then
    return 0
  fi

  return 1
}

sync_vlc() {
  log_header "Synchronizing VLC UPnP Configuration"

  mkdir -p "$VLC_DIR"

  if [[ ! -f "$VLCRC" ]]; then
    log_info "Creating initial ~/.config/vlc/vlcrc with UPnP service discovery..."
    cat << 'EOF' > "$VLCRC"
[main]
services-discovery=upnp
EOF
    log_success "Created ~/.config/vlc/vlcrc with UPnP enabled."
  elif is_vlc_upnp_configured; then
    log_success "VLC UPnP service discovery is already configured in ${VLCRC}."
  else
    log_info "Enabling UPnP service discovery in ${VLCRC}..."
    if grep -q "^#services-discovery=" "$VLCRC"; then
      sed -i 's/^#services-discovery=.*/services-discovery=upnp/' "$VLCRC"
    elif grep -q "^services-discovery=" "$VLCRC"; then
      sed -i 's/^services-discovery=\(.*\)/services-discovery=\1:upnp/' "$VLCRC"
    else
      echo -e "\nservices-discovery=upnp" >> "$VLCRC"
    fi
    log_success "UPnP auto-discovery enabled in VLC configuration."
  fi

  # Check firewall status
  if systemctl is-active ufw &>/dev/null; then
    if is_ufw_upnp_allowed; then
      log_success "Firewall (UFW) permits UPnP discovery traffic."
    else
      log_warn "UFW is active and may block UPnP discovery responses."
      log_info "To permit UPnP traffic from your local network, run:"
      echo -e "    ${CLR_BOLD}sudo ufw allow in proto udp from 192.168.1.0/24 to any port 1900${CLR_RESET}"
    fi
  fi
}

status_vlc() {
  log_header "VLC UPnP Status"

  if pacman -Q vlc-plugin-upnp &>/dev/null; then
    echo -e "  ${CLR_GREEN}✔${CLR_RESET} Package vlc-plugin-upnp installed"
  else
    echo -e "  ${CLR_RED}✖${CLR_RESET} Package vlc-plugin-upnp missing"
  fi

  if is_vlc_upnp_configured; then
    echo -e "  ${CLR_GREEN}✔${CLR_RESET} UPnP auto-discovery enabled in ${VLCRC}"
  else
    echo -e "  ${CLR_YELLOW}⚠${CLR_RESET} UPnP auto-discovery not enabled in ${VLCRC}"
  fi

  if systemctl is-active ufw &>/dev/null; then
    if is_ufw_upnp_allowed; then
      echo -e "  ${CLR_GREEN}✔${CLR_RESET} Firewall (UFW) permits UPnP traffic"
    else
      echo -e "  ${CLR_YELLOW}⚠${CLR_RESET} Firewall (UFW) rule missing for UDP 1900"
    fi
  else
    echo -e "  ${CLR_DIM}• UFW inactive (no firewall blocking)${CLR_RESET}"
  fi
}
