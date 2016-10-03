package Scripts::Windy::SmartMatch::MatchObject;

use 5.012;
use Scripts::Windy::Util;
use Encode qw/_utf8_on _utf8_off/;
use Scripts::scriptFunctions;
use List::Util qw/all/;
no warnings 'experimental';
sub new
{
    my $class = shift;
    my $match = shift;
    my $data = ref $_[0] eq 'HASH' ? shift : {};
    my $self = { match => $match, %$data };
    parse($self, @_);
    bless $self, $class;
}

sub parse
{
    my $self = shift;
    my $textMatch = join '', grep { not ref $_ } @_;
    $textMatch = eval { qr/$textMatch/ };
    return if $@;
    my @cond = grep { ref $_ } @_;
    $self->{cond} = [@cond];
    $self->{pattern} = $textMatch;
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
    my $data = ref $_[0] eq 'HASH' ? shift : {};
    my $str = shift;
    my $self = { raw => $str, parsed => 0, match => $match, %$data, };
    bless $self, $class;
}

sub match
{
    my $object = shift;
    my $windy = shift;
    my $msg = shift;
    my $t = msgText ($windy, $msg);
    my $textMatch = $object->{pattern};
    _utf8_on($t);
    my @ret;
    given ($object->{style}) {
        when ('S') {
            my ($start, $end) = (msgPosStart($windy, $msg), msgPosEnd($windy, $msg));
            if (@ret = $t =~ $textMatch) {
                my $real_start = length $`;
                my $real_end = length $';
                if ($real_start > $start or $real_end > $end) {
                    @ret = ();
                }
            }
        }
        when ('s') {
            my ($start, $end) = (msgPosStart($windy, $msg), msgPosEnd($windy, $msg));
            $textMatch = qr/^.{0,$start}$textMatch.{0,$end}$/;
            @ret = $t =~ $textMatch;
        }
        default { @ret = $t =~ $textMatch; }
    }
    @ret;
}

sub run
{
    my $object = shift;
    my $self = $object->{match};
    if (not $object->{parsed}) {
        $object->selfParse;
    }
    my @pattern = @{$object->{cond}};
    my $windy = shift;
    my $msg = shift;
    my @ret = $object->match($windy, $msg);
    # 先执行regex，然后判定是否符合条件。
    if (@ret and (@pattern ? all { $self->runExpr($windy, $msg, $_, @_); } @pattern : 1)) {
        @ret;
    } else {
        ();
    }
}
1;
