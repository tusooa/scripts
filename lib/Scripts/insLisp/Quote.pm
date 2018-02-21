package Scripts::insLisp::Quote;

use base 'Exporter';
use Scripts::Base;
use Scripts::insLisp::Symbol;

our @EXPORT = qw/quote/;
our $quoteSym = Scripts::insLisp::Symbol->new('quote');
sub quote
{
    my $arg = shift;
    [$quoteSym, $arg];
}

1;
