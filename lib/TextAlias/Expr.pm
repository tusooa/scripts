package Scripts::TextAlias::Expr;
use utf8;
use 5.012;
use Scripts::scriptFunctions;
debugOn;

sub new
{
    my ($class, $ta, $text) = @_;
    my $self = {
        parser => $ta,
        var => {},
        list => [],
    };
}

1;
