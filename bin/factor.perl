#!/usr/bin/env perl

use 5.012;
sub f
{
    my $num = shift;
    for (2..($num-1)) {
        if ($num % $_ == 0) {
            return ($_, f($num/$_));
        }
    }
    ($num);
}

say join ' ', f shift;

