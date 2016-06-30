package Scripts::Windy::Conf::smartmatch;
use 5.012;
no warnings 'experimental';
use Scripts::Windy::Addons::Nickname;
use Scripts::Windy::SmartMatch;
use Scripts::Windy::Quote;
use Scripts::Windy::Util;
use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/$match sm sr/;
loadNicknames;
our $match;
my $myName = qr/(?:小|西)?风(?:妹(?:子|儿|砸|妹)?|儿|酱|姐{1,2})/;
my $If = qr/(?:(?:如)?若|如果)/;
my $Then = qr/(?:则|那么)/;
my $Else = qr/(?:不然|否则)(?:的话)?/;
my $subs = {
#    AsIs => quote(sub {
#        my $windy = shift;
#        my ($msg, $m1) = @_;
#        my $m = expr $m1;
#        $m->($windy, $msg)
#    }),
    IfThenElse => quote(sub {
        my ($self, $windy, $msg, $m1, $m2, $m3) = @_;
        if ($self->runExpr($windy, $msg, $m1)) {
            $self->runExpr($windy, $msg, $m2);
        } else {
            $self->runExpr($windy, $msg, $m3);
        }
    }),
    IfThen => quote(sub {
        my ($self, $windy, $msg, $m1, $m2, $m3) = @_;
        if ($self->runExpr($windy, $msg, $m1)) {
            $self->runExpr($windy, $msg, $m2);
        }
    }),
    And => sub {
        my ($self, $windy, $msg, $m1, $m2) = @_;
        $m1 and $m2;
    },
    Or => sub {
        my ($self, $windy, $msg, $m1, $m2) = @_;
        $m1 or $m2;
    },
    Not => sub {
        my ($self, $windy, $msg, $m1) = @_;
        not $m1;
    },
    Op => sub {
        my ($self, $windy, $msg, $r1, $e, $r2) = @_;
        given ($e) {
            $r1 > $r2 when '大于';
            $r1 == $r2 when '等于';
            $r1 < $r2 when '小于';
            $r1 <= $r2 when '不大于';
            $r1 >= $r2 when '不小于';
            $r1 != $r2 when '不等于';
            $r1 eq $r2 when '为';
            $r1 ne $r2 when '不为';
            #$r1 ~~ $r2 when '是';
        }
    },
};
my $aliases = [
    # Remove spaces
    #[qr/^\s+(.+)$/, $subs->{AsIs}],
    #[qr/^(.+?)\s+$/, $subs->{AsIs}],
    #[qr/^(?:回)?答(.+)$/, $subs->{AsIs}],
    # Plain
    #[qr/^$d3(.+)?$d4$/, sub { my ($windy, $msg, $m1) = @_; $m1 }],
    # Control structures
    [qr/^$If(.+?)，$Then(.+?)，$Else(.+)$/, $subs->{IfThenElse}],
    [qr/^$If(.+?)，$Then(.+)$/, $subs->{IfThen}],
    # Logical expressions
    [qr/^(.+?)(?:并且|而且|且)(.+)$/, $subs->{And}],
    [qr/^(.+?)(?:或者|或是|或)(.+)$/, $subs->{Or}],
    [qr/^不是(.+)$/, $subs->{Not}],
    # Comparison expressions
    [qr/^(.+)((?:不)?(?:大|等|小)于|为)(.+)$/, $subs->{Op}],
    #[qr/^(?:随机|任选)(.+)$/s, sub { my ($self, $windy, $msg, $m1) = @_; my @arr = split /\n/, $m1; (expr $arr[int rand @arr])->($windy, $msg) } ],
    [qr/^概率(\d*\.*\d+)(.+)$/, quote(sub {
        my ($self, $windy, $msg, $m1, $m2) = @_;
        if ($self->runExpr($windy, $msg, $m1) >= rand) {
            $self->runExpr($windy, $msg, $m2);
        } })],
    # Functions
    [qr/^群讯$/, sub { my ($self, $windy, $msg) = @_; isGroupMsg($windy, $msg) and msgGroupId($windy, $msg) ~~ @{$windy->{startGroup}}; }],
    [qr/^截止$/, sub { print "i am stopping parse this message"; msgStopping($_[1], $_[2]) = 1; '' } ],
    [qr/^(?:来讯者(?:名|的名字))$/, \&senderNickname],
    [qr/^好感(?:度)?$/, sub { 0 }],
    [qr/^(?:对|艾特)(?:我|你)$/, sub { my $self = shift;my $windy = shift; my $msg = shift; isAt($windy, $msg) or msgText($windy, $msg) =~ /^\s*$myName(?:\s+|，|。)?/ }],
    ];
my $replacements = {
    '风妹' => qr/\s*$myName(?:\s+|，|。)?/,
    };
$match = Scripts::Windy::SmartMatch->new(
    d1 => '【',
    d2 => '】',
    d3 => '{',
    d4 => '}',
    d5 => '<',
    d6 => '>',
    aliases => $aliases,
    replacements => $replacements);

sub sm
{
    $match->smartmatch(@_);
}

sub sr
{
    $match->smartret(@_);
}

1;
