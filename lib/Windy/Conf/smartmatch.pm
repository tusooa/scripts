package Scripts::Windy::Conf::smartmatch;
use 5.012;
no warnings 'experimental';
use Scripts::Windy::Addons::Nickname;
use Scripts::Windy::Addons::Sense;
use Scripts::Windy::Addons::Sign;
use Scripts::Windy::Addons::BlackList;
use Scripts::Windy::Addons::Mood;
use Scripts::Windy::Addons::StartStop;
use POSIX qw/strftime/;
use Scripts::Windy::SmartMatch;
use Scripts::Windy::Quote;
use Scripts::Windy::Util;

use List::Util qw/sum/;
use Scripts::scriptFunctions;
use Exporter;
use utf8;
use Encode qw/_utf8_on _utf8_off/;
our @ISA = qw/Exporter/;
our @EXPORT = qw/$match sm smS sms sr $sl1 $sl2 $sl3 @sl @ml $subs %reply sizeOfMatch
reloadReplacements addReplacement getReplacement nicknameById loadConfGroup/;

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
my $aliasFile = $configDir.'windy-conf/alias.conf';
my $size = 0;
my $split = qr/(?<!\\)\|/;
my $caller = qr//;
my $nickForbidden = qr//;

sub sm;
sub sr;
sub loadReplacements;
sub addReplacement;
sub reloadReplacements;
sub loadAlias;
sub addAlias;
sub reloadAlias;
sub updateSize;
sub loadConfGroup;
sub loadLevels;
sub loadReply;
our ($sl1, $sl2, $sl3);
our @sl;
our @ml;
our %reply = ();

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
            $r1 eq $r2 when '正好就是';
            $r1 ne $r2 when '不正好就是';
            #$r1 ~~ $r2 when '是';
        }
    },
    mood => sub {
        my ($self, $windy, $msg) = @_;
        curMood;
    },
    addMood => sub {
        my ($self, $windy, $msg, $m1) = @_;
        my ($mood, $added) = addMood($m1, uid(msgSender($windy, $msg)));
        $reply{'addMood'}->run($windy, $msg, $added);
    },
    sense => sub {
        my ($self, $windy, $msg) = @_;
        sense(uid(msgSender($windy, $msg)));
    },
    senseWithMood => sub {
        my ($self, $windy, $msg) = @_;
        my $sense = $subs->{sense}(@_);
        moodedSense($sense, $ml[2]);
    },
    addSense => sub {
        my ($self, $windy, $msg, $m1) = @_;
        my (undef, $added) = addSense(uid(msgSender($windy, $msg)), $m1);
        $reply{'addSense'}->run($windy, $msg, $added);
    },
    sign => sub {
        my ($self, $windy, $msg) = @_;
        my $s = sign($self, $windy, $msg);
        if (defined $s) {
            my (undef, $added) = addSense(uid(msgSender($windy, $msg)), $s);
            $reply{'sign'}->run($windy, $msg, $added);
        } else {
            debug "not sensing.";
            '';
        }
    },
    newNick => sub {
        my ($self, $windy, $msg, $nick, $sticky) = @_;
        my $id = uid(msgSender($windy, $msg));
        if ($subs->{senseWithMood}($self, $windy, $msg) > $sl2 and $nick !~ $nickForbidden) {
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
        my ($self, $windy, $msg) = @_;
        isGroupMsg($windy, $msg)
            and isStartOn(msgGroupId($windy, $msg));
    },
    callerName => sub {
        my $self = shift;
        my ($windy, $msg) = @_;
        if (isGroupMsg($windy, $msg)
            and my $uid = isStartOn(msgGroupId($windy, $msg))) {
            if ($uid != -1) {
                userNickname($self,
                             findUserInGroup($windy, $uid, msgGroup($windy, $msg)));
            } else {
                $reply{'callerName-default'}->run(@_);
            }
        } else {
            undef;
        }
    },
};
my @aliases = (
    # Plain
    #[qr/^$d3(.+)?$d4$/, sub { my ($windy, $msg, $m1) = @_; $m1 }],
    # Control structures
    [qr/^$If(.+?)，$Then(.*?)，$Else(.+)$/, $subs->{IfThenElse}],
    [qr/^$If(.+?)，$Then(.+)$/, $subs->{IfThen}],
    [qr/^心情判[:：]([^,]*),([^,]*),([^,]*),([^,]*)$/, quote(sub {
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
            when ($_ > $ml[1]) { $self->runExpr($windy, $msg, $_[0], @_[4..$#_]) or continue; }
            when ($_ > $ml[3]) { $self->runExpr($windy, $msg, $_[1], @_[4..$#_]) or continue; }
            when ($_ > $ml[5]) { $self->runExpr($windy, $msg, $_[2], @_[4..$#_]) or continue; }
            default { $self->runExpr($windy, $msg, $_[3], @_[4..$#_]); }
        }
     })],
    [qr/^心情判[:：]([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*)$/, quote(sub {
        my $self = shift;
        my $windy = shift;
        my $msg = shift;
        my $mood = curMood;
        given ($mood) {
            when ($_ > $ml[0]) { $self->runExpr($windy, $msg, $_[0], @_[7..$#_]) or continue; }
            when ($_ > $ml[1]) { $self->runExpr($windy, $msg, $_[1], @_[7..$#_]) or continue; }
            when ($_ > $ml[2]) { $self->runExpr($windy, $msg, $_[2], @_[7..$#_]) or continue; }
            when ($_ > $ml[3]) { $self->runExpr($windy, $msg, $_[3], @_[7..$#_]) or continue; }
            when ($_ > $ml[4]) { $self->runExpr($windy, $msg, $_[4], @_[7..$#_]) or continue; }
            when ($_ > $ml[5]) { $self->runExpr($windy, $msg, $_[5], @_[7..$#_]) or continue; }
            default { $self->runExpr($windy, $msg, $_[6], @_[7..$#_]); }
        }
     })],
    [qr/^好感判[:：]([^,]*),([^,]*),([^,]*),([^,]*)$/, quote(sub {
        my $self = shift;
        my $windy = shift;
        my $msg = shift;
        my $sense = $subs->{senseWithMood}($self, $windy, $msg);
        #say $sense;
        #say term join ',', @_;
        given ($sense) {
            when ($_ > $sl1) { $self->runExpr($windy, $msg, $_[0], @_[4..$#_]) or continue; }
            when ($_ > $sl2) { $self->runExpr($windy, $msg, $_[1], @_[4..$#_]) or continue; }
            when ($_ > $sl3) { $self->runExpr($windy, $msg, $_[2], @_[4..$#_]) or continue; }
            default { $self->runExpr($windy, $msg, $_[3], @_[4..$#_]); }
        }
                                                             })],
    [qr/^隐掉：(.+?)。$/, sub { undef; }],
    [qr/^(.+?)\+(.+)$/, sub { my ($self, $windy, $msg, $m1, $m2) = @_; $m1 . $m2; }],
    # Logical expressions
    [qr/^(.+?)(?:并且|而且)(.+)$/, $subs->{And}],
    [qr/^(.+?)(?:或者|或是)(.+)$/, $subs->{Or}],
    [qr/^不是(.+)$/, $subs->{Not}],
    # Comparison expressions
    [qr/^(.+?)(不?(?:(?:大|等|小)于|正好就是))(.+)$/, $subs->{Op}],
    #[qr/^(?:随机|任选)(.+)$/s, sub { my ($self, $windy, $msg, $m1) = @_; my @arr = split /\n/, $m1; (expr $arr[int rand @arr])->($windy, $msg) } ],
    [qr/^概率(\d*\.*\d+)(.+)$/, quote(sub {
        my ($self, $windy, $msg, $m1, $m2) = @_;
        if ($self->runExpr($windy, $msg, $m1, @_[5..$#_]) >= rand) {
            $self->runExpr($windy, $msg, $m2, @_[5..$#_]);
        } })],
    # Functions
    [qr/^讯息$/, sub { my ($self, $windy, $msg) = @_; isMsg($windy, $msg); }],
    [qr/^群讯开启$/, $subs->{fromGroup}],
    [qr/^私讯$/, sub { my ($self, $windy, $msg) = @_; isPrivateMsg($windy, $msg); }],
    [qr/^截止$/, sub { msgStopping($_[1], $_[2]) = 1; '' } ],
    [qr/^(?:来讯者(?:名|的名字))$/, \&senderNickname],
    [qr/^我名$/, sub { shift; receiverName(@_) },],
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
        my $self = shift;
        $reply{'default-mood-p'}->run(@_);
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
    [qr/^(?:对|艾特)(?:我|你)$/, sub {
        my ($self, $windy, $msg) = @_;
        my $text = msgText($windy, $msg);
        _utf8_on($text); # 别忘。
        isAt($windy, $msg) or $text =~ $caller;
     }],
    [qr/^左$/, sub { shift->{d1} }],
    [qr/^右$/, sub { shift->{d2} }],
    [qr/^群(?:中|里|内)有(\d+)$/, sub {
        my ($self, $windy, $msg, $id) = @_;
        msgGroupHas($windy, $msg, $id);
     }],
    [qr/^艾特到(\d+)$/, sub {
        my ($self, $windy, $msg, $id) = @_;
        isAtId($windy, $msg, $id);
     }],
    [qr/^被(?:屏蔽|拉黑)$/, sub {
        my ($self, $windy, $msg) = @_;
        onBlackList(uid(msgSender($windy, $msg)));
     }],
    [qr/^群[Ii][Dd]$/, sub { my ($self, $windy, $msg) = @_; msgGroupId($windy, $msg); }],
    [qr/^换行$/, sub { "\n" }],
    [qr/^下讯$/, sub { $nextMessage }],
    [qr/^当下时间$/, sub { formatTime; }],
    [qr/^时间段$/, sub {
        my ($min, $hour) = (localtime)[1,2];
        given ($hour + $min/60) {
            '凌晨' when $_ <= 4;
            '黎明' when $_ <= 6;
            '早上' when $_ <= 8;
            '上午' when $_ <= 11;
            '中午' when $_ <= 13;
            '下午' when $_ <= 17;
            '晚上' when $_ <= 23;
            default { '夜里'; }
        }
     }],
    [qr/^\$\[([^\]]+)\]$/, sub {
        my ($self, $windy, $msg, $entry) = @_;
        my $ret = $entry eq '-' ? '$' : $windyConf->get(split /::/, $entry);
        _utf8_on($ret);
        $ret;
     }],
    [qr/^\$\(([^\)]+)\)$/, sub {
        my ($self, $windy, $msg, $entry) = @_;
        $entry eq '-' ? '$' : ($reply{$entry} and $reply{$entry}->run($windy, $msg, @_[4..$#_]));
     }],
    );

$match = Scripts::Windy::SmartMatch->new(
    d1 => '【',
    d2 => '】',
    d3 => '{',
    d4 => '}',
    d5 => '<',
    d6 => '>',
    d7 => '〔',
    d8 => '〕',
    aliases => [@aliases],
    replacements => {},);
reloadReplacements;
loadAlias;
loadReply;
loadLevels;

sub loadReply
{
    %reply = ();
    for ($windyConf->childList('reply')) {
        my $text = $windyConf->get('reply', $_);
        _utf8_on($text);
        $reply{$_} = sr($text)->part;
    }
}

sub loadLevels
{
    @sl = ();
    for (qw/favourite like normal/) {
        push @sl, $windyConf->get('levels', 'sense', $_);
    }
    ($sl1, $sl2, $sl3) = @sl;
    @ml = ();
    for (1..6) {
        push @ml, $windyConf->get('levels', 'mood', $_);
    }
}

sub smS
{
    $match->smartmatch({ style => 'S' }, @_);
}

sub sms
{
    $match->smartmatch({ style => 's' }, @_);
}

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
    $caller = getReplacement("_我名_");
    $caller = qr/$caller/;
    $nickForbidden = getReplacement("称呼里不能用的");
    $nickForbidden = qr/$nickForbidden/;
    my $pre = getReplacement("前");
    $match->{preMatch} = qr/^$pre/;
    my $post = getReplacement("后");
    $match->{postMatch} = qr/$post$/;
    updateSize;
}

sub getReplacement
{
    my $name = shift;
    my $asIs = shift;
    if ($match->{replacements}{$name}) {
        if ($asIs) {
            my $d = $match->{replacements}{$name};
            ref $d eq 'ARRAY' ? join '|', @$d : $d;
        } else {
            $match->parseReplacements($match->{d5}.$name.$match->{d6});
        }
    } else {
        undef;
    }
}

### addReplacement('aaa', 'bbb')
### => <aaa> -> 'bbb'
sub addReplacement
{
    my ($name, $rep, $quotemeta) = @_;
    if (my $regex = getReplacement($name)) {
        if ($rep =~ m/^$regex$/) { # 这条已经存在了。
            # 之前没有^$。简直zz。
            return undef;
        }
    }
    $rep = quotemeta $rep if $quotemeta;
    eval { qr/$rep/ };
    return 0 if $@;
    if (ref $match->{replacements}{$name} eq 'ARRAY') {
        push @{$match->{replacements}{$name}}, $rep;
    } elsif (defined $match->{replacements}{$name}) { # 不能这么做呐。
        return 0;
    } else {
        $match->{replacements}{$name} = [$rep];
    }
    $size += scalar split $split, $rep;
    if (open my $f, '>>', $repFile) {
        binmode $f, ':unix';
        say $f "$name\t$rep";
        close $f;
    } else {
        die term "没法打开 $repFile 写入: $!\n";
    }
    $rep;
}

sub updateSize
{
    my %r = %{$match->{replacements}};
    $size = 0;
    for (keys %r) {
        my $v = $r{$_};
        if (ref $v eq 'ARRAY') {
            $size += sum map { scalar split $split } @$v;
        } else {
            $size += 1;
        }
    }
}

sub sizeOfMatch
{
    $size;
}

sub loadAlias
{
    if (open my $f, '<', $aliasFile) {
        while (<$f>) {
            chomp;
            my ($from, $to) = split /\t/, $_;
            push @{$match->{aliases}}, [$from, $to];
        }
        close $f;
    }
}

sub reloadAlias
{
    $match->{aliases} = [@aliases];
    loadAlias;
}

sub addAlias
{
    my ($from, $to) = @_;
    push @{$match->{aliases}}, [$from, $to];
    if (open my $f, '>', $aliasFile) {
        binmode $f, ':unix';
        say $f $from."\t".$to;
        close $f;
    }
    $to;
}

my %confGroup = (
    level => \&loadLevels,
    reply => \&loadReply,
    sign => \&Scripts::Windy::Addons::Sign::loadConf,
    sense => \&Scripts::Windy::Addons::Sense::loadConf,
    mood => \&Scripts::Windy::Addons::Mood::loadConf,
    startstop => \&Scripts::Windy::Addons::StartStop::loadConf,
);
sub loadConfGroup
{
    my $group = shift;
    if ($group eq 'ALL') {
        for (keys %confGroup) {
            $confGroup{$_}->();
        }
    } else {
        if (ref $confGroup{$group} eq 'CODE') {
            $confGroup{$group}->();
        } else {
            undef;
        }
    }
}

1;
