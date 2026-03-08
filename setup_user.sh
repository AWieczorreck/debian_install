#!/bin/bash
set -euo pipefail

# ============================================================
# USER SETUP SCRIPT
# ============================================================

GH_USERNAME=""
EMAIL=""
read -p "github username: " GH_USERNAME
read -p "gpg email: "       EMAIL

# ============================================================
# FLAGS
# ============================================================

OPT_SUCKLESS=false
OPT_GPG=false
OPT_FONTS=false
OPT_STEAM=false
OPT_PASSFF=false

usage() {
    echo "Verwendung: $0 [OPTIONEN]"
    echo ""
    echo "  --suckless   dwm, st, surf, dmenu, slstatus bauen & installieren"
    echo "  --gpg        GPG / YubiKey einrichten & git config"
    echo "  --fonts      Hack Nerd Font installieren"
    echo "  --steam      Steam installieren"
    echo "  --passff     PassFF Host App installieren"
    echo "  --all        Alles aktivieren"
    echo ""
    exit 0
}

for arg in "$@"; do
    case "$arg" in
        --suckless) OPT_SUCKLESS=true ;;
        --gpg)      OPT_GPG=true ;;
        --fonts)    OPT_FONTS=true ;;
        --steam)    OPT_STEAM=true ;;
        --passff)   OPT_PASSFF=true ;;
        --all)
            OPT_SUCKLESS=true
            OPT_GPG=true
            OPT_FONTS=true
            OPT_STEAM=true
            OPT_PASSFF=true
            ;;
        --help|-h) usage ;;
        *)
            echo "Unbekanntes Argument: $arg"
            usage
            ;;
    esac
done

# ============================================================
# HELPER
# ============================================================

log() { echo -e "\n\033[1;34m>>> $1\033[0m\n"; }

INSTALL_DIR="$HOME/repos/debian_install"

# ============================================================
# BASE
# ============================================================

setup_base() {
    log "Base tools & dotfiles"
    sudo cp "$INSTALL_DIR/tools/passmenu" /usr/local/bin/
    sudo cp "$INSTALL_DIR/tools/totpmenu" /usr/local/bin/

    grep -q "QT_QPA_PLATFORMTHEME" ~/.profile || \
        echo "export QT_QPA_PLATFORMTHEME=qt5ct" >> ~/.profile

    cp "$INSTALL_DIR/tools/startdwm/.xinitrc" ~/
}

# ============================================================
# SUCKLESS TOOLS
# ============================================================

build_suckless_tool() {
    local tool="$1"
    local patch="${2:-}"  # optionaler patch

    log "Suckless: $tool"
    git clone "https://git.suckless.org/$tool" "$HOME/repos/$tool"
    cd "$HOME/repos/$tool"
    rm -f config.h
    if [[ -n "$patch" ]]; then
        patch -i "$INSTALL_DIR/$tool/${tool}_patch.diff"
    fi
    sudo make install
}

setup_suckless() {
    log "Suckless tools"
    build_suckless_tool "dwm"      "patch"
    build_suckless_tool "st"       "patch"
    build_suckless_tool "surf"     "patch"
    build_suckless_tool "dmenu"    # kein patch
    build_suckless_tool "slstatus" "patch"
}

# ============================================================
# GPG / YUBIKEY / GIT
# ============================================================

setup_dotfiles() {
    log "Dotfiles (GPG config)"
    git clone "https://github.com/$GH_USERNAME/dotfiles" "$HOME/repos/dotfiles"
    cp -r "$HOME/repos/dotfiles/.gnupg" ~/
    chmod 700 ~/.gnupg/
    chmod 700 ~/.gnupg/*
}

setup_bashrc_gpg() {
    log "GPG bashrc exports"
    grep -q "PASSWORD_STORE_GPG_OPTS" ~/.bashrc || \
        echo "export PASSWORD_STORE_GPG_OPTS='--no-throw-keyids'" >> ~/.bashrc

    grep -q "GPG_TTY" ~/.bashrc || \
        printf "%s\n" \
            'export GPG_TTY=$(tty)' \
            'gpg-connect-agent updatestartuptty /bye > /dev/null' \
            >> ~/.bashrc
}

setup_yubikey() {
    log "YubiKey GPG fetch & trust"
    printf "fetch\nquit\n"      | script -q -c "gpg --card-edit"          /dev/null
    printf "trust\n5\nj\nquit\n" | script -q -c "gpg --key-edit $EMAIL"   /dev/null
}

setup_git_config() {
    log "Git config (from GPG key)"
    local name email signingkey

    name=$(gpg --with-colons -K | grep '^uid:' | cut -d: -f10 | sed 's/ *<.*>//')
    email=$(gpg --with-colons -K | grep '^uid:' | cut -d: -f10 | sed -n 's/.*<\([^>]*\)>.*/\1/p')
    signingkey=$(gpg --with-colons -K | awk -F: '$1=="ssb" && $12 ~ /S/ {print $5; exit}
                                                  $1=="sec"{p=$5}
                                                  END{if(p) print p}')

    git config --global user.name        "$name"
    git config --global user.email       "$email"
    git config --global user.signingkey  "$signingkey"
    git config --global init.defaultBranch main
}

setup_debian_install_remote() {
    log "debian_install git remote -> SSH"
    cd "$INSTALL_DIR"
    git remote set-url origin "git@github.com:$GH_USERNAME/debian_install"
    cd ~
}

setup_gpg() {
    setup_dotfiles
    setup_bashrc_gpg
    setup_yubikey
    setup_git_config
    setup_debian_install_remote
}

# ============================================================
# FONTS
# ============================================================

setup_fonts() {
    log "Hack Nerd Font"
    mkdir -p ~/.local/share/fonts/
    curl -L -o /tmp/Hack.zip \
        https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip
    unzip /tmp/Hack.zip -d ~/.local/share/fonts/Hack/
    rm /tmp/Hack.zip
    fc-cache -fv
}

# ============================================================
# STEAM
# ============================================================

setup_steam() {
    log "Steam"
    curl -L -o /tmp/steam.deb \
        https://cdn.fastly.steamstatic.com/client/installer/steam.deb
    sudo apt install -y /tmp/steam.deb
    rm /tmp/steam.deb
    cp "$INSTALL_DIR/tools/gaming/update_ge-eggroll.sh" ~
}

# ============================================================
# PASSFF
# ============================================================

setup_passff() {
    log "PassFF host app"
    curl -sSL \
        https://codeberg.org/PassFF/passff-host/releases/download/latest/install_host_app.sh \
        | bash -s -- firefox
}

# ============================================================
# MAIN
# ============================================================

main() {
    setup_base

    $OPT_SUCKLESS && setup_suckless
    $OPT_GPG      && setup_gpg
    $OPT_FONTS    && setup_fonts
    $OPT_STEAM    && setup_steam
    $OPT_PASSFF   && setup_passff

    log "User setup complete!"
}

main
