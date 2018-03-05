#!/usr/bin/env perl

use lib 'lib';
use Getopt::Long;
use Scripts::Configure;
use Scripts::WindowsSupport;
use 5.012;
use utf8;
use File::Path qw/make_path/;
use FindBin;
use Encode qw/encode decode _utf8_on _utf8_off/;
use Data::Dumper;

sub utf8df
{
    my $str = join '', @_;
    my $ret;
    $ret = eval { decode 'GBK', $str };
    $ret = $str if $@;
    _utf8_off($ret);
    $ret;
}

sub term
{
    my $str = join '', @_;
    my $ret;
    eval { $ret = encode 'GBK', decode 'utf-8', $str };
    eval { $ret = encode 'GBK', $str } if $@;
    die "error: $@, @_" if $@;
    $ret;
}

my $prefix = isWindows ? "/usr/local" : "c:/Home/Programs/Scripts";
my $bindir;
my $libdir;
my $datadir;
my $confdir;
my $installHere = 0;
#my $target = ENV_USER;
GetOptions(
    'prefix' => \$prefix,
    'bindir' => \$bindir,
    'libdir' => \$libdir,
    'datadir' => \$datadir,
    'confdir' => \$confdir,
    'here' => \$installHere,
    #'system' => sub { $target = ENV_SYSTEM },
    #'user' => sub { $target = ENV_USER },
    );

$bindir //= "$prefix/bin";
$libdir //= "$prefix/lib";
$datadir //= "$prefix/share/Scripts";
$confdir //= isWindows ? "/etc/Scripts" : "$prefix/default-cfg";

if ($installHere) {
    $prefix = $FindBin::Bin;
    $bindir = "$prefix/bin";
    $libdir = "$prefix/lib";
    $datadir = "$prefix/Data";
    $confdir = "$prefix/default-cfg";
}
my $home = isWindows ? $ENV{HOMEDRIVE}.$ENV{HOMEPATH} : $ENV{HOME};
my $xdgConf = $ENV{XDG_CONFIG_HOME} ? "$ENV{XDG_CONFIG_HOME}/" : "$home/.config/";
my $configDir = utf8df "${xdgConf}Scripts/";
my $xdgCache = $ENV{XDG_CACHE_HOME} ? "$ENV{XDG_CACHE_HOME}/" : "$home/.cache/";
my $cacheDir = utf8df "${xdgCache}Scripts/";
say "creating config and cache directories...";
make_path($configDir, $cacheDir);
say "done.";

# paths
my $cfgFile = $confdir.'/syspath';
my $config = Scripts::Configure->new($cfgFile);
$config->modify('appsDir' => unixPath utf8df $prefix.'/');
$config->modify('dataDir' => unixPath utf8df $datadir.'/');
$config->modify('scriptsDir' => unixPath utf8df $bindir.'/');
$config->modify('libDir' => unixPath utf8df $libdir.'/');
$config->modify('addPath' => unixPath utf8df $bindir);
open FILE, '>', $cfgFile or die "cannot open $cfgFile: $!\n";
binmode FILE, ':unix';
my $out = $config->outputFile;
say "Config File: ";
print $out;
print FILE $out;
close FILE;
say "conf file ready.";

# default config dir
say "processing defconf...";
my $writeTo = $libdir.'/Scripts/Path/defConf.pm';
open WRITE, '>', $writeTo or die "Cannot open $writeTo: $!\n";
binmode WRITE, ':unix';
print WRITE 'our ';
print WRITE Data::Dumper->Dump(
    [unixPath $confdir.'/'],
    ['defConfDir']);
say WRITE '1;';
close WRITE;
say "done.";

if (isWindows) {
    say "installing environment variables...";
    addPathEnv PATH => $bindir;
    addPathEnv PERL5LIB => $libdir;
    #InsertPathEnv($target, PATH => winPath $bindir);
    #InsertPathEnv($target, PERL5LIB => winPath $libdir);
    say "done.";
} else {
    say "Add the following to your PATH:";
    say unixPath $bindir;
    say "Add the following to your PERL5LIB:";
    say unixPath $libdir;
}

#final;

