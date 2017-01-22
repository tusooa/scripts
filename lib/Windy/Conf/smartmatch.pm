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
use Scripts::TextAlias::Parser;
use Scripts::Windy::SmartMatch::TextAlias;
use Scripts::TextAlias::Expr qw/quoteExpr/;
use List::Util qw/sum/;
use Scripts::scriptFunctions;
use Exporter;
use utf8;
use Encode qw/_utf8_on _utf8_off/;
our @ISA = qw/Exporter/;
our @EXPORT = qw/$match sm smS sms sr $sl1 $sl2 $sl3 @sl @ml $subs %reply sizeOfMatch
reloadReplacements addReplacement getReplacement nicknameById loadConfGroup windyMsgArgs
loadNicknames loadSense loadSign loadBlackList loadMood loadGroups/;

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
        my $s = msgTAEnv($windy, $msg)->scope;
        $s->makeVar($moodAddedVN);
        $s->var($moodAddedVN, $added);
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
        my $s = msgTAEnv($windy, $msg)->scope;
        $s->makeVar($senseAddedVN);
        $s->var($moodAddedVN, $added);
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
    toMe => sub {
        my ($self, $windy, $msg) = @_;
        my $text = msgTextNoAt($windy, $msg);
        _utf8_on($text); # 别忘。
        isAt($windy, $msg) or $text =~ $caller;
    },
    stopMsg => sub { msgStopping($_[1], $_[2]) = $_[3] || 1; '' },
    privMsg => sub { my ($self, $windy, $msg) = @_; isPrivateMsg($windy, $msg); },
    partOfDay => sub {
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
    },
    replyTemplate => sub {
        my ($self, $windy, $msg, $entry) = @_;
        $entry eq '-' ? '$' : ($reply{$entry} and $reply{$entry}->run($windy, $msg, @_[4..$#_]));
    },
    windyConf => sub {
        my ($self, $windy, $msg, $entry) = @_;
        my $ret = $entry eq '-' ? '$' : $windyConf->get(split /::/, $entry);
        _utf8_on($ret);
        $ret;
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
    [qr/^私讯$/, $subs->{privMsg}],
    [qr/^截止(?:[：:](.+))?$/, $subs->{stopMsg} ],
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
    [qr/^(?:对|艾特)(?:我|你)$/, $subs->{toMe}],
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
    [qr/^群名$/, sub { my ($self, $windy, $msg) = @_; msgGroupName($windy, $msg); }],
    [qr/^换行$/, sub { "\n" }],
    [qr/^下讯$/, sub { $nextMessage }],
    [qr/^当下时间$/, sub { formatTime; }],
    [qr/^时间段$/, $subs->{partOfDay}],
    [qr/^随机数[：:](\d+),(\d+)$/, sub {
        my ($self, $windy, $msg, $bot, $top) = @_;
        randFromTo($bot, $top);
     }],
    [qr/^\$\[([^\]]+)\]$/, $subs->{windyConf}],
    [qr/^\$\(([^\)]+)\)$/, $subs->{replyTemplate}],
    );

sub windyMsgArgs
{
    my ($env, $args) = @_;
    my $scope = $env->scope;
    my ($windy, $msg) = ($scope->var('windy'), $scope->var('msg'));
    ($windy, $msg, @$args);
}

topScope->var('smart-match', $match);
topScope->var('c', quoteExpr sub {
    my ($env, $args) = @_;
    my $cond = $env->scope->var($condVN);
    push @$cond, @$args;
    undef;
              });
topScope->var('p', sub {
    my ($env, $args) = @_;
    my (undef, undef, $p) = windyMsgArgs(@_);
    $env->scope->var($patternVN, $p);
});
topScope->var('posi', quoteExpr sub {
    my ($env) = @_;
    my (undef, undef, $posi, @rest) = windyMsgArgs(@_);
    if (ta->getValue($posi, $env) >= rand) {
        my @ret = map { ta->getValue($_, $env); } @rest;
        wantarray ? @ret : $ret[-1];
    }
              });
topScope->var('sender-name', sub { senderNickname($match, windyMsgArgs(@_)); });
topScope->var('my-name', sub { receiverName(windyMsgArgs(@_)); });
topScope->var('sense', sub { $subs->{senseWithMood}($match, windyMsgArgs(@_)); });
topScope->var('mood', sub { $subs->{mood}($match, windyMsgArgs(@_)); });
topScope->var('add-sense', sub { $subs->{addSense}($match, windyMsgArgs(@_)); });
topScope->var('add-mood', sub { $subs->{addMood}($match, windyMsgArgs(@_)); });
topScope->var('cap', sub {
    my ($env) = @_;
    my (undef, undef, $num) = windyMsgArgs(@_);
    $env->scope->var($msgMatchVN)->[$num-1];
              });
topScope->var('to-me', sub { $subs->{toMe}($match, windyMsgArgs(@_)); });
topScope->var('stop', sub { $subs->{stopMsg}($match, windyMsgArgs(@_)); });
topScope->var('priv-msg', sub { $subs->{privMsg}($match, windyMsgArgs(@_)); });
topScope->var('from-group', sub { $subs->{fromGroup}($match, windyMsgArgs(@_)); });
topScope->var('group-name', sub { msgGroupName(windyMsgArgs(@_)); });
topScope->var('group-id', sub { msgGroupId(windyMsgArgs(@_)) });
topScope->var('nl', "\n");
topScope->var('next', $nextMessage);
topScope->var('time-now', sub { formatTime });
topScope->var('part-of-day', $subs->{partOfDay});
topScope->var('rand-int', sub { my (undef, undef, @a) = msgWindyArgs(@_); randFromTo(@a); });
topScope->var('reply', sub {
    my ($env) = @_;
    my $msgMatch = $env->scope->var($msgMatchVN);
    my ($windy, $msg, $entry) = windyMsgArgs(@_);
    $reply{$entry} and $reply{$entry}->run($windy, $msg, @$msgMatch); });
topScope->var('conf', sub { $subs->{windyConf}($match, windyMsgArgs(@_)); });
topScope->var('by-sense', quoteExpr sub {
    my ($env) = @_;
    my ($windy, $msg, @args) = windyMsgArgs(@_);
    my @lvl = ();
    given (scalar @args) {
        @lvl = @args when $_ >= 4;
        @lvl = (@args[0..1], undef, $args[2]) when 3;
        @lvl = (undef, $args[0], undef, $args[1]) when 2;
        @lvl = (undef, undef, undef, @args) when 1;
        default { return; }
    }
    my $sense = $subs->{senseWithMood}($match, $windy, $msg);
    given ($sense) {
            when ($_ > $sl1) { ta->getValue($lvl[0], $env) // continue; }
            when ($_ > $sl2) { ta->getValue($lvl[1], $env) // continue; }
            when ($_ > $sl3) { ta->getValue($lvl[2], $env) // continue; }
            default { ta->getValue($lvl[3], $env); }
        }
              });
topScope->var('by-mood', quoteExpr sub {
    my ($env) = @_;
    my ($windy, $msg, @args) = windyMsgArgs(@_);
    my @lvl = ();
    given (scalar @args) {
        @lvl = @args when $_ >= 7;
        @lvl = (undef, @args) when 6;
        @lvl = (undef, $args[0], $args[1], $args[2], undef, $args[3], $args[4]) when 5;
        @lvl = (undef, $args[0], undef, $args[1], undef, $args[2], $args[3]) when 4;
        @lvl = (undef, $args[0], undef, $args[1], undef, undef, $args[2]) when 3;
        @lvl = (undef, undef, undef, $args[0], undef, undef, $args[1]) when 2;
        $lvl[6] = $args[0] when 1;
        default { return; }
    }
    my $mood = curMood;
    given ($mood) {
        when ($_ > $ml[0]) { ta->getValue($lvl[0], $env) // continue; }
        when ($_ > $ml[1]) { ta->getValue($lvl[1], $env) // continue; }
        when ($_ > $ml[2]) { ta->getValue($lvl[2], $env) // continue; }
        when ($_ > $ml[3]) { ta->getValue($lvl[3], $env) // continue; }
        when ($_ > $ml[4]) { ta->getValue($lvl[4], $env) // continue; }
        when ($_ > $ml[5]) { ta->getValue($lvl[5], $env) // continue; }
        default { ta->getValue($lvl[6], $env); }
    }
});
ta->addHandler('literal', sub { $match->parseText(@_); } );
topScope->makeRO;

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
    for (qw/1 2 3/) {
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
    $match->{nickForbidden} = $nickForbidden;
    my $notShownInAt = getReplacement("艾特里显不出的");
    $match->{notShownInAt} = qr/$notShownInAt/;
    my $pre = getReplacement("前");
    $match->{preMatch} = qr/^$pre/;
    my $post = getReplacement("后");
    $match->{postMatch} = qr/$post$/;
    my $tailing = getReplacement("_尾_");
    $match->{tailing} = qr/$tailing$/;
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
    main => sub { my $windy = shift; $windy and $windy->loadConf; },
);
sub loadConfGroup
{
    my ($windy, $group) = @_;
    if ($group eq 'ALL') {
        for (keys %confGroup) {
            $confGroup{$_}->(@_);
        }
    } else {
        if (ref $confGroup{$group} eq 'CODE') {
            $confGroup{$group}->(@_);
        } else {
            undef;
        }
    }
}

1;
