#!/usr/bin/env perl

use Scripts::scriptFunctions;
use Getopt::Long qw/:config gnu_getopt/;
use POSIX qw/strftime/;
use 5.012;

sub help();
my $jpg = 0;
my $pause = 0;
GetOptions(
    'j|jpg' => \$jpg,
    'p|pause' => \$pause,
    'help' => \&help);

my $time = strftime '%Y-%m-%d-%H-%M-%S', localtime;
my $file = $jpg ? "snapshot-${time}.jpg" : "snapshot-${time}.png";
my @args;
@args = qw/-pause 5/ if $pause;

my $pictureDir = $pathConf->get ('picDir');
#"/usr/bin/import $args \"${Pictures}${file}\""
system 'import', @args, "$pictureDir$file";

system 'notice-msg', "截图完成，文件名: $pictureDir$file";

sub help ()
{
    say qq{Usage: screenshot.perl [options]
Options:
    --help                      Show this help
    -j, --jpg                   Use jpg format instead of png
    -p, --pause                 Pause 5s
};
    exit 0;
}
