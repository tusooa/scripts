#!/usr/bin/env perl
use 5.018;
use Scripts::scriptFunctions qw/term $home $configDir $pathConf/;
use Scripts::Configure;
use File::Basename;
use Getopt::Long;
use File::Path qw/make_path/;
my $accountDir;
my $defaultAccountDir = $home.'/Documents/Account/';
GetOptions('a=s', \$accountDir);
-d $configDir or make_path($configDir);

my $conf = $pathConf;
#unless ($pathConf->get('appsDir')) {
if (! $accountDir) {
    say term "账号应该放在哪儿[$defaultAccountDir]? ";
    chomp ($accountDir = <STDIN>);
    length $accountDir or $accountDir = $defaultAccountDir;
    $accountDir =~ s#\\#/#g;
    $accountDir =~ s#(?<!/)$#/#;
}
my $appsDir = ((dirname dirname $0) =~ s#\\#/#gr) . '/';
$pathConf->modify('appsDir', $appsDir);
$pathConf->modify('scriptsDir', '$[appsDir]bin/');
$pathConf->modify('dataDir', '$[appsDir]Data/');
$pathConf->modify('accountDir', $accountDir);
$pathConf->modify('libDir', '$[appsDir]lib/');
$pathConf->modify('addPath', '$[appsDir]bin');
say $pathConf->outputFile;
#}
