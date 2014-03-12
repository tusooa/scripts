#!/usr/bin/env perl

use 5.012;
use Encode qw/decode_utf8/;
use encoding 'utf8';

my $text = join ' ', @ARGV;
$text = decode_utf8 $text;
my $len = length $text;
my @arr = split '', $text;
my $col = int sqrt $len;
my $row = int $len / $col;
$row++ if $len % $col;
my $sep = '|';
my @new;# = map [], (0..$col-1);
=comment
1234567 =>
   0 1 2 3
   -------
0 |1 2 3 4
1 |5 6 7
(1,0)(0,0)
(1,1)(0,1)
(1,2)(0,2)
(1,3)(0,3)
=cut
for my $i (0..$col-1)
{
    my @line = map $arr[$i*$row+$_], (0..$row-1);
    push @new, [@line];
}

#for my $i (0..$#new)
#{
#    say "\$new[$i]:@{$new[$i]}";
#}

for my $i (0..$row-1)
{
    for my $j (reverse 0..$col-1)
    {
        $new[$j]->[$i] //= ' ';
        $new[$j]->[$i] =~ s/([a-zA-Z0-9`~!@#$%^&*()\-_+=\[\]{}\\|;:'",.\/<>? ])/$1 /;
        print $new[$j]->[$i].'|';
    }
    say "\b ";
}
__END__
for my $i (0..$col)
{
    for my $j (0..$row)
    {
        print $new[$j]->[$i];
    }
    say undef;
}

__END__
for (0..$row-1)
{
    my @line;
    for my $num (0..$col-1)
    {
        $line[$num] = $arr[$num*$col+$_];
        $line[$num] =~ s/([a-zA-Z0-9`~!@#$%^&*()\-_+=\[\]{}\\|;:'",.\/<>?])/$1 /;
    }
    say join '|', reverse @line;
}


