package Scripts::scriptFunctions;
use Exporter;
use Scripts::Configure qw/$defg/;
use 5.014;
use File::Basename qw/basename dirname/;
no if $] >= 5.018, warnings => "experimental";
use Encode qw/encode decode _utf8_on _utf8_off/;
use POSIX qw/strftime/;
our $VERSION = 0.1;
our @ISA = qw/Exporter/;
our @EXPORT_OK = qw/$appsDir/;
our @EXPORT = qw/$home
$configDir $cacheDir $dataDir
$accountDir $scriptsDir $libDir
$verbose verbose $debug debug
conf $pathConf $defg $scriptName
multiArgs time2date final ln term
formatTime utf8 randFromTo
/;
use Scripts::WindowsSupport;
sub time2date;
sub multiArgs;
sub conf;
sub ln;
sub term;
sub final;
sub debug;
sub formatTime;

our $home = $^O eq 'MSWin32' ? $ENV{HOMEDRIVE}.$ENV{HOMEPATH} : $ENV{HOME};
our $scriptName= basename $0;
our $verbose   = 0;
our $debug     = 0;
# 目录，其名称最后一定要加上/，可能是eexp最差的一个设计了。然而却提升了伊的流动性。
my $xdgConf   = $ENV{XDG_CONFIG_HOME} ? "$ENV{XDG_CONFIG_HOME}/" : "$home/.config/";
our $configDir = "${xdgConf}Scripts/";
my $xdgCache  = $ENV{XDG_CACHE_HOME} ? "$ENV{XDG_CACHE_HOME}/" : "$home/.cache/";
our $cacheDir  = "${xdgCache}Scripts/";
our $defConfDir = $configDir . 'Default/';# 硬性编码
#say $defConfDir;
our $pathConf = conf 'scriptFunctions' // conf 'scriptpath';
our $appsDir   = $pathConf->get ('appsDir') // "$home/应用/";
our $dataDir   = $pathConf->get ('dataDir') // "${appsDir}数据/";
our $accountDir= $pathConf->get ('accountDir') // "$home/个人/账号/";
our $scriptsDir= $pathConf->get ('scriptsDir') // "${appsDir}脚本/";
our $libDir    = $pathConf->get ('libDir') // "${appsDir}库/脚本/";
#our $defConfDir= $pathConf->get ('defConfDir') // "${appsDir}默认配置/";
if (my $p = $pathConf->get ('addPath')) {
    debug "Adding path: $p";
    if ($^O eq 'MSWin32') {
        $ENV{PATH} = $p =~ s!/!\\!gr . ';' . $ENV{PATH};
    } else {
        $ENV{PATH} = $p . ':' . $ENV{PATH};
    }
    debug "Path now is: $ENV{PATH}";
}
sub time2date
{
    my @t = @_ ? @_ : localtime;
    my $year = $t[5] + 1900;
    my $month = $t[4] + 1;
    my $day = $t[3];
    "${year}-${month}-${day}";
}

sub multiArgs
{
#    say "@ARGV";say $ARGV[0];
    my @args;
    while (@ARGV) {
    # 不以-开头的参数，都记作多个参数。示例。g regex -f <f1 f2 f3> -- regex2
    # 详见grep.perl
    #        say "adding $ARGV[0]";
        #解决了如下bug:
        # g regex -f - file #其中file会被识别成正则的问题
        last if $ARGV[0] =~ /^-/ and ! ($ARGV[0] eq '-');
        push @args, (shift @ARGV);
    }
#    say "@args";
    @args;
}

sub conf
{
    my $file = shift // $scriptName;
    Scripts::Configure->new ($configDir.$file, $defConfDir.$file);
}

sub ln
{
    if ($^O eq 'MSWin32') {
        $winFunc{ln}->(@_);
    } else {
        my ($target, $name) = @_;
        symlink $target, $name;
    }
}

sub utf8
{
    my $str = join '', @_;
    my $ret;
    $ret = eval { decode 'GBK', $str };
    $ret = $str if $@;
    _utf8_on($ret);
    $ret;
    #$ret;
}

sub term #蛋痛的euc-cn <=> utf-8 转换。只有闻道死才需要。和谐。
{
    if ($^O eq 'MSWin32') {
        $winFunc{term}->(@_);
    } else {
        join '', @_;
    }
}

sub final
{
    say term "\n开始我们的战争\e[4D\e[1A\e[1;7;32mDate\e[0m\e[1B吧w";
}

sub debug
{
    if ($debug) {
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

sub formatTime
{
    @_ or @_ = localtime;
    my $ret = strftime("%Y,%m,%d (%w) %H,%M,%S", @_);
    $ret =~ s/\(0\)/(7)/;
    $ret;
}
#$pathConf = conf 'scriptpath'; #不加这，cairo-w就会出错。
#原因是之前没有指明默认配置在哪里

#sub main
#{
#    require Getopt::Long qw/:config gnu_getopt/;
#    my ($action, $conf);
#    GetOptions (
#        'c|test-conf=s' => sub { $conf});
#}

#if ($0 eq 'scriptFunctions.pm') {
#    main;
#}

sub randFromTo
{
    my ($min, $max) = @_;
    int(rand($max + 1 - $min)+$min);
}
1;
