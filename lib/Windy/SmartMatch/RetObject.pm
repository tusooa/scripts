package Scripts::Windy::SmartMatch::RetObject;
use 5.012;
use Scripts::Windy::Util;
use Encode qw/_utf8_on _utf8_off/;
use Scripts::scriptFunctions;
sub new
{
    my $class = shift;
    my $match = shift;
    my $self = { match => $match };
    parse($self, @_);
    bless $self, $class;
}

sub parse
{
    my $self = shift;
    $self->{pattern} = [@_];
    $self->{parsed} = 1;
    $self;
}

sub selfParse
{
    my $self = shift;
    $self->parse($self->{match}->parse($self->{raw}));
}

sub fromString
{
    my $class = shift;
    my $match = shift;
    my $str = shift;
    my $self = { raw => $str, parsed => 0, match => $match };
    bless $self, $class;
}

sub run
{
    my $object = shift;
    my $self = $object->{match};
    if (not $object->{parsed}) {
        $object->selfParse;
    }
    my $windy = shift;
    my $msg = shift;
    # Evaluate if code
    # Plain text leave it as-is
    my $ret = join '', map { $self->runExpr($windy, $msg, $_, @_) } @{$object->{pattern}};
    _utf8_off($ret);
    $ret;
}

1;
