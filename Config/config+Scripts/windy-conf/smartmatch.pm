package Scripts::Windy::Conf::smartmatch;
use 5.012;
no warnings 'experimental';
use Scripts::Windy::Addons::Nickname;
use Scripts::Windy::Addons::Sense;
use Scripts::Windy::Addons::Sign;
use Scripts::Windy::SmartMatch;
use Scripts::Windy::Quote;
use Scripts::Windy::Util;
use Scripts::scriptFunctions;
$Scripts::scriptFunctions::debug = 0;
use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/$match sm sr $sl1 $sl2 $sl3 $subs/;
loadNicknames;
loadSense;
loadSign;
our $match;
my $myName = qr/(?:(?<!风)(?:小|西)?风(?:妹(?:子|儿|砸|妹)?|儿|酱|姐{1,2})|小风姬|西风待人)/;
my $emotion = qr/(?:哪|呐|呀|啊|w|[Qq](?:[AWwa][Qq])+[Qq]*)/;
my $caller = qr/\s*$myName(?:$emotion)?(?:\s+|，|。|,|\.{2,})?/;
my $If = qr/(?:(?:如)?若|如果)/;
my $Then = qr/(?:则|那么)/;
my $Else = qr/(?:不然|否则)(?:的话)?/;

our ($sl1, $sl2, $sl3) = (100, 50, 0);

our $subs;
$subs = {
#    AsIs => quote(sub {
#        my $windy = shift;
#        my ($msg, $m1) = @_;
#        my $m = expr $m1;
#        $m->($windy, $msg)
#    }),
    IfThenElse => quote(sub {
        my ($self, $windy, $msg, $m1, $m2, $m3) = @_;
        if ($self->runExpr($windy, $msg, $m1, @_[6..$#_])) {
            $self->runExpr($windy, $msg, $m2, @_[6..$#_]);
        } else {
            $self->runExpr($windy, $msg, $m3, @_[6..$#_]);
        }
    }),
    IfThen => quote(sub {
        my ($self, $windy, $msg, $m1, $m2) = @_;
        if ($self->runExpr($windy, $msg, $m1, @_[5..$#_])) {
            $self->runExpr($windy, $msg, $m2, @_[5..$#_]);
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
    sense => sub {
        my ($self, $windy, $msg) = @_;
        sense(uid(msgSender($windy, $msg)));
    },
    addSense => sub {
        my ($self, $windy, $msg, $m1) = @_;
        my ($sense, $added) = addSense(uid(msgSender($windy, $msg)), $m1);
        if ($added <= 0 or rand >= .233) { # 有一定的概率,显示好感.
            '';
        } else {
            my $nick = senderNickname($self, $windy, $msg);
            if ($sense > $sl1) {
                '  最喜欢'.$nick.'了www';
            } elsif ($sense > $sl2) {
                '  咱好像越来越喜欢'.$nick.'了呢w';
            } elsif ($sense > $sl3) {
                '  咱好像有点喜欢'.$nick.'了呢w';
            } else {
                ''; # 对于好感是负的人来说...你上辈子做了什么孽呀QAQ
            }
        } 
    },
    sign => sub {
        my ($self, $windy, $msg) = @_;
        my $s = sign($self, $windy, $msg);
        if ($s) {
            debug "sensing: $s";
            $subs->{addSense}($self, $windy, $msg, $s, @_[3..$#_]);
        } else {
            debug "not sensing.";
            '';
        }
    },
    newNick => sub {
        my ($self, $windy, $msg, $nick) = @_;
        my $id = uid(msgSender($windy, $msg));
        newNick($id, $nick);
        $nick;
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
        if ($self->runExpr($windy, $msg, $m1, @_[5..$#_]) >= rand) {
            $self->runExpr($windy, $msg, $m2, @_[5..$#_]);
        } })],
    # Functions
    [qr/^群讯$/, sub { my ($self, $windy, $msg) = @_; isGroupMsg($windy, $msg) and msgGroupId($windy, $msg) ~~ @{$windy->{startGroup}}; }],
    [qr/^截止$/, sub { print "i am stopping parse this message"; msgStopping($_[1], $_[2]) = 1; '' } ],
    [qr/^(?:来讯者(?:名|的名字))$/, \&senderNickname],
    [qr/^(?:增|加|增加)(\d+)好感$/, $subs->{addSense}],
    [qr/^好感(?:度)?$/, $subs->{sense}],
    [qr/^捕获(\d+)$/, sub {
        my $self = shift;
        my $windy = shift;
        my $msg = shift;
        my $num = shift;
        $_[$num - 1];
     }],
    [qr/^一等$/, sub {
        my ($self, $windy, $msg) = @_;
        my $s = $subs->{sense}($self, $windy, $msg);
        $s > $sl1;
     }],
    [qr/^二等$/, sub {
        my ($self, $windy, $msg) = @_;
        my $s = $subs->{sense}($self, $windy, $msg);
        $s <= $sl1 and $s > $sl2;
     }],
    [qr/^三等$/, sub {
        my ($self, $windy, $msg) = @_;
        my $s = $subs->{sense}($self, $windy, $msg);
        $s <= $sl2 and $s > $sl3;
     }],
    [qr/^四等$/, sub {
        my ($self, $windy, $msg, $m1) = @_;
        my $s = $subs->{sense}($self, $windy, $msg);
        $s <= $sl3;
     }],
    [qr/^签到$/, $subs->{sign}],
    [qr/^(?:对|艾特)(?:我|你)$/, sub { my $self = shift;my $windy = shift; my $msg = shift; isAt($windy, $msg) or msgText($windy, $msg) =~ /^$caller/ }],
    ];
my $replacements = {
    '风妹' => $caller,
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
