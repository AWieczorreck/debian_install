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
# (N)VIM-CONFIG
# ============================================================

setup_n_vim_config() {
    rm -rf ~/.vim
    cp -r ~/repos/debian_install/configs/editors/nvim ~/.config
    cp -r ~/repos/debian_install/configs/editors/vim/.vim ~
}


# ============================================================
# MAIN
# ============================================================

main() {
    setup_password_store
    setup_n_vim_config

    log "User private configs complete!"
}

main
