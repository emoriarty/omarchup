#!/usr/bin/env bash
# ==============================================================================
# Omarchup Terminal UI & Formatting Helpers
# ==============================================================================

if [[ -t 1 ]]; then
  CLR_RESET="\033[0m"
  CLR_BOLD="\033[1m"
  CLR_DIM="\033[2m"
  CLR_RED="\033[31m"
  CLR_GREEN="\033[32m"
  CLR_YELLOW="\033[33m"
  CLR_BLUE="\033[34m"
  CLR_MAGENTA="\033[35m"
  CLR_CYAN="\033[36m"
else
  CLR_RESET=""
  CLR_BOLD=""
  CLR_DIM=""
  CLR_RED=""
  CLR_GREEN=""
  CLR_YELLOW=""
  CLR_BLUE=""
  CLR_MAGENTA=""
  CLR_CYAN=""
fi

print_logo() {
  # Do not print logo in quiet mode or non-interactive environments
  if [[ "${OMARCHUP_QUIET:-0}" == "1" ]] || [[ ! -t 1 ]]; then
    return 0
  fi

  cat << "LOGO_EOF"
  ____  __  __    _    ____   ____ _   _ _   _ ____  
 / __ \|  \/  |  / \  |  _ \ / ___| | | | | | |  _ \ 
| |  | | |\/| | / _ \ | |_) | |   | |_| | | | | |_) |
| |__| | |  | |/ ___ \|  _ <| |___|  _  | |_| |  __/ 
 \____/|_|  |_/_/   \_\_| \_\\____|_| |_|\___/|_|    
LOGO_EOF
  echo -e "${CLR_DIM}Personal Add-on & Dotfiles Layer for Omarchy OS${CLR_RESET}\n"
}

log_info() {
  echo -e "${CLR_BLUE}ℹ${CLR_RESET} $*"
}

log_success() {
  echo -e "${CLR_GREEN}✔${CLR_RESET} $*"
}

log_warn() {
  echo -e "${CLR_YELLOW}⚠${CLR_RESET} $*"
}

log_error() {
  echo -e "${CLR_RED}✖${CLR_RESET} $*" >&2
}

log_header() {
  echo -e "\n${CLR_BOLD}${CLR_CYAN}==>${CLR_RESET} ${CLR_BOLD}$*${CLR_RESET}"
}

log_step() {
  echo -e "  ${CLR_DIM}•${CLR_RESET} $*"
}
