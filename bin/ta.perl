#!/usr/bin/env perl
use Scripts::Base;
use Scripts::TextAlias::Parser;
use Getopt::Long;
my $code;
GetOptions('e=s' => \$code);
my $running = '-e';
if (not $code) {
    my $file = shift @ARGV;
    die unless $file;
    open FILE, '<', $file or die "cannot open $file: $!\n";
    $code = join '', <FILE>;
    close FILE;
    $running = $file;
}
my $a = [@ARGV];
topEnv->scope->var('-args-', $a);
topEnv->scope->var('ARGS', $a);
topEnv->scope->var('-running-', $running);
#ta->{maxdepth} = 100;
use Data::Dumper;
my $byte = ta->parse($code);
$byte->value(topEnv);

