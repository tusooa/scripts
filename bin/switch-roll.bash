#!/bin/bash

: '''
2 -> 23
6 -> 9
7 -> 2
9 -> 6
23 -> 7
'''
default ()
{
    echo 'set => default'
    notice-msg 'set => default' &
    xmodmap -e 'pointer = 1 23 3 4 5 9 2 8 6 10 11 12 13 14 15 16 17 18 19 20 21 22 7 24'
}

: '''
2 -> 23
4 -> 6
5 -> 7
6 -> 9
7 -> 2
9 -> 5
23 -> 4
'''
roll ()
{
    echo 'set => roll'
    notice-msg 'set => roll' &
    xmodmap -e 'pointer = 1 23 3 6 7 9 2 8 5 10 11 12 13 14 15 16 17 18 19 20 21 22 4 24'
}

switch ()
{
    if xmodmap -pp | grep '\<4\>\s*\<6\>' ; then # current: roll
        default
    else
        roll
    fi
}

case "$1" in
    default)default;;
    roll)roll;;
    *)switch;;
esac
