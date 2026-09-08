#!/usr/bin/env bash
# ==============================================================================
# Omarchup Dotfiles Module (GNU Stow)
# ==============================================================================

ensure_dotfiles_prereqs() {
  local needed=()
  for cmd in git stow; do
    if ! command -v "$cmd" &>/dev/null; then
      needed+=("$cmd")
    fi
  done

  if ((${#needed[@]} > 0)); then
    log_info "Installing missing dotfiles prerequisites: ${needed[*]}"
    omarchy pkg add "${needed[@]}"
  fi
}

sync_dotfiles_repo() {
  if [[ ! -d "$DOTFILES_DIR" ]]; then
    log_info "Cloning dotfiles from ${CLR_BOLD}${DOTFILES_REPO_URL}${CLR_RESET} to ${DOTFILES_DIR}..."
    git clone "$DOTFILES_REPO_URL" "$DOTFILES_DIR"
    log_success "Dotfiles cloned."
  else
    log_info "Updating dotfiles repo in ${DOTFILES_DIR}..."
    if git -C "$DOTFILES_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
      git -C "$DOTFILES_DIR" pull --ff-only || log_warn "Could not fast-forward dotfiles repo. Local changes may exist."
      log_success "Dotfiles repository is up to date."
    else
      log_warn "${DOTFILES_DIR} exists but is not a valid git repository. Skipping git pull."
    fi
  fi
}

stow_module() {
  local module="$1"
  local force="${2:-false}"

  if [[ ! -d "${DOTFILES_DIR}/${module}" ]]; then
    log_warn "Module directory '${module}' not found in dotfiles repository."
    return 1
  fi

  log_step "Stowing module: ${CLR_BOLD}${module}${CLR_RESET}"

  # Attempt restow
  local output
  if output=$(stow --dir="$DOTFILES_DIR" --target="$HOME" -R "$module" 2>&1); then
    return 0
  else
    if [[ "$force" == "true" ]]; then
      log_warn "Stow reported conflict for '${module}'. Attempting adopt/override..."
      stow --dir="$DOTFILES_DIR" --target="$HOME" --adopt -R "$module"
      git -C "$DOTFILES_DIR" checkout -- . 2>/dev/null || true
      return 0
    else
      log_warn "Conflict detected while stowing '${module}':"
      echo -e "${CLR_DIM}${output}${CLR_RESET}"
      log_info "Existing file in ~/.config or ~ was preserved. To adopt or override, inspect manually or pass --force."
      return 1
    fi
  fi
}

sync_dotfiles() {
  local force="${1:-false}"
  local target_modules=("${MODULES[@]:-${SAFE_MODULES[@]}}")

  log_header "Synchronizing Dotfiles"

  ensure_dotfiles_prereqs
  sync_dotfiles_repo

  local success_count=0
  local fail_count=0

  for mod in "${target_modules[@]}"; do
    if stow_module "$mod" "$force"; then
      ((success_count += 1))
    else
      ((fail_count += 1))
    fi
  done

  if ((fail_count > 0)); then
    log_warn "${fail_count} modules had conflicts and were preserved safely."
  else
    log_success "All dotfile modules stowed successfully."
  fi
}

status_dotfiles() {
  local target_modules=("${MODULES[@]:-${SAFE_MODULES[@]}}")
  log_header "Dotfiles Status"

  if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo -e "  ${CLR_RED}✖${CLR_RESET} Dotfiles repository not cloned yet (${DOTFILES_DIR})"
    return
  fi

  echo -e "  ${CLR_GREEN}✔${CLR_RESET} Repository: ${DOTFILES_DIR} ${CLR_DIM}($(git -C "$DOTFILES_DIR" rev-parse --short HEAD 2>/dev/null || echo "unknown"))${CLR_RESET}"

  echo -e "\n${CLR_BOLD}Configured Modules:${CLR_RESET}"
  for mod in "${target_modules[@]}"; do
    if [[ -d "${DOTFILES_DIR}/${mod}" ]]; then
      echo -e "  ${CLR_GREEN}✔${CLR_RESET} ${mod} ${CLR_DIM}(ready)${CLR_RESET}"
    else
      echo -e "  ${CLR_YELLOW}⚠${CLR_RESET} ${mod} ${CLR_DIM}(module directory missing in repo)${CLR_RESET}"
    fi
  done
}
