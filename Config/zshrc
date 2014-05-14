#color{{{
autoload colors 
colors
for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
eval _$color='%{$terminfo[bold]$fg[${(L)color}]%}'
eval $color='%{$fg[${(L)color}]%}'
eval bg_$color='%{$bg[${(L)color}]%}'
(( count = $count + 1 ))
done
FINISH="%{$terminfo[sgr0]%}"
#}}}

. ~/.zsh/distro
. ~/.zsh/alias
. ~/.zsh/complete
. ~/.zsh/prompt
. ~/.zsh/paths
. ~/.zsh/misc
. ~/.zsh/env

typeset -U path fpath

if [ -f /etc/profile.d/autojump.zsh ] ; then
    . /etc/profile.d/autojump.zsh
fi

