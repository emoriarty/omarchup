#!/usr/bin/env bash
# ==============================================================================
# Omarchup Hook Management Module
# ==============================================================================

HOOK_TARGET_DIR="${HOME}/.config/omarchy/hooks/post-update.d"
HOOK_FILE_NAME="50-omarchup.hook"
HOOK_TARGET_PATH="${HOOK_TARGET_DIR}/${HOOK_FILE_NAME}"

install_hook() {
  log_header "Installing Omarchy Post-Update Hook"

  local source_hook="${SCRIPT_DIR}/hooks/${HOOK_FILE_NAME}"
  if [[ ! -f "$source_hook" ]]; then
    log_error "Source hook not found at ${source_hook}"
    return 1
  fi

  omarchy hook install post-update "$source_hook"
  log_success "Omarchup is now registered with 'omarchy update'!"
  log_info "Whenever 'omarchy update' runs, your packages and dotfiles will sync automatically."
}

remove_hook() {
  log_header "Removing Omarchy Post-Update Hook"

  if [[ -f "$HOOK_TARGET_PATH" ]]; then
    rm -f "$HOOK_TARGET_PATH"
    log_success "Removed hook from ${HOOK_TARGET_PATH}"
  else
    log_info "No hook found at ${HOOK_TARGET_PATH}. Nothing to remove."
  fi
}

status_hook() {
  log_header "Omarchy Hook Integration Status"

  if [[ -f "$HOOK_TARGET_PATH" ]]; then
    echo -e "  ${CLR_GREEN}✔${CLR_RESET} Active in ${HOOK_TARGET_PATH}"
    echo -e "    ${CLR_DIM}Runs automatically during 'omarchy update'${CLR_RESET}"
  else
    echo -e "  ${CLR_YELLOW}⚠${CLR_RESET} Not installed in ${HOOK_TARGET_DIR}"
    echo -e "    ${CLR_DIM}Run 'omarchup hook install' to enable automatic post-update sync.${CLR_RESET}"
  fi
}
