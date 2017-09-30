#!/usr/bin/env perl
use 5.012;
@ARGV = ('import-dll.c');
binmode STDOUT, ':unix';
say '
package Scripts::Windy::MyPCQQ;
use 5.012;
use Exporter;
use Win32::API;
use Encode qw/encode decode/;
use utf8;
our @ISA = qw/Exporter/;
our @EXPORT = qw//;
our %func;
our $dllfile = "Message.dll";';
while (<>) {
    next unless /^typedef/;
    my ($type,$func,$rest) = /(int|char \*|bool|void) \(__stdcall \*Api_(.+?)_ptr\)\((.*)\);/;
    die unless $type;
    my @args = split /\s*,\s*/, $rest;
    $type = 'int' if $type eq 'bool';
    my @argNames = map { '__arg_'. $_ } 0..$#args;
    my $calling = $func . "(". (join ', ', map { $args[$_].' '.$argNames[$_] } 0..$#argNames) .")";
    print '$func{"'.$func.'"} = Win32::API::More->new($dllfile, "' ;
    say $type.' Api_'.$calling.'") or die "Cannot load func named '.$func.': $^E\n";';
    say 'sub '.$func;
    say '{';
    say '    $func{"'.$func.'"}->Call(@_);';
    say '}';
}
