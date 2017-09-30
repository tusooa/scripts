#!/usr/bin/env perl
use Scripts::Base;
use File::Basename;

my $oneDriveDir = $home . '/OneDrive/w/';
for (<${oneDriveDir}*>) {
    ln $_, basename $_;
}
final;
