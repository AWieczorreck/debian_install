#!/bin/bash
set -euo pipefail

# ============================================================
# DEBIAN SETUP SCRIPT
# ============================================================

USERNAME=""
read -p "username: " USERNAME

# Validate username
if [[ -z "$USERNAME" ]]; then
  echo "Error: username cannot be empty"
  exit 1
fi

# ============================================================
# FLAGS
# ============================================================

OPT_AMD=false
OPT_GAMING=false
OPT_BROWSER=false
OPT_SECURITY=false
OPT_POWER=false
OPT_FONTS=false
OPT_VIM=false
OPT_NVIM=false
OPT_FIRMWARE=false

usage() {
  echo "Verwendung: $0 [OPTIONEN]"
  echo ""
  echo "  --amd        AMD GPU Treiber & xorg Konfiguration"
  echo "  --gaming     Gaming Pakete (vulkan, gamemode, ckb-next)"
  echo "  --browser    Firefox Nightly"
  echo "  --security   Smartcard / YubiKey / pass"
  echo "  --power      Power management (power-profiles-daemon)"
  echo "  --fonts      Bitmap Fonts & UW Ttyp0"
  echo "  --vim        Vim aus Sourcecode bauen"
  echo "  --nvim       NeoVim aus Sourcecode bauen"
  echo "  --firmware   Linux Firmware aus Sourcecode bauen"
  echo "  --all        Alles aktivieren"
  echo ""
  exit 0
}

for arg in "$@"; do
  case "$arg" in
  --amd) OPT_AMD=true ;;
  --gaming) OPT_GAMING=true ;;
  --browser) OPT_BROWSER=true ;;
  --security) OPT_SECURITY=true ;;
  --power) OPT_POWER=true ;;
  --fonts) OPT_FONTS=true ;;
  --vim) OPT_VIM=true ;;
  --nvim) OPT_NVIM=true ;;
  --firmware) OPT_FIRMWARE=true ;;
  --all)
    OPT_AMD=true
    OPT_GAMING=true
    OPT_BROWSER=true
    OPT_SECURITY=true
    OPT_POWER=true
    OPT_FONTS=true
    OPT_VIM=true
    OPT_NVIM=true
    OPT_FIRMWARE=true
    ;;
  --help | -h) usage ;;
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

# Add line to file if it doesn't exists
add_line_once() {
  local file="$1"
  local line="$2"
  grep -qF "$line" "$file" || echo "$line" >>"$file"
}

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
  local grub_file="/etc/default/grub"

  # Function to add kernel parameter safely
  add_grub_param() {
    local param="$1"
    if ! grep -q "$param" "$grub_file"; then
      sed -i "s/\(GRUB_CMDLINE_LINUX_DEFAULT=\"[^\"]*\)\"/\1 $param\"/" "$grub_file"
    fi
  }

  add_grub_param "nosgx"
  add_grub_param "amdgpu.dc=1"
  add_line_once "$grub_file" "GRUB_GFXMODE=1920x1200"
  add_line_once "$grub_file" "GRUB_GFXPAYLOAD_LINUX=keep"

  update-grub
}

# ============================================================
# APT REPOSITORIES
# ============================================================

setup_repos() {
  log "APT repositories"

  # Add i386 architecture
  sed -i 's/^deb http/deb [arch=amd64,i386] http/g' /etc/apt/sources.list
  dpkg --add-architecture i386

  # Backports
  add_line_once /etc/apt/sources.list.d/trixie-backports.list \
    "deb [arch=amd64,i386] http://deb.debian.org/debian trixie-backports main contrib non-free non-free-firmware" |

    # Mozilla repo
    install -d -m 0755 /etc/apt/keyrings
  wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- |
    tee /etc/apt/keyrings/packages.mozilla.org.asc >/dev/null
  gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc |
    awk '/pub/{getline; gsub(/^ +| +$/,""); print "\n"$0"\n"}'

  add_line_once /etc/apt/sources.list.d/mozilla.list \
    "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" |
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
    firmware-amd-graphics
}

install_xorg() {
  log "X11 / Xorg packages"
  apt install -y \
    xserver-xorg \
    x11-xserver-utils \
    x11-utils \
    xinit \
    xserver-xorg-video-all \
    xfonts-base \
    xfonts-75dpi \
    xfonts-100dpi \
    xfonts-cyrillic \
    gsfonts-x11 \
    fonts-noto \
    fonts-noto-cjk \
    fonts-noto-extra \
    numlockx \
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
    clang \
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
    fuse \
    qt5ct
}

install_node() {
  log "Install nvm, latest npm and node v24"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
  nvm install-latest-npm
  nvm install v24
}

install_audio_video() {
  log "Audio & video"
  apt install -y \
    pipewire \
    pulseaudio-utils \
    pavucontrol \
    ffmpeg \
    gstreamer1.0-libav \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly
}

install_cli_tools() {
  log "CLI tools"
  apt install -y \
    curl \
    wget \
    vim \
    unzip \
    zip \
    gpg \
    mc \
    bat \
    ripgrep \
    fzf \
    fd-find \
    rdfind \
    psmisc \
    glow

  curl -LsSf https://astral.sh/uv/install.sh | sh
  curl -LsSf https://astral.sh/ruff/install.sh | sh
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
    upower \
    npm
}

