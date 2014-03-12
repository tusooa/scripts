#!/bin/bash

#FvwmCommand 'Current Exec exec xprop -id $[w.id] _NET_WM_PID'
pid="$1"
child="$(ps -o pid,ppid ax | awk "{ if ( \$2 == $pid ) { print \$1; exit }}")"
