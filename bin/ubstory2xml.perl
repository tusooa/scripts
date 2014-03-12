#!/usr/bin/env perl

use 5.012;
use Getopt::Long;

my $title = 1;
GetOptions (
    'T|notitle' => sub { $title = 0; },
);

my $text = "  <article>\n";
while (<>)
{
    chomp;
    if ($title && /^\s*(?:\(|（)\d+(?:）|\))\s*(.+)\s*$/)
    {
        $text .= "    <title>$1</title>\n";
        $title = 0;
    }
    elsif (!/^\s*$/)
    {
        $text .= "    <para>\n$_\n    </para>\n";
    }
}
$text .= "  </article>\n";

open XSEL, '|-', 'xsel', '-i' or die "不能打开管道: $!\n";
say XSEL $text;
close XSEL;
