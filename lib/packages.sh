#!/usr/bin/env bash
# ==============================================================================
# Omarchup Package Management Module
# ==============================================================================

sync_packages() {
  log_header "Synchronizing Packages"

  local missing_repo=()
  local installed_repo=()

  for pkg in "${PACKAGES[@]}"; do
    if pacman -Q "$pkg" &>/dev/null; then
      installed_repo+=("$pkg")
    else
      missing_repo+=("$pkg")
    fi
  done

  if ((${#missing_repo[@]} > 0)); then
    log_info "Missing official/repo packages to install: ${CLR_BOLD}${missing_repo[*]}${CLR_RESET}"
    omarchy pkg add "${missing_repo[@]}"
    log_success "Official/repo packages installed successfully."
  else
    log_success "All official/repo packages are already installed (${#installed_repo[@]} packages)."
  fi

  if ((${#AUR_PACKAGES[@]} > 0)); then
    local missing_aur=()
    local installed_aur=()

    for pkg in "${AUR_PACKAGES[@]}"; do
      if pacman -Q "$pkg" &>/dev/null; then
        installed_aur+=("$pkg")
      else
        missing_aur+=("$pkg")
      fi
    done

    if ((${#missing_aur[@]} > 0)); then
      log_info "Missing AUR packages to install: ${CLR_BOLD}${missing_aur[*]}${CLR_RESET}"
      omarchy pkg aur add "${missing_aur[@]}"
      log_success "AUR packages installed successfully."
    else
      log_success "All AUR packages are already installed (${#installed_aur[@]} packages)."
    fi
  fi
}

status_packages() {
  log_header "Package Status"

  echo -e "\n${CLR_BOLD}Official / Omarchy Repository Packages:${CLR_RESET}"
  for pkg in "${PACKAGES[@]}"; do
    if pacman -Q "$pkg" &>/dev/null; then
      local version
      version=$(pacman -Q "$pkg" | awk '{print $2}')
      echo -e "  ${CLR_GREEN}✔${CLR_RESET} ${pkg} ${CLR_DIM}(${version})${CLR_RESET}"
    else
      echo -e "  ${CLR_RED}✖${CLR_RESET} ${pkg} ${CLR_DIM}(not installed)${CLR_RESET}"
    fi
  done

  if ((${#AUR_PACKAGES[@]} > 0)); then
    echo -e "\n${CLR_BOLD}AUR Packages:${CLR_RESET}"
    for pkg in "${AUR_PACKAGES[@]}"; do
      if pacman -Q "$pkg" &>/dev/null; then
        local version
        version=$(pacman -Q "$pkg" | awk '{print $2}')
        echo -e "  ${CLR_GREEN}✔${CLR_RESET} ${pkg} ${CLR_DIM}(${version})${CLR_RESET}"
      else
        echo -e "  ${CLR_RED}✖${CLR_RESET} ${pkg} ${CLR_DIM}(not installed)${CLR_RESET}"
      fi
    done
  fi
}
