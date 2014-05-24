#!/usr/bin/env perl

use 5.012;
use Term::ReadKey;

my @sessions = glob '/tmp/dtach/*';
my $p = -t STDOUT ? '' : 'xterm -e ';

system ('msg', 'attach.perl: 没有可连接的sock'),exit 1 if @sessions == 0;
system (qq{${p}dtach -a '$sessions[0]'}),exit 0 if @sessions == 1;

say '多个sock,数字选择:';
say "$_\t$sessions[$_]" for (0..$#sessions);
ReadMode 4;
my $num = -1;
while ($num<0 || $num>$#sessions)
{
    $num = ReadKey 0;
}
ReadMode 0;

say "socket $num\t$sessions[$num]";
system qq{${p}dtach -a '$sessions[$num]'};

