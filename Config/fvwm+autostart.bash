#!/bin/bash

cd
export LANG=zh_CN.UTF-8 TERM=xterm LC_ALL= XIM=fcitx XIM_PROGRAM=fcitx
export LC_CTYPE=zh_CN.UTF-8
export XMODIFIERS="@im=fcitx"
export QT_IM_MODULE=fcitx GTK_IM_MODULE=fcitx
export PATH="$HOME/Apps/bin:$PATH"

xset -b
xrdb ~/.Xresource
xbacklight -set 65
#/usr/libexec/polkit-gnome-authentication-agent-1 &
#xbindkeys&
#trayer --widthtype pixel --width 200 --edge bottom --align left --transparent true &
#nm-applet &
menu2ctrl.bash &
罗技鼠标-m525.bash &
fcitx &
stardict &
#xcompmgr -CF &
urxvt -e tmux &
tray-volume.perl &
(waitForNetwork.perl && cairo-wallpaper.perl )&
#plasma-desktop
#sleep 2
#FvwmCommand 'Next (env) WarpToWindow 20 110'
#(sleep 1;xdotool click 1)&
#FvwmCommand 'Close'
#sleep 2
#FvwmCommand "All (urxvt) Maximize"
#sleep 3
conky &
#mlnet &
#switch-roll.bash default &

#xcompmgr -CcF -I-.015 -O-.03 -D6 -t-1 -l-3 -r4.2 -o.5 &
#trayer --widthtype pixel --width 200 --edge bottom --align left --transparent true &
#mkdir -p /tmp/dtach/
#test -e /tmp/dtach/fanqiang || dtach -n /tmp/dtach/fanqiang /bin/bash $HOME/应用/脚本/fq-loop &

#xterm -e screen &

#plasma-desktop
#FvwmCommand Focus

#nm-applet --sm-disable &

#FvwmCommand "Next (plasma-desktop) Nop"
#FvwmCommand "Next (plasma-desktop) Close"
#sleep 5

#FvwmCommand "All (urxvt) Maximize"
#FvwmCommand "All (screen) MoveToPage 1 1"
#FvwmCommand "All (screen) Maximize"
#pulseaudio &
#gnome-keyring-daemon &
#nm-applet --sm-disable &
#autoproxy -p 7456 &
#/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &
