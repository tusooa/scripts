#!/usr/bin/env perl

use 5.012;
open PIPE, q{eix |grep -A2 '\[I\]'|} or die "Cannot open PIPE: $!\n";


local $/ = "--";
my $pkg = 0;
my @vcspkgs = ();
while (<PIPE>)
{
    my ($package, $installed);
    chomp;
    @_ = split /\n/;
    $package = $1 if $_[1] =~ /\[I\] ([^\s]+)/;
    $installed = $1 if $_[3] =~ /([0-9\.]+)/;
    if ($installed =~ /^9999+-?/)
    {
        push @vcspkgs, $package;
    }
    $pkg++;
    print "\e[0G". scalar @vcspkgs. "/$pkg";
    #say $package," ",$installed;
}

say undef;
say "VCS Packages: @vcspkgs";


