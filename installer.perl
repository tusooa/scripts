#!/usr/bin/env perl

use lib 'lib';
use Getopt::Long;
use Scripts::Base;
use File::Path qw/make_path/;
use FindBin;
use if isWindows, 'Win32::Env';

my $prefix = isWindows ? "/usr/local" : "c:/Home/Programs/Scripts";
my $bindir;
my $libdir;
my $datadir;
my $confdir;
my $installHere = 0;
my $target = ENV_USER;
GetOptions(
    'prefix' => \$prefix,
    'bindir' => \$bindir,
    'libdir' => \$libdir,
    'datadir' => \$datadir,
    'confdir' => \$confdir,
    'here' => \$installHere,
    'system' => sub { $target = ENV_SYSTEM },
    'user' => sub { $target = ENV_USER },
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

make_path($configDir, $cacheDir);

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
print FILE $config->outputFile;
close FILE;

# default config dir
my $writeTo = $libdir.'/Scripts/Path/defConf.pm';
open WRITE, '>', $writeTo or die "Cannot open $writeTo: $!\n";
binmode WRITE, ':unix';
print WRITE 'our ';
print WRITE Data::Dumper->Dump(
    [unixPath $confdir.'/'],
    ['defConfDir']);
say WRITE '1;';
close WRITE;

if (isWindows) {
    InsertPathEnv($target, PATH => winPath $bindir);
    InsertPathEnv($target, PERL5LIB => winPath $libdir);
    BroadcastEnv;
} else {
    say "Add the following to your PATH:";
    say unixPath $bindir;
    say "Add the following to your PERL5LIB:";
    say unixPath $libdir;
}

final;

