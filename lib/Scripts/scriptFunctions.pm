=encoding utf8
=cut
=head1 名称

Scripts::scriptFunctions - 一些基础函数
=cut

=head1 用法

use Scripts::scriptFunctions;

say term 'mewmewmew';
final;
=cut

=head1 概述

这个模块包括了 Scripts 里的通用函数，以及一些有用的变量。

默认情况下几乎所有的变量和函数都会被导出。
=cut
package Scripts::scriptFunctions;
use base 'Exporter';
use Scripts::Configure qw/$defg/;
use 5.014;
no if $] >= 5.018, warnings => "experimental";
use Encode qw/encode decode _utf8_on _utf8_off/;
use POSIX qw/strftime/;
use Pod::Text;
use Scripts::WindowsSupport;

our $VERSION = 0.1;
our @EXPORT = qw/
debug $defg
multiArgs time2date final ln
formatTime randFromTo debugOn debugOff
printHelp/;
push @EXPORT, @Scripts::WindowsSupport::EXPORT;
sub time2date;
sub multiArgs;
#sub ln;
sub final;
sub debug;
sub formatTime;
sub printHelp;
#%debug
#未被导出。它的键指示了一个模块名，而值表示在这个模块下是否开启调试输出。
#参见 C<函数> 一节的 C<debugOn> 和 C<debugOff>。

our %debug = ();
=head1 函数
=cut
=head2 time2date LIST
=cut
=head2 time2date

LIST 是一个时间数组(通常由 localtime 生成)。如果不带参数加以调用，默认为 localtime。

返回对应的日期，该日期的形式为YYYY-M-D。
=cut
sub time2date
{
    my @t = @_ ? @_ : localtime;
    my $year = $t[5] + 1900;
    my $month = $t[4] + 1;
    my $day = $t[3];
    "${year}-${month}-${day}";
}
=head2 multiArgs

用于 Getopt::Long。获取多个命令行参数，直到遇见下一个选项(C<-> 开头的字符串，但除去 C<-> 本身)。返回所获得的参数。

示例(取自 C<g>):

        GetOptions('file|f' => sub { @files = multiArgs }, 'end' => sub {});
        # 在命令行上
        $ g regex -f f1 f2 f3 --end regex2

上面的代码会将 f1 f2 f3 都放入 @files 里。这里，C<--end> 会终止 multiArgs 读取接下来的参数。
=cut
sub multiArgs
{
    my @args;
    while (@ARGV) {
        #解决了如下bug:
        # g regex -f - file #其中file会被识别成正则的问题
        last if $ARGV[0] =~ /^-/ and ! ($ARGV[0] eq '-');
        push @args, (shift @ARGV);
    }
    @args;
}
=head2 ln TARGET, NAME

创建从 TARGET 到 NAME 的链接。

在 Windows 系统下，将会使用 Windows 自带的软链接程序。可能需要管理员权限。
=cut
=head2 utf8df LIST

将 LIST 直接拼接后由 GBK 转化为 UTF-8 编码，并关闭 utf8 flag。返回转化后的字符串。
=cut
=head2 utf8 LIST

将 LIST 直接拼接后由 GBK 转化为 UTF-8 编码，并打开 utf8 flag。返回转化后的字符串。
=cut
=head2 gbk LIST

将 LIST 原样拼接后从 UTF-8 转化为 GBK。
=cut
=head2 term LIST

在 Windows 下，返回 gbk(LIST)。否则，将 LIST 原样拼接后返回。

在 Windows 下，当涉及终端输出和访问文件，且输出内容或文件名是 UTF-8 编码时，应该总是使用 term 函数。
=cut
=head2 final

打印一段信息，表示程序执行完满结束。

现在的讯息是取自 Date-A-Live 的。原意是表示任务开始。
=cut
sub final
{
    say term "\n开始我们的战争\e[4D\e[1A\e[1;7;32mDate\e[0m\e[1B吧w";
}
=head2 debugOn

在别的 package 中调用。启用这个 package 中的调试输出。
=cut
sub debugOn
{
    my $pack = (caller 0)[0];
    $debug{$pack} = 1;
}
=head2 debugOff

在别的 package 中调用。停用这个 package 中的调试输出。
=cut
sub debugOff
{
    my $pack = (caller 0)[0];
    $debug{$pack} = 0;
}
=head2 debug CODEREF
=cut
=head2 debug SCALAR

输出调试信息。仅在调试输出启用的时候，执行 CODEREF，或者输出 SCALAR。
=cut
sub debug
{
    my $pack = (caller 0)[0];
    if ($debug{$pack}) {
        for (ref (my $s = shift)) {
            when ('CODE') {
                $s->(@_);
            }
            default {
                say term $s;
            }
        }
    }
}
=head2 formatTime LIST
=cut
=head2 formatTime

LIST 为时间数组，默认为 localtime。返回以 C<YYYY,M,D (day-of-week) HH,MM,SS> 为格式的时间。
=cut
sub formatTime
{
    @_ or @_ = localtime;
    my $ret = strftime("%Y,%m,%d (%w) %H,%M,%S", @_);
    $ret =~ s/\(0\)/(7)/;
    $ret;
}
=head2 randFromTo MIN, MAX

返回属于 [MIN, MAX] 的随机整数。
=cut
sub randFromTo
{
    my ($min, $max) = @_;
    int(rand($max + 1 - $min)+$min);
}
=head2 isWindows

返回当前系统是否是 Windows。

这个函数是从 Scripts::WindowsSupport 里导入的。
=cut
=head2 printHelp

显示帮助。利用了 Pod::Text。
=cut
sub printHelp
{
    my $parser = Pod::Text->new;
    my $ret;
    $parser->output_string(\$ret);
    $parser->parse_file($0);
    print term $ret;
    1;
}
=head1 配置文件

配置文件都存放于 $configDir 下。

配置文件的结构包括组，子组和键-值对。

每个子组都应该属于一个组。

每个键-值对都应该属于一个组或子组，如果没有指定，则默认属于组 C<main>。

语法示例:

    key = value
    [group-name]
    key = value
    [group]:subgroup
    key = value

这个配置文件有三个组: main, group-name 和 group。其中，main 和 group-name 下各有一个键-值对，而 group 下有一个名为 subgroup 的子组。subgroup 下有一个键-值对。

不同的组(子组)中的键-值对可以同名而不会产生混淆。

在值中，可以通过 C<${VAR}> 引用环境变量 VAR；通过 C<$[GROUP::SUBGROUP::KEY]>, C<$[KEY]>, C<$[GROUP::KEY]> 引用另一个配置项的值。如果需要一个字面意义上的 C<$>，使用 C<${-}> 或 C<$[-]>。如果需要字面意义上的空格(用于值的首尾)，将空格用 C<${ }> 或 C<$[ ]> 包围起来。
=cut
1;
