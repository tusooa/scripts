#!/usr/bin/env perl

use 5.012;
use Scripts::RageComics;
use Scripts::Base;
no warnings qw/expermental/;
my $net = "${scriptsDir}waitForNetwork.perl";
system { $net } $net;
given (my $ret = Scripts::RageComics->new->login) {
    say term '已经登录过了' when 1;
    final when 2;
    default { die term '登录出错' }
}
