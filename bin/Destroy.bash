#!/bin/bash

window="$(xprop -root _NET_ACTIVE_WINDOW | awk '{print $5}')"
pid="$(xprop -id "$window" | awk '{print $3}')"
kill -9 "$pid"
