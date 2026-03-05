#!/bin/bash
USERNAME=""
read -p "username: " USERNAME
apt install -y sudo gpg
sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)"/\1 nosgx"/' /etc/default/grub
echo "GRUB_GFXMODE=1920x1200" >> /etc/default/grub
echo "GRUB_GFXPAYLOAD_LINUX=keep" >> /etc/default/grub
usermod -a -G sudo $USERNAME
update-grub
echo "deb [arch=amd64,i386] http://deb.debian.org/debian trixie-backports main contrib non-free non-free-firmware" | tee /etc/apt/sources.list.d/trixie-backports.list
install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); print "\n"$0"\n"}'
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
apt update
apt install -y -t trixie-backports linux-image-amd64 linux-headers-amd64 firmware-amd-graphics
apt install -y build-essential libx11-dev libxft-dev libxcb-xinerama0 qt5ct libxinerama-dev xserver-xorg x11-xserver-utils x11-utils xinit libxcursor-dev libxcb1-dev libx11-xcb-dev libxcb-res0-dev xfonts-base xfonts-75dpi xfonts-100dpi xfonts-cyrillic gsfonts-x11 numlockx xserver-xorg-video-all xdotool xinput libgtk-3-dev libgcr-3-dev libwebkit2gtk-4.1-dev libx11-dev libxtst-dev libxt-dev libsm-dev libxpm-dev curl wget vim unzip pipewire pulseaudio-utils acpi upower libfuse2t64 fuse libnss3-dev psmisc libopengl0 mc thunar lxpolkit dunst pavucontrol ffmpeg gstreamer1.0-libav gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly npm bat ripgrep fzf fd-find pcscd scdaemon pinentry-gtk2 pass yubikey-manager vulkan-tools mesa-vulkan-drivers firefox-nightly firefox-nightly-l10n-de power-profiles-daemon ckb-next rdfind gamemode gpg
echo 'KERNEL=="vga_arbiter", GROUP="video", MODE="0660"' | tee /etc/udev/rules.d/99-vga-arbiter.rules
chmod u+s /usr/bin/Xorg
sed -i 's/^XKBOPTIONS=""/#XKBOPTIONS=""/' /etc/default/keyboard
sed -i '$i\ \ \ \ \ \ \ \ Option "TearFree" "true"' /usr/share/X11/xorg.conf.d/10-amdgpu.conf
sed -i '$i\ \ \ \ \ \ \ \ Option "SWCursor" "true"' /usr/share/X11/xorg.conf.d/10-amdgpu.conf
sed -i '$i\ \ \ \ \ \ \ \ Option "DRI" "3"' /usr/share/X11/xorg.conf.d/10-amdgpu.conf
sed -i '/HotplugDriver/d' /usr/share/X11/xorg.conf.d/10-amdgpu.conf
cd /etc/fonts/conf.d && rm -f 70-no-bitmaps*.conf && ln -s ../conf.avail/70-yes-bitmaps.conf
git clone https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git /home/$USERNAME/repos/linux-firmware
cd /home/$USERNAME/repos/linux-firmware
make install
make dedup
update-initramfs -u -k all
git clone https://github.com/vim/vim.git /home/$USERNAME/repos/vim
cd /home/$USERNAME/repos/vim
./configure --with-features=huge --with-x --prefix=/usr/local
make install
sed -i 's/^# \(en_US.UTF-8\)/\1/' /etc/locale.gen
sed -i 's/^# \(de_DE.UTF-8\)/\1/' /etc/locale.gen
locale-gen
wget https://gist.githubusercontent.com/archisman-panigrahi/cd571ddea1aa2c5e2b4fa7bcbee7d5df/raw/setup-snixembed-debian.sh && bash setup-snixembed-debian.sh
echo "RADV_PERFTEST=aco" | tee -a /etc/environment
sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)"/\1 amdgpu.dc=1"/' /etc/default/grub
groupadd gamemode
usermod -a -G gamemode $USERNAME
curl -L -o uw-ttyp0.tar.gz "https://people.mpi-inf.mpg.de/~uwe/misc/uw-ttyp0/uw-ttyp0-2.1.tar.gz"
tar xf uw-ttyp0.tar.gz && cd uw-ttyp0-2.1 && ./configure && make && make install
rm -rf uw-ttyp0-2.1
cp ~/debian_install/tools/ckb-next-daemon.service /etc/systemd/system/
mv debian_install /home/$USERNAME/repos/
chown -R $USERNAME:$USERNAME /home/$USERNAME/repos/
systemctl daemon-reload
systemctl enable ckb-next-daemon
systemctl start ckb-next-daemon
systemctl enable upower.service
systemctl start upower.service
