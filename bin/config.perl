#!/usr/bin/env perl

use Scripts::scriptFunctions;
use 5.012;
no if $] >= 5.018, warnings => "experimental";

my $groupColor = "\e[1;32m";
my $entryColor = "\e[1;36m";
my $confColor = "\e[1;34m";
my $noColor = "\e[0m";
sub printTree
{
    my $hash = shift;
    my $groupStr = shift;
    for my $name (sort { $a cmp $b } keys %$hash) {
        my $item = $hash->{$name};
        for (ref $item) {
            printTree ($item, "$groupStr$name$noColor => $groupColor") when 'HASH';
            default {
                say "$groupStr$noColor$entryColor$name$noColor => $confColor$item$noColor";
            }
        }
    }
}

my $file;
for (scalar @ARGV) {
    $file = shift when /^[123]$/;
    # 如下的写法怎么都不行。操。
    #when (\(1...3)) {
    #    say "$file = shift";
    #}
    default {
        die "错误。参数个数应介于1-3个，分别为：filename [[group] entry]\n";
    }
}

my $conf = conf $file;
if (@ARGV) {
    say $conf->get (@ARGV);
} else {
    my $confhash = $conf->hashref;
    printTree $confhash, $groupColor;
}
