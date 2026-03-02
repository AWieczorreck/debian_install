start_systray() {
    pkill -x ckb-next 2>/dev/null
    sleep 0.3
    ckb-next --background &
}

start_apps() {
    dunst &
    lxpolkit &
    numlockx on
    slstatus &
    snixembed --fork &
}

init_ssh_gpg() {
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    gpgconf --launch gpg-agent
}

x11_session_export() {
    dbus-update-activation-environment --systemd DISPLAY XAUTHORITY
}

setup_screen_saver_parameters() {
    xset s off -dpms
}

startdwm() {
    csum=""
    new_csum=$(sha1sum $(which dwm))
    while true
    do
        if [ "$csum" != "$new_csum" ]
        then
            csum=$new_csum
            start_systray
            dwm 2> ~/.dwm.log
        else
            exit 0
        fi
        new_csum=$(sha1sum $(which dwm))
        sleep 0.5
    done
}

init_ssh_gpg
x11_session_export
start_apps
start_systray
setup_screen_saver_parameters

startdwm
