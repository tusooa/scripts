package Scripts::Windy::Conf::smartmatch;
use 5.012;
no warnings 'experimental';
use Scripts::Windy::Addons::Nickname;
use Scripts::Windy::Addons::Sense;
use Scripts::Windy::Addons::Sign;
use Scripts::Windy::Addons::BlackList;
use Scripts::Windy::SmartMatch;
use Scripts::Windy::Quote;
use Scripts::Windy::Util;
use Scripts::scriptFunctions;
#$Scripts::scriptFunctions::debug = 0;
use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/$match sm sr $sl1 $sl2 $sl3 $subs/;
loadNicknames;
loadSense;
loadSign;
loadBlackList;
our $match;
my $myName = qr/(?:(?<!风)(?:小|西)?风(?:妹(?:子|儿|砸|妹)?|儿|酱|姐{1,2})|小风姬|西风待人)/;
# wwwww, qwqwqqqqqq, 0 0 0, ououo
# 这只是几个例子，绝对不是兔嫂在卖萌，嗯。
my $emotion = qr/(?:w+|[Qq](?:.[Qq])+[Qq]*|0(?:.0)+|[Oo](?:.[Oo])+|x+|-(?:.-)+|=(?:.=)+|😂)/;
# 最后一个是笑抽的表情，嗯。
my $emotion_s = qr/(?:\s+|？|。|\?|\.|~|～|,|，|!|！|\^|【|】|（|\(|\)|）|「|」|“|”)/;
my $excl = qr/(?:呜|哟|哦|喵|咩|呜|吗|啊|呀|哪|呐|嘛|咪|噫|吁|嚱|嗯|恩|诶|欸|哎|唉|等|噗|铥(?:的)?|这|23{2,}(?:4*3*)*)/;
my $excl_pre = qr/(?:喂|卧槽|woc|[Tt][Mm]|(?:神)?(?:特(?:么|喵)|(?:他|她|它)妈)(?:的)?|所以(?:说)?|说来|话说(?:回来)?|说回来|然而|(?:可|但)(?:是)?|因为|只因)/;
my $excl_post = qr/(?:呢|哉|也|矣|你|(?:大)?误|(?:大)?雾|吧|了|打勾|打钩|(?:并)?不)/;
my $emotion_post = qr/(?:$excl|$excl_post|$emotion_s|$emotion|$myName)*/;
my $emotion_pre = qr/(?:$excl|$excl_pre|$emotion_s|$emotion|$myName)*?/;
#my $suffix = qr/(?:哪|呐|呀|啊|喵|$emotion)/;
my $caller = qr/$emotion_pre$myName$emotion_post/;
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
                '（最喜欢'.$nick.'了www';
            } elsif ($sense > $sl2) {
                '（咱好像越来越喜欢'.$nick.'了呢w';
            } elsif ($sense > $sl3) {
                '（咱好像有点喜欢'.$nick.'了呢w';
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
        my ($self, $windy, $msg, $nick, $sticky) = @_;
        my $id = uid(msgSender($windy, $msg));
        newNick($id, $nick, $sticky);
    },
    assignNick => sub {
        my ($self, $windy, $msg, $id, $nick, $sticky) = @_;
        newNick($id, $nick, $sticky);
    },
    blackList => sub {
        my ($self, $windy, $msg, $id, $status) = @_;
        if ($status) {
            addBlackList($id);
        } else {
            removeBlackList($id);
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
    [qr/^(.+?)(?:连上|\+)(.+)$/, sub { my ($self, $windy, $msg, $m1, $m2) = @_; $m1 . $m2; }],
    [qr/^(.+?)((?:不)?(?:大|等|小)于|为)(.+)$/, $subs->{Op}],
    #[qr/^(?:随机|任选)(.+)$/s, sub { my ($self, $windy, $msg, $m1) = @_; my @arr = split /\n/, $m1; (expr $arr[int rand @arr])->($windy, $msg) } ],
    [qr/^概率(\d*\.*\d+)(.+)$/, quote(sub {
        my ($self, $windy, $msg, $m1, $m2) = @_;
        if ($self->runExpr($windy, $msg, $m1, @_[5..$#_]) >= rand) {
            $self->runExpr($windy, $msg, $m2, @_[5..$#_]);
        } })],
    # Functions
    [qr/^群讯$/, sub { my ($self, $windy, $msg) = @_; isGroupMsg($windy, $msg) and msgGroupId($windy, $msg) ~~ @{$windy->{startGroup}}; }],
    [qr/^截止$/, sub { msgStopping($_[1], $_[2]) = 1; '' } ],
    [qr/^(?:来讯者(?:名|的名字))$/, \&senderNickname],
    [qr/^来讯者(?:的|之)?(?:[Ii][Dd]|[Qq][Qq])$/, sub {
        my ($self, $windy, $msg) = @_;
        uid(msgSender($windy, $msg));
     }],
    [qr/^(?:增|加|增加)(-?\d+)好感$/, $subs->{addSense}],
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
    [qr/^左$/, sub { shift->{d1} }],
    [qr/^右$/, sub { shift->{d2} }],
    [qr/^群(?:中|里|内)有(\d+)$/, sub {
        my ($self, $windy, $msg, $id) = @_;
        msgGroupHas($windy, $msg, $id);
     }],
    [qr/^被(?:屏蔽|拉黑)$/, sub {
        my ($self, $windy, $msg) = @_;
        onBlackList(uid(msgSender($windy, $msg)));
     }],
    ];
my $replacements = {
    '风妹' => $caller,
    '前' => $emotion_pre,
    '后' => $emotion_post,
    '我' => qr/(?:我|咱(?:家)?|在下|人家|吾(?:辈)?|朕|寡人|孤(?:王)?|本王|本人|本薇)/,
    'd1' => qr/【/,
    'd2' => qr/】/,
    'd5' => qr/</,
    'd6' => qr/>/,
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
