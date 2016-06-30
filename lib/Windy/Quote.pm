package Scripts::Windy::Quote;
use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/quote/;

sub quote
{
    bless shift, 'Scripts::Windy::Quote';
}

1;
