#!/usr/bin env perl
use 5.012;
use Scripts::Base;
my $path = 'C:\Home\Programs\\';
chdir $path;
my $perl32 = 'perl32';
my $perl64 = 'perl64';
my $perlLink32 = 'perl5_32';
my $perlLink64 = 'perl5_64';
my $perlLink = 'perl5';

my $arch = shift;
die "Unknown arch: $arch\n" if $arch ne '32' and $arch ne '64';

my $curArch;
if (not -e $perlLink32) {
    $curArch = '32';
} elsif (not -e $perlLink64) {
    $curArch = '64';
} else {
    die "Current arch not found.\n";
}

if ($curArch eq $arch) {
    say "Already switched to $arch";
    exit;
}

my ($from1, $to1, $from2, $to2);
if ($arch eq '32') {
    $from1 = $perlLink;
    $to1 = $perlLink64;
    $from2 = $perlLink32;
    $to2 = $perlLink;
} elsif ($arch eq '64') {
    $from1 = $perlLink;
    $to1 = $perlLink32;
    $from2 = $perlLink64;
    $to2 = $perlLink;
}
system 'REN', $from1, $to1;
system 'REN', $from2, $to2;
final;
