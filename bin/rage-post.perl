#!/usr/bin/env perl

use 5.012;
use WWW::Mechanize::Firefox;

my $net = "${scriptsDir}waitForNetwork.perl";
system { $net } $net;


