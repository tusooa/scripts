#!/usr/bin/env perl

use 5.012;
use Term::ReadKey;

my @array = ();
my $ord = 0;
my $outMode = 0;
my $level = 0;

sub parseChar
{
    my $char = shift;
    given ($char)
    {
        when ('>') { $ord++ }
        when ('<') { $ord-- }
        when ('+') { $array[$ord]++ }
        when ('-') { $array[$ord]-- }
        when (',')
        {
            ReadMode 4;
            $array[$ord] = $outMode ? int ReadKey 0 : ord ReadKey 0;
            ReadMode 0;
        }
        when ('.')
        {
            print $outMode ? $array[$ord] : chr $array[$ord];
        }
        when ('[')
        {
            $level++;
            
        }
        when (']')
        {
            die "多出一个`]'\n";
        }
        default
        {
            # do nothing
        }
    }
}

my @chars = <>;
my @chars = split '', (join '', @chars);
for (@chars)
{
    parseChar $_;
}

