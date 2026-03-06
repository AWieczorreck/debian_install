#!/bin/bash
GH_USERNAME=""
EMAIL=""
read -p "github username: " GH_USERNAME
read -p "gpg email: " EMAIL
sudo cp ~/repos/debian_install/tools/passmenu /usr/local/bin
sudo cp ~/repos/debian_install/tools/totpmenu /usr/local/bin
echo "export QT_QPA_PLATFORMTHEME=qt5ct" >> ~/.profile
cp ~/repos/debian_install/tools/startdwm/.xinitrc ~
TOOL=dwm
git clone https://git.suckless.org/$TOOL ~/repos/$TOOL
cd ~/repos/$TOOL && rm -f config.h && patch -i ~/repos/debian_install/$TOOL/$(echo $TOOL)_patch.diff && sudo make install
TOOL=st
git clone https://git.suckless.org/$TOOL ~/repos/$TOOL
cd ~/repos/$TOOL && rm -f config.h && patch -i ~/repos/debian_install/$TOOL/$(echo $TOOL)_patch.diff && sudo make install
TOOL=surf
git clone https://git.suckless.org/$TOOL ~/repos/$TOOL
cd ~/repos/$TOOL && rm -f config.h && patch -i ~/repos/debian_install/$TOOL/$(echo $TOOL)_patch.diff && sudo make install
TOOL=dmenu
git clone https://git.suckless.org/$TOOL ~/repos/$TOOL
cd ~/repos/$TOOL && rm -f config.h && sudo make install
TOOL=slstatus
git clone https://git.suckless.org/$TOOL ~/repos/$TOOL
cd ~/repos/$TOOL && rm -f config.h && patch -i ~/repos/debian_install/$TOOL/$(echo $TOOL)_patch.diff && sudo make install
git clone https://github.com/$GH_USERNAME/dotfiles ~/repos/dotfiles
cp -r ~/repos/dotfiles/.gnupg ~
chmod 700 ~/.gnupg/ && chmod 700 ~/.gnupg/*
echo "export PASSWORD_STORE_GPG_OPTS='--no-throw-keyids'" >> ~/.bashrc
printf "%s\n" "export GPG_TTY=\$(tty)" "gpg-connect-agent updatestartuptty /bye > /dev/null" >> ~/.bashrc
printf "fetch\nquit\n" | script -q -c "gpg --card-edit" /dev/null
printf "trust\n5\nj\nquit\n" | script -q -c "gpg --key-edit $EMAIL" /dev/null
git config --global user.name "$(gpg --with-colons -K | grep '^uid:' | cut -d: -f10 | sed 's/ *<.*>//')"
git config --global user.email $(gpg --with-colons -K | grep '^uid:' | cut -d: -f10 | sed -n 's/.*<\([^>]*\)>.*/\1/p')
git config --global user.signingkey $(gpg --with-colons -K | awk -F: '$1=="ssb" && $12 ~ /S/ {print $5; exit} $1=="sec"{p=$5} END{if(!NR || !p){} else if(!seen && !system("")) print p}')
git config --global init.defaultBranch main
mkdir -p ~/.local/share/fonts/
curl -L -o Hack.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip
unzip Hack.zip -d ~/.local/share/fonts/Hack/
fc-cache -fv
cd ~/repos/debian_install
git remote set-url origin git@github.com:$GH_USERNAME/debian_install
curl -sSL https://codeberg.org/PassFF/passff-host/releases/download/latest/install_host_app.sh | bash -s -- firefox
git clone git@github.com:$GH_USERNAME/password-store ~/.password-store
