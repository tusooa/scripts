package Scripts::Windy::Conf::smartmatch;
use 5.012;
no warnings 'experimental';
use Scripts::Windy::Addons::Nickname;
use Scripts::Windy::Addons::Sense;
use Scripts::Windy::Addons::Sign;
use Scripts::Windy::Addons::BlackList;
use Scripts::Windy::Addons::Mood;
use Scripts::Windy::Addons::StartStop;
#use Scripts::Windy::Conf::smartmatch::replacements;

use Scripts::Windy::SmartMatch;
use Scripts::Windy::Quote;
use Scripts::Windy::Util;

use Scripts::scriptFunctions;
#$Scripts::scriptFunctions::debug = 0;
use Exporter;
use utf8;
use Encode qw/_utf8_on _utf8_off/;
our @ISA = qw/Exporter/;
our @EXPORT = qw/$match sm sr $sl1 $sl2 $sl3 $subs/;

loadNicknames;
loadSense;
loadSign;
loadBlackList;
loadMood;
loadGroups;
our $match;

my $If = qr/(?:(?:如)?若|如果)/;
my $Then = qr/(?:则|那么)/;
my $Else = qr/(?:不然|否则)(?:的话)?/;

my $repFile = $configDir.'windy-conf/replacements.db';

sub sm;
sub sr;
sub loadReplacements;
sub addReplacement;
sub reloadReplacements;

