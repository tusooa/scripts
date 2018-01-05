#!/usr/bin/env perl

use Scripts::Base;
use Getopt::Long qw/:config gnu_getopt/;

# 绝对路径的特征。考虑了 Windows。
my $absPathRegex = isWindows ? qr{(?:[A-Za-z]:)?/} : qr{/};
sub decideIfAbs;
# 使用颜色
my $color = -t STDOUT;
# 设定标志，若为defined则为设定模式，若undef则为获取模式
my $set = undef;
# 是否将命令行参数视为 GBK 编码。若为 Windows 则默认启用。
my $gbk = isWindows;
# 是否需要确认
my $confirm = undef;
# 是否使用绝对路径，要根据文件名判断
my $abs = undef;
# 输出 parse 之后的文件
my $printFile = 0;
GetOptions (
    'c|color' => \$color,
    'C|no-color' => sub { $color = 0; },
    'd|debug' => \$Scripts::scriptFunctions::debug,
    'F|print' => \$printFile,
    's|set=s' => \$set,
    'i|confirm' => \$confirm,
    'a|abs' => \$abs,
    'r|rel' => sub { $abs = 0; },
    'f|no-confirm' => sub { $confirm = 0; },
    'g|gbk' => \$gbk,
    'u|utf8' => sub { $gbk = 0; },
    'help' => sub { exit printHelp },
    ) or exit printHelp;
if (! defined $confirm) {
    $confirm = -t STDIN && not $printFile;
}
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
# 转化 Windows 的路径
isWindows and $file =~ s{\\}{/}g;
# 判定是否使用绝对路径
if (! defined $abs) {
    $abs = decideIfAbs $file;
}

my $conf = $abs ? Scripts::Configure->new($file) : conf $file;
my $realPath = $abs ? $file : $configDir.$file;
if (not defined $set) {
    if (@ARGV) {
        say -t STDOUT ? term $conf->get(@ARGV) : $conf->get(@ARGV);
    } elsif ($printFile) {
        print term $conf->outputFile;
    } else {
        printTree $conf;
    }
} else {
    if (not @ARGV) {
        die term "没有提供要修改的选项。\n";
    } else {
        if ($gbk) {
            $set = utf8 $set;
            @ARGV = map { utf8 $_ } @ARGV;
        }
        # Scripts::Configure 没有use utf8;
        _utf8_off($set);
        map { _utf8_off $_ } @ARGV;
        if (my $success = $conf->modify(@ARGV, $set)) {
            say term join('::', @ARGV), '将被修改为: ', $conf->get (@ARGV);
            if ($confirm) {
                say term '确定吗？[y/N]';
                chomp(my $choice = <STDIN>);
                if ($choice !~ /^y/) {
                    die term "已取消。\n";
                }
            }
            if ($printFile) { # 只输出修改后的文件，不实际修改
                say term "修改后的文件如下:";
                print term $conf->outputFile;
            } else {
                if (open my $f, '>', $realPath) {
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
}

# decideIfAbs EXPR
# EXPR 是一个 Unix 风格的文件名。
# 如果文件名以"./"，"../"开头，或者是绝对路径，则返回1。否则返回undef。
sub decideIfAbs
{
    shift =~ m{^(?:$absPathRegex|\./|\.\./)};
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
=head2 --help

输出帮助信息。
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

需要确认。默认是当标准输入是终端，且 -F 选项没有开启时才需要确认。
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
=head2 -a, --abs

不考虑 configDir。即：如果 FILE 是绝对路径，则按照绝对路径处理。如果 FILE 是相对路径，认为它在当前目录下。

默认当 FILE 是绝对路径，或者以"./"或"../"开头时启用。

在 Windows 下，路径中的 \ 会被自动转化成 /。
=cut
=head2 -r, --rel

总是认为 FILE 在 configDir 之下。
=cut
=head2 -F, --print

在获取模式中，输出排好序后的配置文件。输出内容应符合 config 的语法。

在设置模式中，把修改后的配置文件输出到标准输出，不修改原配置文件。
=cut
