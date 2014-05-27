#!/usr/bin/env perl6

use Scripts::scriptFunctions;
use v6;

my $groupColor = "\e[1;32m";
my $entryColor = "\e[1;36m";
my $confColor = "\e[1;34m";
my $noColor = "\e[0m";
sub printTree ($hash, $groupStr)
{
    for %($hash).kv -> $name, $item {
        given ($item) {
            when ($_ ~~ Hash) {
                printTree $_, "$groupStr$name$noColor => $groupColor";
            }
            default {
                say "$groupStr$noColor$entryColor$name$noColor => $confColor$item$noColor";
            }
        }
    }
}

my $file;
given @*ARGS.elems {
    when m:P5/^[123]$/ {
        $file = shift @*ARGS;
    }
    default {
        die "错误。参数个数应介于1-3个，分别为：filename [[group] entry]\n";
    }
}

my $conf = conf $file;
#say $file; say $conf.confhash.perl;
if (@*ARGS) {
    #say "args";
    say $conf.get(@*ARGS);
} else {
    #say "no args";
    printTree $conf.confhash, $groupColor;
}
