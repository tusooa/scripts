#!/usr/bin/env perl

use 5.016;
use Scripts::scriptFunctions;
#use LWP::UserAgent;
use LWP::Simple;
use utf8;

my $file = 'f:/Pictures/design_331581.xml';
# lower case
$file =~ s<^([A-Za-z]):></media/\L${1}\Edisk> if $^O ne 'MSWin32'; # /media/fdisk, see /etc/fstab
my $dir = 'f:/Pictures/暴漫/smilies/';
$dir =~ s<^([A-Za-z]):></media/\L${1}\Edisk> if $^O ne 'MSWin32'; # /media/fdisk, see /etc/fstab
open FILE, '<', term $file or die "cannot open file $file: $!\n";

while (<FILE>) {
    chomp;
    m!<imagePath>(.+)</imagePath>! or next;
    my $url = $1;
    $url =~ m!/(\d+/\d+\..+)$! or next;
    my $filename = $1 =~ s!/!,!rg;
    say term "get $url -> $dir$filename";
    my $content = getstore $url, term $dir.$filename;
    say 'done';
}
close FILE;
final;

