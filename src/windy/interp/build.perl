#!/usr/bin/env perl

use ExtUtils::Embed;
use 5.012;
my $CC = 'gcc';
my $suffix = $^O eq 'MSWin32' ? 'dll' : 'so';
my $output = 'interp.'.$suffix;
my $source = 'perl.c';
system $CC . ' -shared -o ' . $output . ' ' . $source . ' ' . ccopts .' '. ldopts;
