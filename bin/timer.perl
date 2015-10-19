#!/usr/bin/env perl

use 5.012;
use warnings;
use Term::ReadKey;
use Scripts::scriptFunctions;
sub timeFormat;
ReadMode 3;

say term '按任意键开始';
ReadKey 0;

my $pid = fork;
die term "无法 fork: $!\n" if !defined $pid;
if ($pid) {
    while (1) {
        my $k;
        say term '按任意键暂停，空格计次';

        $k = ReadKey 0;
        if ($k eq ' ') {
            kill 'USR2', $pid;
        } else {
            kill 'USR1', $pid;
            say term '按任意键继续，q退出';
            $k = ReadKey 0;
            last if $k eq 'q';
            kill 'USR1', $pid;
        }
    }
    kill 'INT', $pid;
} else {
       $| = 1;
    my $p = 1;
    my $origTime = 0;
    my $startTime = time;
    my @times;
    $SIG{USR1} = sub {
        if ($p == 1) { # 暂停
            $origTime += time-$startTime;
            $p = 0;
            say q//;
        } else { # 继续
            $startTime = time;
            $p = 1;
        }
    };
    $SIG{USR2} = sub {
        push @times, time-$startTime+$origTime;
        say term (scalar @times)."次\t".(timeFormat $times[-1]);
    };
    $SIG{INT} = sub {
        final;
        say term '计时结果';
        say term "\e[1;3".($_ % 6 + 1)."m".($_+1)."次\e[0m\t".(timeFormat $times[$_]) for 0..$#times;
        say term "\e[1;4;42;37m最终\e[0m\t".(timeFormat $origTime);
        exit 0;
    };
    while (1) {
        print "\e[0G".(term timeFormat time-$startTime+$origTime) if $p;
        sleep 1;
    }
}

ReadMode 0;

sub timeFormat
{
    my $t = shift;
    my %formats;
    my %divs = (w => 60*60*24*7,
                d => 60*60*24,
                h => 60*60,
                m => 60);
    for (qw/w d h m/) {
        $formats{$_} = int $t / $divs{$_};
        $t -= $formats{$_} * $divs{$_};
    }
    $formats{s} = $t;
    my $p = 0;
    my $ret;
    for (qw/w d h m s/) {
        $p = 1 if $formats{$_} != 0;
        $ret .= $formats{$_} . $_ . ' ' if $p;
    }
    $ret;
}
