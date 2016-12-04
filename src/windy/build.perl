#!/usr/bin/env perl
use 5.012;

my $cxx = 'g++';
my $CFLAGS = "-shared -static -static-libgcc  -Wl,-Bstatic -lstdc++ -pthread -std=gnu++11 -Wall -ISimple-Web-Server -Iport";
my $boost = $ENV{BOOST_ROOT} || "C:/Home/Programs/boost-install";
my $tc = "mgw49";
my $boostVer = '1_62';
my $incPath = "$boost/include/boost-$boostVer";
my $realIncPath = $incPath;
#$realIncPath =~ s|/|\\|g;
$CFLAGS .= qq/ -I"$realIncPath"/;

my $libPath = "$boost/lib";
$CFLAGS .= qq/ -L"$libPath"/;
my $libPrefix = '-lboost_';#$libPath.'/libboost_';
my $libSuffix = "-${tc}-mt-s-${boostVer}";#.a";
for my $lib (qw/system thread filesystem date_time/) {
    my $actualPath = "$libPrefix$lib$libSuffix";
    #$actualPath =~ s|/|\\|g;
    $CFLAGS .= qq/ "$actualPath"/;
}
$CFLAGS .= ' -lws2_32 -lwsock32';
my $source = 'windy.cpp';
my $output = 'windy.xx.dll';
my $cmd = qq/"$cxx" -o "$output" $source $CFLAGS/;
say $cmd;
system $cmd;
