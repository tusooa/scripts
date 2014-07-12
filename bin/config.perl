#!/usr/bin/env perl

use Scripts::scriptFunctions;
use 5.012;
no if $] >= 5.018, warnings => "experimental";
use Getopt::Long qw/:config gnu_getopt/;
my $color = -t STDOUT;
GetOptions (
    'c|color' => \$color,
    'C|no-color' => sub { $color = 0 },
    'd|debug' => \$Scripts::scriptFunctions::debug,
);
my ($groupColor, $entryColor, $confColor, $noColor) = ('','','','');
if ($color) {
    $groupColor = "\e[1;32m";
    $entryColor = "\e[1;36m";
    $confColor = "\e[1;34m";
    $noColor = "\e[0m";
}
sub printTree
{
    my $topLevel = shift;
    #warn "printTree $topLevel @_";
    for my $name (sort $topLevel->getGroups (@_)) {
        my $item = $topLevel->getGroup (@_, $name);
        for (ref $item) {
            printTree ($topLevel, @_, $name) when 'HASH';
            default {
                say $groupColor . join ("$noColor => $groupColor", @_) . "$noColor => $entryColor$name$noColor => $confColor".$topLevel->get (@_, $name).$noColor;
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
    printTree $confhash;
}
