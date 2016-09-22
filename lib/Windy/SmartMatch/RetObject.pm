package Scripts::Windy::SmartMatch::RetObject;
use 5.012;
use Scripts::Windy::Util;
use Encode qw/_utf8_on _utf8_off/;
use Scripts::scriptFunctions;
sub new
{
    my $class = shift;
    my $match = shift;
    my $self = { pattern => [@_], match => $match };
    bless $self, $class;
}

sub run
{
    my $object = shift;
    my $self = $object->{match};
    my $windy = shift;
    my $msg = shift;
    # Evaluate if code
    # Plain text leave it as-is
    my $ret = join '', map { $self->runExpr($windy, $msg, $_, @_) } @{$object->{pattern}};
    _utf8_off($ret);
    $ret;
}

1;
