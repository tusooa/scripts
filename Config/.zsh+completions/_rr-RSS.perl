#compdef rr-RSS.perl

_arguments -s \
    '(-c --conky)'{-c,--conky}'[use conky-style colorized output]' \
    '(-t --ansi-term)'{-t,--ansi-term}'[use ansi-term-style colorized output]' \
    '(-r --rss)'{-r,--rss}'[use rss format]' \
    '(-a --atom)'{-a,--atom}'[use atom format]' \
    '(-u --custom)'{-u,--custom}'[use custom web uri]:*:title or uri' \
    '(-m --max)'{-m,--max}'[define the max number of items]:number: ' \
    '(-p --proxy)'{-p,--proxy=}'[use specialized proxy]:proxy: ' \
    '(-a --user-agent)'{-a,--user-agent=}'[use specialized string as user-agent]:user-agent' \
    '--help[show help]' \
    '--version[show version]' \
    '*: :_guard "^-*" "short name"'
#    '1:short name for the website:(hsyyf coolshell adam)'

