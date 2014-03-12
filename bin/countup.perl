#!/usr/bin/env perl

use 5.012;
use Scripts::scriptFunctions;
use Scripts::TimeDay;
use POSIX qw/strftime/;

sub record
{
    my ($item, @command) = @_;
    my $cache = conf 'countup.cache';
    my @file;
    my $now = strftime "%Y-%m-%d", localtime time;
    my $found = 0;
    #my ($year, $month, $day) = ($t[5]+1900,$t[4]+1,$t[3]
    for (keys %{$cache->hashref->{$defg}})
    {
        my $line = '';
        if ($item eq $_)
        {
            $line = "$_ = $now";
            $found = 1;
        }
        else
        {
            $line = "$_ = ".$cache->get($_);
        }
        push @file, $line;
    }
    $found or push @file, "$item = $now";
    open CACHE, '>', "${configDir}countup.cache" or die "Cannot open cache: $!\n";
    say CACHE $_ for @file;
    close CACHE;
    if (@command)
    {
#        print "@command";
        system @command;
    }
    else
    {
        say "提醒下。你这啥命令都没给，只假装作了个countup啊。";
    }
}

if (@ARGV)
{
    record @ARGV;
    exit;
}

my $config = conf 'countup.perl';
my $cache = conf 'countup.cache';
my $now = Scripts::TimeDay->now;
for (keys %{$config->hashref->{$defg}})
{
    my $str = $cache->get ($_) or next;
    my $last = Scripts::TimeDay->newFromString ($str);
#    say "@$last";
    my $name = $config->get ($_) // "开$_";
    my $past = timeDiff ($last, $now) - 1;
    #say $past;
    if ($past > 0) #灵异事件。合在一起写不行。
    {
        say "${past}天没${name}了";
    }
    elsif ($past == 0)
    {
        say "昨天刚${name}";
    }
}
