#!/usr/bin/env perl

use Scripts::Base;
use Getopt::Long qw/:config gnu_getopt/;
my $color = -t STDOUT;
my $set = undef;
my $gbk = isWindows;
my $confirm = 1;
GetOptions (
    'c|color' => \$color,
    'C|no-color' => sub { $color = 0; },
    'd|debug' => \$Scripts::scriptFunctions::debug,
    's|set=s' => \$set,
    'i|no-confirm' => sub { $confirm = 0; },
    'g|gbk' => \$gbk,
    'u|utf8' => sub { $gbk = 0; },
) or die;
my ($groupColor, $entryColor, $confColor, $noColor) = ('','','','');
if ($color) {
    $groupColor = "\e[1;32m";
    $entryColor = "\e[1;36m";
    $confColor = "\e[1;37m";
    $noColor = "\e[0m";
}
sub printTree
{
    my $topLevel = shift;
    #warn "printTree $topLevel @_";
    for my $name ($topLevel->childList (@_)) {
        my $item = $topLevel->getGroup (@_, $name);
        for (ref $item) {
            printTree ($topLevel, @_, $name) when 'HASH';
            default {
                say term $groupColor . join ("$noColor => $groupColor", @_) . "$noColor => $entryColor$name$noColor => $confColor".$topLevel->get (@_, $name).$noColor;
            }
        }
    }
}

my $file;
for (scalar @ARGV) {
    $file = shift when /^[1234]$/;
    default {
        die term "错误。参数个数应介于1-4个，分别为：filename [[group [subgroup]] entry]\n";
    }
}

my $conf = conf $file;
if (not defined $set) {
    if (@ARGV) {
        say -t STDOUT ? term $conf->get(@ARGV) : $conf->get(@ARGV);
    } else {
        printTree $conf;
    }
} else {
    if (not @ARGV) {
        die term "没有提供要修改的选项。\n";
    } else {
        if ($gbk) {
            $set = utf8 $set;
        }
        _utf8_off($set);
        if (my $success = $conf->modify(@ARGV, $set)) {
            say term join('::', @ARGV), '将被修改为: ', $conf->get (@ARGV);
            if ($confirm) {
                say term '确定吗？[y/N]';
                chomp(my $choice = <STDIN>);
                if ($choice !~ /^y/) {
                    die term "已取消。\n";
                }
            }
            if (open my $f, '>', $configDir.$file) {
                binmode $f, ':unix';
                print $f $conf->outputFile;
                close $f;
                final;
            } else {
                die term "无法打开配置文件 $configDir${file}： $!\n";
            }
        }
    }
}
