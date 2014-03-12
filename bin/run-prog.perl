#!/usr/bin/env perl

use 5.012;
#use Scripts::scriptFunctions;
use Term::ReadKey;
#my $cfg = conf 'run-prog.perl';

my @commands = (
    ['firefox', 'FvwmCommand', 'JumpExec Firefox firefox'],
    ['gimp', 'FvwmCommand', 'JumpExec GIMP gimp'],
    ['fvwm console', 'FvwmCommand', 'Module FvwmConsole'],
    ['evince', 'FvwmCommand', 'JumpExec "Document Viewer" evince'],
    ['filezilla', 'FvwmCommand', 'JumpExec FileZilla filezilla'],
    ['Emacs', 'FvwmCommand', 'RunEmacs'],
    ['snake-game', 'FvwmCommand', 'Exec exec xterm -geometry 60x40+0+0 -title SnakeGame -e sn-贪吃蛇.bash'],
);

ReadMode 4;
say 'Start program: ';
for (0..$#commands)
{
    say "$_\t$commands[$_][0]";
}
print '选择要启动的program: ';
my $num = -1;
while ($num<0 || $num>$#commands)
{
    $num = ReadKey 0;
}
ReadMode 0;
my $name = shift @{$commands[$num]};
say "选择了 $num\t$name";
say "\e[1;32m==> @{$commands[$num]}\e[0m";
exec @{$commands[$num]};
