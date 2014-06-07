#!/usr/bin/env perl

use 5.012;
use IO::Handle;
open PIPE, q{eix |grep -A2 '\[I\]'|} or die "Cannot open PIPE: $!\n";

local $/ = "--";
my $pkg = 0;
my @vcspkgs = ();
STDOUT->autoflush (1);
say "\e[1;32mSearching...\e[0;1;34m";
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

say "\e[0m";
say "\e[1;32mFound:\e[0m";
say "\t\e[1;4m$_\e[0m" for @vcspkgs;
say "按 Enter 进行更新，按 C-c 取消。";
<STDIN>;
say "  \e[1;34m=> \e[0;1;4memerge -av1 @vcspkgs\e[0m";
system 'emerge', '-av1', @vcspkgs;
say '完成!开始我们的战争(Date)吧---';
