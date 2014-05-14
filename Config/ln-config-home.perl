#!/usr/bin/env perl

use 5.012;
use File::Basename qw/basename/;

while (<*>) {
    next if /~$/;
    next if $_ eq basename $0;
    my $target = $_;
    $target =~ s{\+}{/}g;
    $target = $ENV{HOME}.'/.'.$target;
    if (-l $target) {
        say "\e[1;34m==> unlink \e[0m$target";
        unlink $target;
    } elsif (-e $target) {
        say "\e[1;31m==> \e[0m$target\e[1;31m already exists, but it is not a symlink\e[0m";
        next;
    }
    say "\e[34m==> $target -> ".$ENV{PWD}."/$_\e[0m";
    symlink $ENV{PWD}."/$_", $target;
}
