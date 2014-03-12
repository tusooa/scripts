#!/usr/bin/env perl

use 5.010;

$ip = shift @ARGV;

print $ip;
open (who, '-|', 'whois', $ip) or die "管道无法打开: $!\n";

while(<who>){
    chomp;
    s/$&:\s*//,print " ► $_" if /^descr|^country/;
}
close who;

say '';

