#compdef weather.perl

_arguments -s \
    '(-c --conky)'{-c,--conky}'[print as conky format]' \
    '(-t --term)'{-t,--term}'[print as terminal format]' \
    '(-u --uri)'{-u,--uri}'[weather uri]:uri: ' \
    '(-f --force --reload)'{-f,--force,--reload}'[force reload]' \
    '(-F --noforce --noreload)'{-F,--noforce,--noreload}"[don't reload]" \
#    '*:no arguments' && return 0
