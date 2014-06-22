#!/usr/bin/env perl

use 5.016;
use Scripts::scriptFunctions;
#use LWP::UserAgent;
use LWP::Simple;
use utf8;
my $file = '/media/fdisk/Pictures/design_331581.xml';
#$file =~ s<^([A-Za-z]):></media/${1}disk> if $^O ne 'MSWin32'; # /media/fdisk, see /etc/fstab
my $dir = '/media/fdisk/Pictures/暴漫/smilies/';
open FILE, '<', $file or die "cannot open file $file: $!\n";
while (<FILE>) {
    chomp;
    m!<imagePath>(.+)</imagePath>! or next;
    my $url = $1;
    $url =~ m!/(\d+/\d+\..+)$! or next;
    my $filename = $1 =~ s!/!,!rg;
    say "get $url -> $dir$filename";
    my $content = getstore $url, $dir.$filename;
    say 'done';
}
close FILE;
final;

