package Scripts::Windy::SmartMatch::MatchObject;

use 5.012;
use Scripts::Windy::Util;
use Encode qw/_utf8_on _utf8_off/;
use Scripts::scriptFunctions;
use List::Util qw/all/;
sub new
{
    my $class = shift;
    my $match = shift;
    my $textMatch = join '', grep { not ref $_ } @_;
    $textMatch = qr/$textMatch/; ### 加上这句之后反应速率提高数百倍
    my @cond = grep { ref $_ } @_;
    my $self = { cond => [@cond], pattern => $textMatch, match => $match };
    bless $self, $class;
}

sub run
{
    my $object = shift;
    my $self = $object->{match};
    my @pattern = @{$object->{cond}};
    my $textMatch = $object->{pattern};
    my $windy = shift;
    my $msg = shift;
    my $t = msgText ($windy, $msg);
    _utf8_on($t);
    debug 'match pattern:'.$textMatch;
    my @ret = $t =~ $textMatch; ###这实在是太奇怪了。
    # 先执行regex，然后判定是否符合条件。
    if (@ret and (@pattern ? all { $self->runExpr($windy, $msg, $_, @_); } @pattern : 1)) {
        @ret;
    } else {
        ();
    }
}
1;
