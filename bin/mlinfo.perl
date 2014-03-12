#!/usr/bin/env perl

use 5.012;
use Getopt::Long qw/:config bundling/;
my ($nocol, $conky, $short);
-t STDOUT or $conky = 1;
GetOptions ('nocol' => \$nocol, 'c' => \$conky, 's'=>\$short);
my $shortLen=10;
open STDERR, ">/dev/stdout" or die "Cannot open stderr: $!\n";
use LWP::Simple;
$_ = get 'http://localhost:4080/submit?q=vd';
die "Couldn't get it!\n" unless defined $_;
/<table.*\/table>/s;
use HTML::TableExtract;
my $te = HTML::TableExtract->new (depth => 1, count => 1);
$te->parse($&);
for my $ts ($te->tables)
{
    for my $row ($ts->rows)
    {
        next if ! @$row[5];
        if ($short) {@$row[5]=substr(@$row[5],0,$shortLen);}
        if ($nocol)
        {
            $_ = "@$row[5]\t@$row[8]%\t@$row[15]KB/s";
        }
        elsif ($conky)
        {
            $_ = "\${color2}@$row[5]\t\${color1}@$row[8]%\t@$row[15]KB/s\${color}";
        }
        else
        {
            $_ = "\e[4;32;40m@$row[5]\t\e[4;31m@$row[8]%\t@$row[15]KB/s\e[0m";
        }
        s/\s*\t/\t/gs;
        say;
    }
}
close STDERR;
