#!/bin/bash

scriptName=update-fvwm.bash
#pkgver=0.1
#. scriptFunctions

exec 6>"$HOME/.fvwm/f.window"
#exec 7>"$HOME/.fvwm/f.menu"

dsize()
{
    # dsize y x
    local num i j
    echo -en "\nDesktopSize ${1}x${2}" >&6
    (($1 * $2 > 9)) && return
    num=1;
    for i in $(seq 0 $[$1-1]) ; do
        for j in $(seq 0 $[$2-1]) ; do
            echo -en "\nKey $num W 4 PointerWindow MoveToPage $j $i" >&6
            ((num++))
        done
    done
}

ston()
{
    echo -en "\nStyle \"$1\" StartsOnPage $2 $3" >&6
    [[ "$4" == nosm ]] || echo -n ", SkipMapping" >&6
}

echo "# 请勿编辑此文件 用 $scriptName 自动创建" >&6

. "$HOME/.fvwm/c.window"
