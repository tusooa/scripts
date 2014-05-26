module Scripts::scriptFunctions;
#use Exporter;
use v6;
use Scripts::Configure;
#use File::Basename qw/basename/;
#our $VERSION = 0.1;
#our @ISA = qw/Exporter/;
#our @EXPORT_OK = qw/$appsDir/;
#our @EXPORT = qw/
#$configDir $cacheDir $dataDir
#$accountDir $scriptsDir $libDir
#$verbose verbose $debug debug
#conf $pathConf $defg $scriptName
#multiArgs time2date
#/;

#our $scriptName= basename $0;
#our $verbose   = 0;
#our $debug     = 0;
my $xdgConf   = %*ENV<XDG_CONFIG_HOME> ?? "%*ENV<XDG_CONFIG_HOME>/" !! "%*ENV<HOME>/.config/";
our $configDir is export = "{$xdgConf}Scripts/";
my $xdgCache  = %*ENV<XDG_CACHE_HOME> ?? "%*ENV<XDG_CACHE_HOME>/" !! "%*ENV<HOME>/.cache/";
our $cacheDir is export  = "{$xdgCache}Scripts/";

our $pathConf is export = Scripts::Configure.new;
$pathConf.parseConf(fn => $configDir~'scriptpath', defc => '/dev/null');

our $appsDir is export  = $pathConf.get('appsDir') // "%*ENV<HOME>/Apps/";
our $dataDir is export  = $pathConf.get('dataDir') // "{$appsDir}Data/";
our $accountDir is export= $pathConf.get('accountDir')// "%*ENV<HOME>/Accounts/";
our $scriptsDir is export= $pathConf.get('scriptsDir') // "{$appsDir}bin/";
our $libDir    is export = $pathConf.get('libDir') // "{$appsDir}lib/";
our $defConfDir is export= $pathConf.get('defConfDir') // "{$appsDir}default-cfg/";

sub time2date ($date = DateTime.now) is export
{
    "{$date.year}-{$date.month}-{$date.day}";
}

sub multiArgs is export
{
#    say "@ARGV";say $ARGV[0];
    my @args;
    while (@*ARGS) {
    # 不以-开头的参数，都记作多个参数。示例。g regex -f <f1 f2 f3> -- regex2
    # 详见grep.perl
    #        say "adding $ARGV[0]";
        #解决了如下bug:
        # g regex -f - file #其中file会被识别成正则的问题
        last if @*ARGS[0] ~~ m:P5/^-/ and ! (@*ARGS[0] eq '-');
        push @args, (shift @*ARGS);
    }
#    say "@args";
    @args;
}

sub conf ($file) is export
{
    my $conf = Scripts::Configure.new;
    $conf.parseConf(fn => $configDir~$file, defc => $defConfDir~$file);
    $conf;
}

$pathConf = conf('scriptpath');
#不加这，cairo-w就会出错。
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

