#!/usr/bin/env perl

use 5.012;
my $run;
given ($ARGV[0])
{
    when ('server') { shift @ARGV; $run = 'Server'; }
    when ('client') { shift @ARGV; continue; }
    default { $run = 'Client'; }
}

eval "require Scripts::CardHover::$run";

Scripts::CardHover::${run}->run (@ARGV);
