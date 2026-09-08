#!/usr/bin/env bash
# ==============================================================================
# Omarchup Installer
# ==============================================================================
# Creates symlinks in ~/.local/bin so 'omarchup' (and 'omarchyup') can be run
# directly from anywhere in your shell.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BIN_DIR="${HOME}/.local/bin"

mkdir -p "$BIN_DIR"

ln -sf "${SCRIPT_DIR}/bin/omarchup" "${BIN_DIR}/omarchup"
ln -sf "${SCRIPT_DIR}/bin/omarchup" "${BIN_DIR}/omarchyup"

echo -e "\033[32m✔\033[0m Installed symlinks:"
echo -e "  - \033[1m${BIN_DIR}/omarchup\033[0m"
echo -e "  - \033[1m${BIN_DIR}/omarchyup\033[0m"
echo
echo -e "You can now run \033[1momarchup\033[0m or \033[1momarchyup\033[0m from any terminal."
