#!/usr/bin/env perl
use Scripts::Base;
use Scripts::TextAlias::Parser;
my $file = shift @ARGV;
die unless $file;
my $code;
{
    open FILE, '<', $file or die "cannot open $file: $!\n";
    $code = join '', <FILE>;
    close FILE;
}
say 'parsing';
topEnv->scope->var('ARGS', [@ARGV]);
my $byte = ta->parse($code);
$byte->value(topEnv);

