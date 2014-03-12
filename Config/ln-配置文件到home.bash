#!/bin/bash

for i in .* ; do
    [[ $i == . || $i == .. || $i == *~ ]] || {
        target="$HOME/$(echo "$i" | sed -e 's@+@/@g')"
        if [[ -L $target ]] ; then
            # symlink
            cmd="rm -v $target"
            echo -e "\e[1;34m==> $cmd\e[0m"
            eval "$cmd"
        elif [[ -e $target ]] ; then
            echo -e "\e[1;31m==> $target exists, but it's not a symlink\e[0m"
            noexec=1
        fi
        [[ $noexec ]] || {
            cmd="ln -sfv $PWD/$i $target"
            echo -e "\e[1;34m==> $cmd\e[0m"
            eval "$cmd"
        }
    }
done

