#!/usr/bin/env perl

use 5.012;
my $CC = 'g++';
my $suffix = $^O eq 'MSWin32' ? 'dll' : 'so';
my $output = 'group-add.'.$suffix;
my $source = 'group-add.cpp';
my $CFLAGS = '-I../port -IC:/Home/Programs/boost-install/include/boost-1_62';

system "$CC @ARGV -shared -o $output $source $CFLAGS";
