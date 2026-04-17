#!/bin/bash
set -euo pipefail

# ============================================================
# USER SETUP SCRIPT
# ============================================================

GH_USERNAME=""
EMAIL=""
read -p "github username: " GH_USERNAME
read -p "gpg email: " EMAIL

# Validate inputs
if [[ -z "$GH_USERNAME" || -z "$EMAIL" ]]; then
  echo "Error: github username and email cannot be empty"
  exit 1
fi

# ============================================================
# FLAGS
# ============================================================

OPT_SUCKLESS=false
OPT_GPG=false
OPT_FONTS=false
OPT_STEAM=false
OPT_PASSFF=false
OPT_COLORPROFILE=false

usage() {
    echo "Verwendung: $0 [OPTIONEN]"
    echo ""
    echo "  --suckless   dwm, st, surf, dmenu, slstatus bauen & installieren"
    echo "  --gpg        GPG / YubiKey einrichten & git config"
    echo "  --fonts      Hack Nerd Font installieren"
    echo "  --steam      Steam installieren"
    echo "  --passff     PassFF Host App installieren"
    echo "  --colorprofile Farbprofil installieren"
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
        --colorprofile)   OPT_COLORPROFILE=true ;;
        --all)
            OPT_SUCKLESS=true
            OPT_GPG=true
            OPT_FONTS=true
            OPT_STEAM=true
            OPT_PASSFF=true
            OPT_COLORPROFILE=true
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

# Add line to file if it doesn't exist
add_line_once() {
  local file="$1"
  local line="$2"
  grep -qF "$line" "$file" || echo "$line" >> "$file"
}

INSTALL_DIR="$HOME/repos/debian_install"
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
# ============================================================
# BASE
# ============================================================

setup_base() {
    log "Base tools & dotfiles"
    sudo cp "$INSTALL_DIR/tools/passmenu" /usr/local/bin/
    sudo cp "$INSTALL_DIR/tools/totpmenu" /usr/local/bin/
    
    add_line_once ~/.profile "export QT_QPA_PLATFORMTHEME=qt5ct"
    cp "$INSTALL_DIR/tools/startdwm/desktop/.xinitrc" ~/
}

# ============================================================
# SUCKLESS TOOLS
# ============================================================

build_suckless_tool() {
    local tool="$1"
    local patch="${2:-}"  # optional patch
    
    log "Suckless: $tool"
    
    local repo_path="$HOME/repos/$tool"
    if [[ -d "$repo_path" ]]; then
        log "$tool already exists at $repo_path, skipping clone"
    else
        git clone "https://git.suckless.org/$tool" "$repo_path"
    fi
    
    cd "$repo_path"
    rm -f config.h
    
    if [[ -n "$patch" ]]; then
        patch -p1 < "$INSTALL_DIR/$tool/${tool}_patch.diff"
    fi
    
    sudo make clean install
}

setup_suckless() {
    log "Suckless tools"
    build_suckless_tool "dwm"      "patch"
    build_suckless_tool "st"       "patch"
    build_suckless_tool "surf"     "patch"
    build_suckless_tool "dmenu"
    build_suckless_tool "slstatus" "patch"
}

# ============================================================
# GPG / YUBIKEY / GIT
# ============================================================

setup_dotfiles() {
    log "Dotfiles (GPG config)"
    
    local dotfiles_path="$HOME/repos/dotfiles"
    if [[ -d "$dotfiles_path" ]]; then
        log "Dotfiles already exist, updating..."
        cd "$dotfiles_path"
        git pull origin main
    else
        git clone "https://github.com/$GH_USERNAME/dotfiles" "$dotfiles_path"
    fi
    
    cp -r "$dotfiles_path/.gnupg" ~/
    chmod 700 ~/.gnupg
    find ~/.gnupg -type f -exec chmod 600 {} \;
    find ~/.gnupg -type d -exec chmod 700 {} \;
}

setup_bashrc_gpg() {
    log "GPG bashrc exports"
    add_line_once ~/.bashrc "export PASSWORD_STORE_GPG_OPTS='--no-throw-keyids'"
    
    add_line_once ~/.bashrc 'export GPG_TTY=$(tty)'
    add_line_once ~/.bashrc 'gpg-connect-agent updatestartuptty /bye > /dev/null 2>&1 || true'
}

setup_yubikey() {
# ============================================================
# FONTS
# ============================================================

setup_fonts() {
    log "Hack Nerd Font"
    mkdir -p ~/.local/share/fonts/
    
    local font_dir="$HOME/.local/share/fonts/Hack"
    if [[ -d "$font_dir" ]]; then
        log "Hack font already installed"
        return 0
    fi
    
    curl -L -o /tmp/Hack.zip \
        https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip
    unzip /tmp/Hack.zip -d "$font_dir"
    rm /tmp/Hack.zip
    fc-cache -fv
}

# ============================================================
# STEAM
# ============================================================

setup_steam() {
    log "Steam"
    
    if command -v steam &> /dev/null; then
        log "Steam already installed"
        return 0
    fi
    
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
# COLORPROFILE
# ============================================================

setup_colorprofile() {
    log "Install colorprofile"
    
    if [[ ! -d "$INSTALL_DIR/configs/lenovo" ]]; then
        echo "Error: Lenovo colorprofile config not found"
        return 1
    fi
    
    sudo cp "$INSTALL_DIR/configs/lenovo"/*.icm /usr/share/color/icc/
}

# ============================================================
# MAIN
# ============================================================

main() {
    setup_base

    $OPT_SUCKLESS && setup_suckless
    $OPT_GPG && setup_gpg
    $OPT_FONTS && setup_fonts
    $OPT_STEAM && setup_steam
    $OPT_PASSFF && setup_passff
    $OPT_COLORPROFILE && setup_colorprofile

    log "User setup complete!"
}

main
    curl -sSL \
        https://codeberg.org/PassFF/passff-host/releases/download/latest/install_host_app.sh \
        | bash -s -- firefox
}

# ============================================================
# COLORPROFILE
# ============================================================

setup_passff() {
    log "Install colorprofile"
    sudo cp "$INSTALL_DIR/configs/lenovo/*.icm" /usr/share/color/icc/
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
    $OPT_COLORPROFILE   && setup_colorprofile

    log "User setup complete!"
}

main
