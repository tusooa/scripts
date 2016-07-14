#!/usr/bin/env perl

#use 5.012;
use File::Temp qw/tempfile/;

my $emacsclient = 'C:\Home\usr\emacs-24.3\bin\emacsclientw.exe';
my $file = shift;
if (not $file) {
    my $fh;
    ($fh, $file) = tempfile;
    while (<STDIN>) {
        print $fh $_;
    }
    close $fh;
}

system $emacsclient, $file;
