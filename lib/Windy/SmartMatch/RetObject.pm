package Scripts::Windy::SmartMatch::RetObject;
use 5.012;
use Scripts::Windy::Util;
use Encode qw/_utf8_on _utf8_off/;
use Scripts::scriptFunctions;
use Scripts::Windy::SmartMatch::TextAlias;
use Scripts::TextAlias::Parser;
#debugOn;
sub new
{
    my $class = shift;
    my $match = shift;
    my $self = { match => $match };
    parse($self, @_);
    bless $self, $class;
}

sub parseSM
{
    my $self = shift;
    @_ or return;
    $self->{pattern} = [@_];
    $self->{parsed} = 1;
    $self;
}

sub parseTA
{
    my ($self, undef, $tree) = @_;
    $tree or return;
    my @list = @$tree;
    $self->{pattern} = [@list];
    $self->{parsed} = 1;
    $self;
}

sub selfParse
{
    my $self = shift;
    if ($self->{type} eq 'sm') {
        $self->parseSM($self->{match}->parse($self->{raw}));
    } elsif ($self->{type} eq 'ta') {
        debug 'parsing TA';
        $self->parseTA(ta->parseCommand($self->{raw}));
    } else {
        ###
    }
}

sub fromString
{
    my $class = shift;
    my $match = shift;
    my $str = shift;
    my $self = { raw => $str, parsed => 0, match => $match };
    unless ($self->{type}) {
        $self->{type} = isTALike($str) ? 'ta' : 'sm';
        debug "type is $self->{type}";
    }
    debug "$str added.";
    bless $self, $class;
}

sub part
{
    my $self = shift;
    $self->{part} = 1;
    $self;
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
    my @res;
    if ($object->{type} eq 'sm') {
        debug 'type is sm';
        @res = map { $self->runExpr($windy, $msg, $_, @_) } @{$object->{pattern}};
    } elsif ($object->{type} eq 'ta') {
        debug 'type is ta';
        my $env = msgTAEnv($windy, $msg);
        @res = map { ta->getValue($_, $env) } @{$object->{pattern}};
    } else {
        debug 'type unknown';
    }
    my $ret = join '', @res;
    _utf8_off($ret) if BACKEND eq 'mojo' and not $object->{part};
    $ret;
}

1;
