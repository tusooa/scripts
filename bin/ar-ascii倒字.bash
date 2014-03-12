#!/bin/bash

regex='y/abcdefghijklmnopqrstuvwxyzɐqɔpǝɟƃɥᴉḷʞȷɯuodbɹsʇnʌʍxʎz:;.!?:؛˙¡¿/ɐqɔpǝɟƃɥᴉḷʞȷɯuodbɹsʇnʌʍxʎzabcdefghijklmnopqrstuvwxyz:؛˙¡¿:;.!?/'
if [ "$*" ] ; then
    echo $* | sed "$regex" | rev
else
    sed "$regex" | rev
fi
