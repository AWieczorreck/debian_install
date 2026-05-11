#!/bin/bash
set -euo pipefail

# ============================================================
# DEBIAN SETUP SCRIPT
# ============================================================

USERNAME=""
read -p "username: " USERNAME

# ============================================================
# FLAGS
# ============================================================

OPT_INTEL=false
OPT_BROWSER=false
OPT_SECURITY=false
OPT_POWER=false
OPT_FONTS=false
OPT_VIM=false
OPT_FIRMWARE=false

usage() {
    echo "Verwendung: $0 [OPTIONEN]"
    echo ""
    echo "  --intel      Intel GPU/NPU Treiber & xorg Konfiguration"
    echo "  --browser    Firefox Nightly"
    echo "  --security   Smartcard / YubiKey / pass"
    echo "  --power      Power management (power-profiles-daemon)"
    echo "  --fonts      Bitmap Fonts & UW Ttyp0"
    echo "  --vim        Vim aus Sourcecode bauen"
    echo "  --firmware   Linux Firmware aus Sourcecode bauen"
    echo "  --all        Alles aktivieren"
    echo ""
    exit 0
}

for arg in "$@"; do
    case "$arg" in
        --intel)    OPT_INTEL=true ;;
        --browser)  OPT_BROWSER=true ;;
        --security) OPT_SECURITY=true ;;
        --power)    OPT_POWER=true ;;
        --fonts)    OPT_FONTS=true ;;
        --vim)      OPT_VIM=true ;;
        --firmware) OPT_FIRMWARE=true ;;
        --all)
            OPT_INTEL=true
            OPT_BROWSER=true
            OPT_SECURITY=true
            OPT_POWER=true
            OPT_FONTS=true
            OPT_VIM=true
            OPT_FIRMWARE=true
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

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log()     { echo -e "\n\033[1;34m>>> $1\033[0m\n"; }
info()    { echo -e "${GREEN}[INFO]${NC}  $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ============================================================
# SYSTEM BASE
# ============================================================

setup_base() {
    log "Base packages & sudo"
    apt install -y sudo gpg
    usermod -a -G sudo "$USERNAME"
    mkdir ~/.gnupg
}

# ============================================================
# GRUB & KERNEL
# ============================================================

setup_grub() {
    log "GRUB configuration"

    # Nur hinzufügen wenn noch nicht vorhanden
    grep -q "GRUB_GFXMODE=1920x1080" /etc/default/grub || \
        echo "GRUB_GFXMODE=1920x1080" >> /etc/default/grub

    grep -q "GRUB_GFXPAYLOAD_LINUX=keep" /etc/default/grub || \
        echo "GRUB_GFXPAYLOAD_LINUX=keep" >> /etc/default/grub
}

# ============================================================
# APT REPOSITORIES
# ============================================================

setup_repos() {
    log "APT repositories"

    # Backports
    echo "deb http://deb.debian.org/debian trixie-backports main contrib non-free non-free-firmware" \
        | tee /etc/apt/sources.list.d/trixie-backports.list

    # Mozilla repo
    install -d -m 0755 /etc/apt/keyrings
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- \
        | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
    gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc \
        | awk '/pub/{getline; gsub(/^ +| +$/,""); print "\n"$0"\n"}'
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" \
        | tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null

    apt update
}

# ============================================================
# APT PACKAGES
# ============================================================

install_kernel() {
    log "Kernel & firmware (backports)"
    apt install -y -t trixie-backports \
        linux-image-amd64 \
        linux-headers-amd64 \
        firmware-intel-graphics
}

install_xorg() {
    log "X11 / Xorg packages"
    apt install -y \
        xserver-xorg \
        x11-xserver-utils \
        x11-utils \
        xinit \
        xcalib \
        xserver-xorg-video-all \
        xfonts-base \
        xfonts-75dpi \
        xfonts-100dpi \
        xfonts-cyrillic \
        gsfonts-x11 \
        fonts-noto \
        fonts-noto-cjk \
        fonts-noto-extra \
        xdotool \
        xinput \
        libx11-dev \
        libxft-dev \
        libxcursor-dev \
        libxcb1-dev \
        libx11-xcb-dev \
        libxcb-res0-dev \
        libxcb-xinerama0 \
        libxinerama-dev
}

install_build_tools() {
    log "Build tools & development libraries"
    apt install -y \
        build-essential \
        cmake \
        libgtk-3-dev \
        libgcr-3-dev \
        libwebkit2gtk-4.1-dev \
        libxtst-dev \
        libxt-dev \
        libsm-dev \
        libxpm-dev \
        libnss3-dev \
        libopengl0 \
        libfuse2t64 \
        qt5ct
}

install_audio_video() {
    log "Audio & video"
    apt install -y \
        pipewire \
        pulseaudio-utils \
        pavucontrol \
        ffmpeg \
        picom \
        gstreamer1.0-libav \
        gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-ugly
}

install_cli_tools() {
    log "CLI tools"
    apt install -y \
        curl \
        wget \
        unzip \
        zip \
        gpg \
        mc \
        bat \
        ripgrep \
        fzf \
        fd-find \
        rdfind \
        psmisc
}

install_security_smartcard() {
    log "Security & smartcard"
    apt install -y \
        pcscd \
        scdaemon \
        pinentry-gtk2 \
        pass \
        yubikey-manager
}

install_desktop_ui() {
    log "Desktop UI & utilities"
    apt install -y \
        thunar \
        lxpolkit \
        dunst \
        acpi \
        upower
}

install_node() {
  log "Install nvm, latest npm and node v24"
  curl -fsSL https://raw.githubusercontent.com/mklement0/n-install/stable/bin/n-install | bash -s 24
}

install_browser() {
    log "Browser"
    apt install -y \
        firefox-nightly \
        firefox-nightly-l10n-de
}

install_power() {
    log "Power management"
    apt install -y \
        power-profiles-daemon
}

# ============================================================
# INTEL CONFIGURATION
# ============================================================
setup_intel() {
    log "INTEL configuration"
    setup_intelgpu
    setup_intelnpu
}

setup_intelgpu() {
    log "INTEL GPU configuration"
    cp /root/debian_install/configs/intel/20-intel.conf /usr/share/X11/xorg.conf.d/
    chmod u+s /usr/bin/Xorg
}

setup_intelnpu() {
    log "INTEL NPU configuration"

    # ======================== https://github.com/intel/linux-npu-driver ======================
    
 
    # ------------------------------------------------------------
    # udev-Regeln einrichten (automatische Berechtigungen)
    # ------------------------------------------------------------
    info "Richte udev-Regeln ein für automatische Gerätezugriffe..."
    bash -c "echo 'SUBSYSTEM==\"accel\", KERNEL==\"accel*\", GROUP=\"render\", MODE=\"0660\"' \
        > /etc/udev/rules.d/10-intel-vpu.rules"
    udevadm control --reload-rules
    udevadm trigger --subsystem-match=accel
    info "udev-Regeln gesetzt."
 
    # ------------------------------------------------------------
    # Aktuellen Benutzer zur render-Gruppe hinzufügen
    # ------------------------------------------------------------
    REAL_USER="${SUDO_USER:-$USER}"
    if [ -n "$REAL_USER" ] && [ "$REAL_USER" != "root" ]; then
        info "Füge Benutzer '$REAL_USER' zur Gruppe 'render' hinzu..."
        usermod -a -G render "$REAL_USER"
        info "Benutzer hinzugefügt. Wirkung nach dem nächsten Login."
    else
        warn "Kein normaler Benutzer erkannt – render-Gruppe bitte manuell setzen:"
        warn "  sudo usermod -a -G render <dein-benutzername>"
    fi
}

# ============================================================
# FONTS
# ============================================================

setup_fonts() {
    log "Bitmap fonts"
    cd /etc/fonts/conf.d
    rm -f 70-no-bitmaps*.conf
    ln -sf ../conf.avail/70-yes-bitmaps.conf

    # UW Ttyp0 font
    curl -L -o /tmp/uw-ttyp0.tar.gz \
        "https://people.mpi-inf.mpg.de/~uwe/misc/uw-ttyp0/uw-ttyp0-2.1.tar.gz"
    tar xf /tmp/uw-ttyp0.tar.gz -C /tmp
    cd /tmp/uw-ttyp0-2.1
    ./configure && make && make install
    rm -rf /tmp/uw-ttyp0-2.1 /tmp/uw-ttyp0.tar.gz
}

# ============================================================
# LOCALE & KEYBOARD
# ============================================================

setup_locale() {
    log "Locale & keyboard"
    grep -q '^en_US.UTF-8' /etc/locale.gen || \
        sed -i 's/^# \(en_US.UTF-8\)/\1/' /etc/locale.gen
    grep -q '^de_DE.UTF-8' /etc/locale.gen || \
        sed -i 's/^# \(de_DE.UTF-8\)/\1/' /etc/locale.gen
    locale-gen

    grep -q '^#XKBOPTIONS=""' /etc/default/keyboard || \
        sed -i 's/^XKBOPTIONS=""/#XKBOPTIONS=""/' /etc/default/keyboard
}

# ============================================================
# SOURCE BUILDS
# ============================================================

build_vim() {
    log "Build Vim from source"
    git clone https://github.com/vim/vim.git "/home/$USERNAME/repos/vim"
    cd "/home/$USERNAME/repos/vim"
    ./configure --with-features=huge --with-x --prefix=/usr/local
    make install
}

build_linux_firmware() {
    log "Build & install linux-firmware"
    git clone https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git \
        "/home/$USERNAME/repos/linux-firmware"
    cd "/home/$USERNAME/repos/linux-firmware"
    make install
    make dedup
    update-initramfs -u -k all
}

# ============================================================
# MISC / EXTRAS
# ============================================================

setup_snixembed() {
    log "snixembed (system tray)"
    wget -O /tmp/setup-snixembed.sh \
        https://gist.githubusercontent.com/archisman-panigrahi/cd571ddea1aa2c5e2b4fa7bcbee7d5df/raw/setup-snixembed-debian.sh
    bash /tmp/setup-snixembed.sh
    rm /tmp/setup-snixembed.sh
}

setup_systemd_services() {
    log "Systemd services"
    systemctl daemon-reload
    systemctl enable --now upower.service
}

setup_repos_ownership() {
    log "Move repos & fix ownership"
    cd
    mv debian_install "/home/$USERNAME/repos/"
    chown -R "$USERNAME:$USERNAME" "/home/$USERNAME/repos/"
}

# ============================================================
# MAIN
# ============================================================

main() {
    # -- Basis (immer) --
    setup_base
    setup_grub
    setup_repos

    install_kernel
    install_xorg
    install_build_tools
    install_audio_video
    install_cli_tools
    install_node
    install_desktop_ui
    setup_locale
    setup_snixembed

    # -- Optional --
    $OPT_INTEL    && setup_intel

    $OPT_GAMING   && setup_gamemode_group
    $OPT_GAMING   && setup_systemd_services

    $OPT_BROWSER  && install_browser

    $OPT_SECURITY && install_security_smartcard

    $OPT_POWER    && install_power

    $OPT_FONTS    && setup_fonts

    $OPT_VIM      && build_vim
    $OPT_FIRMWARE && build_linux_firmware

    setup_repos_ownership

    log "Setup complete!"
}

main
