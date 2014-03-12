#!/usr/bin/env perl

use 5.012;
use Scripts::scriptFunctions;
use Getopt::Long;

my $convert = 0;
GetOptions ('c' => \$convert);
my $picDir = $pathConf->get ('picDir');
my %files = map { $_ => (stat $_)[10] } glob "${picDir}snapshot-*";
my $file = (sort { $files{$b} <=> $files{$a} } keys %files)[0];

if ($convert)
{
    my $new = $file;$new =~ s/\.png$/.jpg/;
    system 'convert', $file, $new;
    system 'gimp', $new;
}
else
{
    system 'gimp', $file;
}

