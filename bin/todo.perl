#!/usr/bin/env perl

use 5.012;
use Scripts::ToDo;
use Scripts::scriptFunctions;
use Getopt::Long;

GetOptions ('a|all' => \$Scripts::ToDo::showAll);

my $todoFile = "${accountDir}todo";
my $todo = Scripts::ToDo->new ($todoFile)
    or die "无法打开todo文件 `$todoFile'\n";
given ($ARGV[0])
{
    $todo->printList when 'p';
    $todo->printList when 'l';
    $todo->add (@ARGV[1..$#ARGV]) when 'a';
    $todo->remove (@ARGV[1..$#ARGV]) when 'r';
#    $todo->emergency (@ARGV[1..$#ARGV]) when 'e';
    $todo->done (@ARGV[1..$#ARGV]) when 'd';
    $todo->undone (@ARGV[1..$#ARGV]) when 'u';
    $todo->modify (@ARGV[1..$#ARGV]) when 'm';
    $todo->printConky when 'c';
    default
    {
        $todo->printList;
    }
}
$todo->save;

