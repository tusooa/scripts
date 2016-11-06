#!/usr/bin/env perl
use 5.012;

my $cxx = 'g++';
my $CFLAGS = "-pthread -std=gnu++11 -Wall -ISimple-Web-Server";
my $boost = $ENV{BOOST_ROOT} || "C:/Home/Programs/boost-install";
my $tc = "mgw49";
my $boostVer = '1_62';
my $incPath = "$boost/include/boost-$boostVer";
my $realIncPath = $incPath;
#$realIncPath =~ s|/|\\|g;
$CFLAGS .= qq/ -I"$realIncPath"/;
my $libPath = 'C:/Home/Programs/boost/stage/lib';#"$boost/lib";
my $libPrefix = $libPath.'/libboost_';
my $libSuffix = "-${tc}-mt-${boostVer}.dll";
for my $lib (qw/regex system thread date_time/) {
    my $actualPath = "$libPrefix$lib$libSuffix";
    #$actualPath =~ s|/|\\|g;
    $CFLAGS .= qq/ "$actualPath"/;
}
$CFLAGS .= ' -lws2_32 -lwsock32';
my $source = 'windy.cpp';
my $output = 'windy.exe';
my $cmd = qq/"$cxx" -o "$output" $source $CFLAGS/;
say $cmd;
system $cmd;