our ($sl1, $sl2, $sl3) = (150, 80, 0);
our @ml = (93, 85, 60, 40, -10, -40);

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
    mood => sub {
        my ($self, $windy, $msg) = @_;
        curMood;
    },
    addMood => sub {
        my ($self, $windy, $msg, $m1) = @_;
        my $mood = addMood($m1, uid(msgSender($windy, $msg)));
        if ((rand) <= .233) {
            '';
        } elsif ($m1 > 0) {
            if ($mood > $ml[0]) {
                '（好开心呢ww';
            } elsif ($mood > $ml[1]) {
                '（开心w';
            } elsif ($mood > $ml[2]) {
                '（有点开心';
            } elsif ($mood > $ml[4]) {
                '（内心好像。。有一种。。要平静下来的感觉呢qwq';
            } elsif ($mood > $ml[5]) {
                '（感觉。。没有。。。那么难过了qaq';
            } else {
                '';
            }
        } else {
            if ($mood > $ml[2]) {
                '';
            } elsif ($mood > $ml[3]) {
                '（咱有点不开心了哦qwq？';
            } elsif ($mood > $ml[4]) {
                '（再这样的话咱可要生气了呢QAQ';
            } elsif ($mood > $ml[5]) {
                '（我可是。。会。黑。化。的。哦？';
            } else {
                '';
            }
        }
    },
    sense => sub {
        my ($self, $windy, $msg) = @_;
        sense(uid(msgSender($windy, $msg)));
    },
    senseWithMood => sub {
        my ($self, $windy, $msg) = @_;
        my $sense = $subs->{sense}(@_);
        my $mood = $subs->{mood}(@_);
        int($sense + (abs($sense) > 20 ? abs($sense) : 20) * ($mood-$ml[3]) / 200);
    },
    addSense => sub {
        my ($self, $windy, $msg, $m1) = @_;
        my (undef, $added) = addSense(uid(msgSender($windy, $msg)), $m1);
        my $sense = $subs->{senseWithMood}($self, $windy, $msg);
        if (rand >= .233) { # 有一定的概率,显示好感.
            '';
        } elsif ($added >= 0) {
            my $nick = senderNickname($self, $windy, $msg);
            if ($sense > $sl1) {
                '（最喜欢'.$nick.'了www';
            } elsif ($sense > $sl2) {
                '（咱好像有点喜欢'.$nick.'了呢w';
            } elsif ($sense > $sl3) {
                '';
            } else {
                ''; # 对于好感是负的人来说...你上辈子做了什么孽呀QAQ
            }
        } else {
            my $nick = senderNickname($self, $windy, $msg);
            if ($sense > $sl1) {
                '（'.$nick.'。。是嫌弃人家了嘛呜。。';
            } elsif ($sense > $sl2) {
                '（'.$nick.'。。。qwq';
            } elsif ($sense > $sl3) {
                '（'.$nick.'，很有趣呀。';
            } else {
                '（你还想作死0 0？'; # 对于好感是负的人来说...你上辈子做了什么孽呀QAQ
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
        if ($subs->{senseWithMood}($self, $windy, $msg) > $sl2) {
            newNick($id, $nick, $sticky);
        } else {
            undef;
        }
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
    start => sub {
        my ($self, $windy, $msg, $group) = @_;
        $group = msgGroupId($windy, $msg) if $windy and $msg and not $group;
        $group or return;
        startOn($group, $windy, $msg);
    },
    stop => sub {
        my ($self, $windy, $msg, $group) = @_;
        $group = msgGroupId($windy, $msg) if $windy and $msg and not $group;
        $group or return;
        stopOn($group);
    },
    fromGroup => sub {
        #say STDERR "FROM GROUP RUNNING";
        my ($self, $windy, $msg) = @_;
        if (isGroupMsg($windy, $msg)
            and my $uid = isStartOn(msgGroupId($windy, $msg))) {
            #say STDERR "fromGroup. uid = $uid";
            if ($uid != -1) {
                userNickname($self,
                             findUserInGroup($windy, $uid, msgGroup($windy, $msg)));
            } else {
                "神";
            }
        } else {
            #say STDERR "not group msg";
            undef;
        }
    },
    reloadR => \&reloadReplacements,
    addR => \&addReplacement,
};
my $aliases = [
    # Plain
    #[qr/^$d3(.+)?$d4$/, sub { my ($windy, $msg, $m1) = @_; $m1 }],
    # Control structures
    [qr/^$If(.+?)，$Then(.+?)，$Else(.+)$/, $subs->{IfThenElse}],
    [qr/^$If(.+?)，$Then(.+)$/, $subs->{IfThen}],
    [qr/^心情判[:：]([^,]*),([^,]*),([^,]*),([^,]*)$/, sub {
        ### 多余的(1)??? 好感判亦同。
        ### 只要任何一个分支中留空，就会出现。
        ### 不知道可能会有什么问题
        my $self = shift;
        my $windy = shift;
        my $msg = shift;
        my $mood = curMood;
        #say $mood;
        #say term join ',', @_;
        given ($mood) {
            when ($_ > $ml[1]) { $_[0] or continue; }
            when ($_ > $ml[3]) { $_[1] or continue; }
            when ($_ > $ml[5]) { $_[2] or continue; }
            default { $_[3]; }
        }
     }],
    [qr/^心情判[:：]([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*)$/, sub {
        my $self = shift;
        my $windy = shift;
        my $msg = shift;
        my $mood = curMood;
        #say $mood;
        #say term join ',', @_;
        #say term join ',', @ml;
        given ($mood) {
            say $_;
            when ($_ > $ml[0]) { $_[0] or continue; }
            when ($_ > $ml[1]) { $_[1] or continue; }
            when ($_ > $ml[2]) { $_[2] or continue; }
            when ($_ > $ml[3]) { $_[3] or continue; }
            when ($_ > $ml[4]) { $_[4] or continue; }
            when ($_ > $ml[5]) { $_[5] or continue; }
            default { $_[6]; }
        }
     }],
    [qr/^好感判[:：]([^,]*),([^,]*),([^,]*),([^,]*)$/, sub {
        my $self = shift;
        my $windy = shift;
        my $msg = shift;
        my $sense = $subs->{senseWithMood}($self, $windy, $msg);
        #say $sense;
        #say term join ',', @_;
        given ($sense) {
            when ($_ > $sl1) { $_[0] or continue; }
            when ($_ > $sl2) { $_[1] or continue; }
            when ($_ > $sl3) { $_[2] or continue; }
            default { $_[3]; }
        }
     }],
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
    [qr/^群讯$/, $subs->{fromGroup}],
    [qr/^截止$/, sub { msgStopping($_[1], $_[2]) = 1; '' } ],
    [qr/^(?:来讯者(?:名|的名字))$/, \&senderNickname],
    [qr/^来讯者(?:的|之)?(?:[Ii][Dd]|[Qq][Qq])$/, sub {
        my ($self, $windy, $msg) = @_;
        uid(msgSender($windy, $msg));
     }],
    [qr/^(?:增|加|增加)(-?\d+)心情$/, $subs->{addMood}],
    [qr/^心情$/, $subs->{mood}],
    [qr/^(?:开心极了|十分开心)$/, sub { curMood > $ml[0] }],
    [qr/^很开心$/, sub { curMood > $ml[1] }],
    [qr/^开心$/, sub { curMood > $ml[2] }],
    [qr/^一般$/, sub { (curMood) <= $ml[2] and curMood > $ml[3] }],
    [qr/^难过$/, sub { (curMood) <= $ml[3] }],
    [qr/^难过极了$/, sub { (curMood) <= $ml[4] }],
    [qr/^黑化$/, sub { (curMood) <= $ml[5] }],
    [qr/^心情判$/, sub {
        my $mood = curMood;
        if ($mood > $ml[1]) {
            'w';
        } elsif ($mood > $ml[3]) {
            'qwq';
        } elsif ($mood > $ml[5]) {
            'QAQ';
        } else {
            '。';
        }
     }],
    [qr/^(?:增|加|增加)(-?\d+)好感$/, $subs->{addSense}],
    [qr/^好感(?:度)?$/, $subs->{senseWithMood}],
    [qr/^捕获(\d+)$/, sub {
        my $self = shift;
        my $windy = shift;
        my $msg = shift;
        my $num = shift;
        $_[$num - 1];
     }],
    [qr/^很喜欢$/, sub {
        my ($self, $windy, $msg) = @_;
        my $s = $subs->{senseWithMood}($self, $windy, $msg);
        $s > $sl1;
     }],
    [qr/^喜欢$/, sub {
        my ($self, $windy, $msg) = @_;
        my $s = $subs->{senseWithMood}($self, $windy, $msg);
        $s > $sl2;
     }],
    [qr/^无感$/, sub {
        my ($self, $windy, $msg) = @_;
        my $s = $subs->{senseWithMood}($self, $windy, $msg);
        $s <= $sl2 and $s > $sl3;
     }],
    [qr/^讨厌$/, sub {
        my ($self, $windy, $msg, $m1) = @_;
        my $s = $subs->{senseWithMood}($self, $windy, $msg);
        $s <= $sl3;
     }],
    [qr/^签到$/, $subs->{sign}],
    [qr/^(?:对|艾特)(?:我|你)$/, sub { my $self = shift;my $windy = shift; my $msg = shift; isAt($windy, $msg) #or msgText($windy, $msg) =~ /^$caller/
     }],
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
    [qr/^群[Ii][Dd]$/, sub { my ($self, $windy, $msg) = @_; msgGroupId($windy, $msg); }],
    ];

$match = Scripts::Windy::SmartMatch->new(
    d1 => '【',
    d2 => '】',
    d3 => '{',
    d4 => '}',
    d5 => '<',
    d6 => '>',
    d7 => '〔',
    d8 => '〕',
    aliases => $aliases,
    replacements => {},);
reloadReplacements;

sub sm
{
    $match->smartmatch(@_);
}

sub sr
{
    $match->smartret(@_);
}

sub loadReplacements
{
    if (open my $f, '<', $repFile) {
        while (<$f>) {
            chomp;
            _utf8_on($_);
            if (/^\e([^\t]+)\t(.+)$/) {
                my $name = $1;
                my $rep = $2;
                $match->{replacements}{$name} = eval $rep;
                die "Cannot eval `$rep` because: $@" if $@;
            } elsif (/^([^\t]+)\t(.+)$/) {
                my $name = $1;
                my $rep = $2;
                if (ref $match->{replacements}{$name} eq 'ARRAY') {
                    push @{$match->{replacements}{$name}}, $rep;
                } else {
                    $match->{replacements}{$name} = [$rep];
                }
            } else {
                # 注释以一个Tab开头？
                # 好主意w
            }
        }
        close $f;
    }
}

sub reloadReplacements
{
    $match->{replacements} = {};
    loadReplacements;
}

### addReplacement('aaa', 'bbb')
### => <aaa> -> 'bbb'
sub addReplacement
{
    my ($name, $rep, $quotemeta) = @_;
    if ($match->{replacements}{$name}) {
        my $regex = $match->parseReplacements($match->{d5}.$name.$match->{d6});
        if ($rep =~ m/$regex/) { # 这条已经存在了。
            return;
        }
    }
    $rep = quotemeta $rep if $quotemeta;
    if (ref $match->{replacements}{$name} eq 'ARRAY') {
        push @{$match->{replacements}{$name}}, $rep;
    } else {
        $match->{replacements}{$name} = [$rep];
    }
    if (open my $f, '>>', $repFile) {
        binmode $f, ':unix';
        say $f "$name\t$rep";
        close $f;
    } else {
        die term "没法打开 $repFile 写入: $!\n";
    }
    $rep;
}

1;
