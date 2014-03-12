#!/bin/bash

script="$(basename "$0")"
echo $script
echo $0
if [[ "$script" = *++* ]] ; then
    echo calling from symlink
    window="${script%%++*}"
    echo $window
    function runProgram
    {
        echo "${script#$window++}"
        eval "${script#$window++} &"
    }
else
    window="$1"
    shift
    function runProgram
    {
        "$@" &
    }
fi
if ! wmctrl -a "$window" ; then
    runProgram "$@"
fi
