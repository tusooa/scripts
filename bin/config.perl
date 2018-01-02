#!/usr/bin/env perl

use Scripts::Base;
use Getopt::Long qw/:config gnu_getopt/;
use Pod::Usage;
my $color = -t STDOUT;
my $set = undef;
my $gbk = isWindows;
my $confirm = -t STDIN;
GetOptions (
    'c|color' => \$color,
    'C|no-color' => sub { $color = 0; },
    'd|debug' => \$Scripts::scriptFunctions::debug,
    's|set=s' => \$set,
    'i|confirm' => \$confirm,
    'f|no-confirm' => sub { $confirm = 0; },
    'g|gbk' => \$gbk,
    'u|utf8' => sub { $gbk = 0; },
) or pod2usage(-verbose => 3, -exitval => 1);
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
=encoding utf8
=cut
=head1 名称

config.perl - 读取和修改配置文件
=cut
=head1 用法

    config.perl [options ...] FILE [[GROUP [SUBGROUP]] KEY]
    config.perl [options ...] -s | --set VALUE FILE [GROUP [SUBGROUP]] KEY

当参数只有文件名时，显示这个文件里所有的配置信息。

当参数包括了文件名、组、子组和键时，显示对应的值。

当 -s 参数被指定时，改变相应配置。

=cut
=head1 选项
=cut
=head2 -c, --color

显示颜色。默认是当标准输出是终端时才显示颜色。
=cut
=head2 -C, --no-color

不显示颜色。
=cut
=head2 -d, --debug

启用调试输出。默认关闭。
=cut
=head2 -s VALUE, --set=VALUE

将配置项的值设定为 VALUE。
=cut
=head2 -i, --confirm

需要确认。默认是当标准输入是终端时才需要确认。
=cut
=head2 -f, --no-confirm

不需要确认。
=cut
=head2 -g, --gbk

认为命令行传来的参数是 GBK 编码的。在 Windows 下默认开启。
=cut
=head2 -u, --utf8

认为命令行传来的参数是 UTF-8 编码的。
=cut
