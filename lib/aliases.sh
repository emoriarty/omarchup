#!/usr/bin/env bash
# ==============================================================================
# Omarchup Shell Aliases Module
# ==============================================================================
# Manages user-level shell aliases in ~/.bash_aliases and ensures they are
# sourced from ~/.bashrc.
# ==============================================================================

ALIASES_FILE="${HOME}/.bash_aliases"
BASHRC_FILE="${HOME}/.bashrc"
MARKER="# Personal aliases (managed by omarchup)"

is_bashrc_aliases_configured() {
  [[ -f "$BASHRC_FILE" ]] && (grep -qF "$MARKER" "$BASHRC_FILE" || grep -qE "(source|\.)\s+.*\.bash_aliases" "$BASHRC_FILE")
}

is_aliases_file_synced() {
  [[ -f "$ALIASES_FILE" ]] && grep -qF "# Managed automatically by omarchup" "$ALIASES_FILE"
}

apply_bashrc_aliases_config() {
  local target="$1"

  # Backup ~/.bashrc before editing
  cp "$target" "${target}.bak.$(date +%s)"

  cat << 'EOF' >> "$target"

# Personal aliases (managed by omarchup)
[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases
EOF
}

generate_aliases_file() {
  local target="$1"
  local tmp_file="${target}.tmp.$$"

  {
    echo "# =============================================================================="
    echo "# Omarchup Shell Aliases"
    echo "# Managed automatically by omarchup - do not edit manually."
    echo "# Edit ~/Work/omarchup/config/aliases.conf and run 'omarchup aliases sync'."
    echo "# =============================================================================="
    echo

    if ((${#ALIASES[@]} > 0)); then
      local sorted_keys
      readarray -t sorted_keys < <(for k in "${!ALIASES[@]}"; do echo "$k"; done | sort)
      for name in "${sorted_keys[@]}"; do
        local cmd="${ALIASES[$name]}"
        printf "alias %s='%s'\n" "$name" "${cmd//\'/\'\\\'\'}"
      done
    fi
  } > "$tmp_file"

  mv "$tmp_file" "$target"
}

sync_aliases() {
  log_header "Synchronizing Shell Aliases"

  # Backup pre-existing ~/.bash_aliases if not managed by omarchup
  if [[ -f "$ALIASES_FILE" ]] && ! grep -qF "# Managed automatically by omarchup" "$ALIASES_FILE"; then
    log_info "Backing up pre-existing ~/.bash_aliases..."
    cp "$ALIASES_FILE" "${ALIASES_FILE}.bak.$(date +%s)"
  fi

  log_info "Writing aliases to ${ALIASES_FILE}..."
  generate_aliases_file "$ALIASES_FILE"
  log_success "Shell aliases written to ${ALIASES_FILE} (${#ALIASES[@]} aliases)."

  if is_bashrc_aliases_configured; then
    log_success "${BASHRC_FILE} already sources ${ALIASES_FILE}."
  else
    log_info "Configuring ${BASHRC_FILE} to source ${ALIASES_FILE}..."
    apply_bashrc_aliases_config "$BASHRC_FILE"
    log_success "${BASHRC_FILE} configured to source ${ALIASES_FILE}."
  fi
}

status_aliases() {
  log_header "Shell Aliases Status"

  if [[ ! -f "$ALIASES_FILE" ]]; then
    echo -e "  ${CLR_RED}✖${CLR_RESET} ${ALIASES_FILE} does not exist"
    echo -e "    ${CLR_DIM}Run 'omarchup aliases' to synchronize.${CLR_RESET}"
    return
  fi

  echo -e "  ${CLR_GREEN}✔${CLR_RESET} File: ${ALIASES_FILE}"

  if is_bashrc_aliases_configured; then
    echo -e "  ${CLR_GREEN}✔${CLR_RESET} Sourced in ${BASHRC_FILE}"
  else
    echo -e "  ${CLR_YELLOW}⚠${CLR_RESET} Not sourced in ${BASHRC_FILE}"
    echo -e "    ${CLR_DIM}Run 'omarchup aliases' to configure ~/.bashrc.${CLR_RESET}"
  fi

  echo -e "\n${CLR_BOLD}Configured Aliases:${CLR_RESET}"
  if ((${#ALIASES[@]} > 0)); then
    local sorted_keys
    readarray -t sorted_keys < <(for k in "${!ALIASES[@]}"; do echo "$k"; done | sort)
    for name in "${sorted_keys[@]}"; do
      local cmd="${ALIASES[$name]}"
      if grep -qF "alias ${name}=" "$ALIASES_FILE" 2>/dev/null; then
        echo -e "  ${CLR_GREEN}✔${CLR_RESET} ${CLR_BOLD}${name}${CLR_RESET} ${CLR_DIM}-> ${cmd}${CLR_RESET}"
      else
        echo -e "  ${CLR_YELLOW}⚠${CLR_RESET} ${CLR_BOLD}${name}${CLR_RESET} ${CLR_DIM}(not active in ${ALIASES_FILE})${CLR_RESET}"
      fi
    done
  else
    echo -e "  ${CLR_DIM}(No aliases configured in config/aliases.conf)${CLR_RESET}"
  fi
}
