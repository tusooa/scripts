#!/usr/bin/env perl
use Scripts::Base;
use Scripts::TextAlias::Parser;
use Getopt::Long;
my $code;
GetOptions('e=s' => \$code);
if (not $code) {
    my $file = shift @ARGV;
    die unless $file;
    open FILE, '<', $file or die "cannot open $file: $!\n";
    $code = join '', <FILE>;
    close FILE;
}
topEnv->scope->var('ARGS', [@ARGV]);
#ta->{maxdepth} = 100;
use Data::Dumper;
my $byte = ta->parse($code);
$byte->value(topEnv);

