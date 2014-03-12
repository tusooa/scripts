#!/bin/bash

if [ $(($RANDOM%2)) -eq 0 ] ; then
    cmd="sed 's/./&\҈/g'" #|ascii2uni -a D"
else
    cmd="sed 's/./&\҉/g'" #|ascii2uni -a D"
fi
cmd="$cmd""|sed 's/ÿ//g'"
if [ "$*" ] ; then
    eval 'echo "$@"|'"$cmd"
else
    eval "$cmd"
fi
