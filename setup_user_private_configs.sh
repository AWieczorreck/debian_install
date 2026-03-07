#!/bin/bash
set -euo pipefail

# ============================================================
# HELPER
# ============================================================

log() { echo -e "\n\033[1;34m>>> $1\033[0m\n"; }

# ============================================================
# USER SETUP SCRIPT
# ============================================================

GH_USERNAME=""
EMAIL=""
read -p "github username: " GH_USERNAME

# ============================================================
# PASSWORD-STORE
# ============================================================

setup_password_store() {
    git clone git@github.com:$GH_USERNAME/password-store ~/.password-store
}

# ============================================================
# VIM-CONFIG
# ============================================================

setup_vim_config() {
    rm -rf ~/.vim
    git clone git@github.com:$GH_USERNAME/vimconfig ~/.vim
}


# ============================================================
# MAIN
# ============================================================

main() {
    setup_password_store
    setup_vim_config

    log "User private configs complete!"
}

main