install_gaming() {
  log "Gaming & GPU tools"
  apt install -y \
    vulkan-tools \
    mesa-vulkan-drivers \
    gamemode \
    ckb-next
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

install_versioned_packages() {
  log "Versioned packages (pinned)"
  apt install -y --allow-downgrades \
    libelf1t64:amd64=0.192-4 \
    libelf1t64:i386=0.192-4
}

# ============================================================
# GPU / AMDGPU CONFIGURATION
# ============================================================

setup_amdgpu() {
  log "AMD GPU configuration"
  local conf="/usr/share/X11/xorg.conf.d/10-amdgpu.conf"

  # Consolidate option additions
  local -a options=(
    'Option "TearFree" "true"'
    'Option "SWCursor" "true"'
    'Option "DRI" "3"'
  )

  for option in "${options[@]}"; do
    if ! grep -qF "$option" "$conf"; then
      sed -i '$i\        '"$option" "$conf"
    fi
  done

  # Remove conflicting option
  sed -i '/HotplugDriver/d' "$conf"

  # Setup udev rules once
  add_line_once /etc/udev/rules.d/99-vga-arbiter.rules \
    'KERNEL=="vga_arbiter", GROUP="video", MODE="0660"'

  chmod u+s /usr/bin/Xorg

  add_line_once /etc/environment "RADV_PERFTEST=aco"
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
  grep -q '^en_US.UTF-8' /etc/locale.gen ||
    sed -i 's/^# \(en_US.UTF-8\)/\1/' /etc/locale.gen
  grep -q '^de_DE.UTF-8' /etc/locale.gen ||
    sed -i 's/^# \(de_DE.UTF-8\)/\1/' /etc/locale.gen
  locale-gen

  grep -q '^#XKBOPTIONS=""' /etc/default/keyboard ||
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

install_go() {
  rm -rf /usr/local/go && tar -C /usr/local -xzf go1.26.2.linux-amd64.tar.gz
}

install_rust() {
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

build_neovim() {
  log "Build NeoVim from source"

  git clone https://github.com/neovim/neovim.git "/home/$USERNAME/repos/neovim"
  cd "/home/$USERNAME/repos/neovim"
  make CMAKE_BUILD_TYPE=RelWithDebInfo
  make install

  install_neovim_tooling
}

install_neovim_tooling() {
  log "NeoVim tooling"

  # Tree-sitter
  wget -q https://github.com/tree-sitter/tree-sitter/releases/download/v0.26.1/tree-sitter-linux-x64.gz -O /tmp/tree-sitter-linux-x64.gz
  gunzip -f /tmp/tree-sitter-linux-x64.gz
  chmod +x /tmp/tree-sitter-linux-x64
  mv /tmp/tree-sitter-linux-x64 /usr/local/bin/tree-sitter

  npm install -g neovim

  # Lua Language Server
  wget -qO /tmp/lua-language-server.tar.gz \
    https://github.com/LuaLS/lua-language-server/releases/download/3.18.1/lua-language-server-3.18.1-linux-x64.tar.gz
  mkdir -p /tmp/lua-language-server
  tar xf /tmp/lua-language-server.tar.gz -C /tmp/lua-language-server
  install -D /tmp/lua-language-server/bin/lua-language-server /home/"$USERNAME"/.local/bin/lua-language-server
  rm -rf /tmp/lua-language-server.tar.gz /tmp/lua-language-server

  # LSP servers
  npm install -g pyright dockerfile-language-server-nodejs svelte-language-server bash-language-server yaml-language-server prettier

  go install golang.org/x/tools/gopls@latest
  go install mvdan.cc/sh/v3/cmd/shfmt@latest

  cargo install stylua
  apt install -y clangd clang-format
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

setup_gamemode_group() {
  log "Gamemode group"
  groupadd -f gamemode
  usermod -a -G gamemode "$USERNAME"
}

setup_systemd_services() {
  log "Systemd services"
  cp /root/debian_install/tools/ckb-next-daemon.service /etc/systemd/system/
  systemctl daemon-reload
  systemctl enable --now ckb-next-daemon
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
  # -- Basis --
  setup_base
  setup_grub
  setup_repos

  install_kernel
  install_xorg
  install_build_tools
  install_node
  install_go
  install_rust
  install_audio_video
  install_cli_tools
  install_desktop_ui
  setup_locale
  setup_snixembed

  # -- Optional --
  $OPT_AMD && setup_amdgpu

  $OPT_GAMING && install_gaming
  $OPT_GAMING && setup_gamemode_group
  $OPT_GAMING && setup_systemd_services
  #$OPT_GAMING   && install_versioned_packages

  $OPT_BROWSER && install_browser

  $OPT_SECURITY && install_security_smartcard

  $OPT_POWER && install_power

  $OPT_FONTS && setup_fonts

  $OPT_VIM && build_vim
  $OPT_NVIM && build_neovim
  $OPT_FIRMWARE && build_linux_firmware

  setup_repos_ownership

  log "Setup complete!"
}

main
