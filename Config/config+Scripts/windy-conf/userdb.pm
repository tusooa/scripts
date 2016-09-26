package Scripts::Windy::Conf::userdb;

use 5.012;
use Scripts::scriptFunctions;
#$Scripts::scriptFunctions::debug = 0;
no warnings 'experimental';
use Scripts::Windy::Util;
use Scripts::Windy::Userdb;
use Scripts::Windy::Conf::smartmatch;
use Exporter;
use Data::Dumper;
use utf8;

sub reloadDB;

our @ISA = qw/Exporter/;
our @EXPORT = qw/$database/;
our $database = Scripts::Windy::Userdb->new();
#sub debug { print @_; }
my @adminList;
if (open my $f, '<', $configDir.'windy-conf/admin') {
    while (<$f>) {
        chomp;
        push @adminList, $_ if $_;
    }
    close $f;
}

sub msgSenderIsAdmin
{
    my $windy = shift;
    my $msg = shift;
    my $id = uid(msgSender($windy, $msg));
    my @a = (@adminList, @{$windy->{Admin}});
    $id ~~ @a;
}

my $startRes1 = sr("【截止】【好感判：喵喵喵www咱在这里呢w,来了来了qwq,好好好，什么事啊- -,你为什么要召唤我。】");
my $startRes1F = sr("【截止】好像哪里不对（思考");
my $startRes2 = sr("【截止】");
sub start
{
    my $windy = shift;
    my $msg = shift;
    if (msgSenderIsGroupAdmin($windy, $msg)
         or msgSenderIsAdmin($windy, $msg)) {
        $subs->{start}(undef, $windy, $msg, undef, @_)
            and $startRes1->run($windy, $msg, @_)
            or $startRes1F->run($windy, $msg, @_);
    } else {
        $startRes2->run($windy, $msg, @_);
    }
}

my $startGRes1 = sr("【截止】听从神之召唤【心情判：w,- -,,。】");
my $startGRes1F = sr("【截止】召唤失败了【心情判：qwq,- -,,。】");
my $startGRes2 = sr("【截止】。。。");
sub startG
{
    my $windy = shift;
    my $msg = shift;
    my ($group) = @_;
    if (msgSenderIsAdmin($windy, $msg)) {
        $subs->{start}(undef, undef, undef, $group, @_)
            and $startGRes1->run($windy, $msg, @_)
            or $startGRes1F->run($windy, $msg, @_);
    } else {
        $startGRes2->run($windy, $msg, @_);
    }
}

my $stopGRes1 = sr("【截止】于是我就这么消失了【心情判：w,- -,,。】");
my $stopGRes1F = sr("【截止】出现了什么问题【心情判：qwq,- -,,。】");
my $stopGRes2 = sr("【截止】。。。");
sub stopG
{
    my $windy = shift;
    my $msg = shift;
    my ($group) = @_;
    if (msgSenderIsAdmin($windy, $msg)) {
        $subs->{stop}(undef, undef, undef, $group, @_)
            and $stopGRes1->run($windy, $msg, @_)
            or $stopGRes1F->run($windy, $msg, @_);
    } else {
        $stopGRes2->run($windy, $msg, @_);
    }
}

my $stopRes1 = sr("【截止】【好感判：诶喵qwq那咱家走惹。。。,令咒的力量真是强大呢- -,是是是我很烦- -,woc你就是想赶我走？】");
my $stopRes1F = sr("【截止】然而这并没有什么用QAQ");
my $stopRes2 = sr("【截止】【好感判：来讯者名+为什么要赶人家走呢qwq,- -令咒用光了吧,,不回去。】");
sub stop
{
    my $windy = shift;
    my $msg = shift;

    if (msgSenderIsGroupAdmin($windy, $msg)
        or msgSenderIsAdmin($windy, $msg)) {
        $subs->{stop}(undef, $windy, $msg, undef, @_)
            and $stopRes1->run($windy, $msg, @_)
            or $stopRes1F->run($windy, $msg, @_);
    } else {
        $stopRes2->run($windy, $msg, @_);
    }
}

my $cRes = sr("【截止】听从【捕获1】的召唤而来【心情判】");
sub callerName
{
    my $windy = shift;
    my $msg = shift;
    my $name = $subs->{callerName}(undef, $windy, $msg, @_);
    $cRes->run($windy, $msg, $name);
}

my $teachRes1 = sr("【截止】可以这很【来讯者名】【好感判：w,0 0,- -,。】");
my $teachRes2 = sr("诶...?QAQ");
my $teachRes3 = sr("...");
sub teach
{
    my $windy = shift;
    my $msg = shift;
    my ($ask, $ans, $style) = @_;
    debug 'teaching:';
    debug 'ques:'.$ask;
    debug 'answ:'.$ans;
    return if !$ask or !$ans;
    my $sense = $subs->{sense}(undef, $windy, $msg);
    if (#$sense > $sl1,
        msgSenderIsAdmin($windy, $msg)) { # 正常运作
        debug "adding";
        $windy->logger("添加「${ask}」 => 「${ans}」");
        $database->add([sm($ask), sr($ans)]);
        if (open my $f, '>>', $configDir.'windy-conf/userdb.db') {
            binmode $f, ':unix';
            say $f "$style\tAsk$ask\n\tAns$ans";
        } else {
            debug 'cannot open db for write'."$!";
        }
        $teachRes1->run($windy, $msg, @_);
    } elsif ($sense > $sl2) { # 
        $teachRes2->run($windy, $msg, @_);
    } else {
        $teachRes3->run($windy, $msg, @_);
    }
}

my $nickRes = sr("【截止】【来讯者名】qwq咱知道惹");
my $nickResF = sr("【截止】诶？");
sub newNickname
{
    my $windy = shift;
    my $msg = shift;
    my ($nick) = @_;
    $subs->{newNick}(undef, $windy, $msg, $nick) ?
        $nickRes->run($windy, $msg, @_) :
        $nickResF->run($windy, $msg, @_);
}

my $assignRes1 = sr("【截止】好哒【来讯者名】w");
my $assignRes1F = sr("【截止】咪呼w...？");
my $assignRes2 = sr("喵...喵呼w？");
my $assignRes3 = sr("....");
sub assignNickname
{
    my $windy = shift;
    my $msg = shift;
    my ($id, $nick, $sticky) = @_;
    my $sense = $subs->{sense}(undef, $windy, $msg);
    if (msgSenderIsAdmin($windy, $msg)) {
        $subs->{assignNick}(undef, $windy, $msg, $id, $nick, $sticky) ?
            $assignRes1->run($windy, $msg, @_) :
            $assignRes1F->run($windy, $msg, @_);
    } elsif ($sense > $sl2) {
        $assignRes2->run($windy, $msg, @_);
    } else {
        $assignRes3->run($windy, $msg, @_);
    }
}

my $blackListRes1 = sr("【截止】咱听【来讯者名】的w");
my $blackListRes2 = sr("我不会考虑的w（笑");
my $blackListRes3 = sr("....");
sub blackList
{
    my ($windy, $msg, $id, $status) = @_;
    my $sense = $subs->{sense}(undef, $windy, $msg);
    if (msgSenderIsAdmin($windy, $msg)) {
        $subs->{blackList}(undef, $windy, $msg, $id, $status);
        $blackListRes1->run(@_);
    } elsif ($sense > $sl2) {
        $blackListRes2->run(@_);
    } else {
        $blackListRes3->run(@_);
    }
}

my $sizeRes = sr("【截止】也就【捕获1】条吧【心情判】【下讯】哦对还要加上【捕获2】个词呢【心情判】所以一共是【捕获3】啦【心情判】");
sub sizeOfDB
{
    my ($windy, $msg) = @_;
    my ($dbSize, $matchSize) = ($database->length, sizeOfMatch);
    $sizeRes->run($windy, $msg, $dbSize, $matchSize, $dbSize + $matchSize);
}

my $addRRes1 = $teachRes1;
my $addRRes1F = sr("【截止】然而机智的我早已记住了【心情判：ww,- -,,。】");
my $addRRes1E = sr("【截止】不可以的。。这样做会死人的。。");
my $addRRes2 = sr("。。。。");
sub addR
{
    my ($windy, $msg, $rep, $name) = @_;
    my $quotemeta = pop;
    if (msgSenderIsAdmin($windy, $msg)) {
        my $ret = $subs->{addR}($name, $rep, $quotemeta);
        if ($ret) {
            $addRRes1->run(@_);
        } elsif (defined $ret) { # 0 for error
            $addRRes1E->run(@_);
        } else { # undef for already-existed
            $addRRes1F->run(@_);
        }
    } else {
        $addRRes2->run(@_);
    }
}

my $getRRes1 = sr("【截止】据我所知，【捕获1】大约是「【捕获2】」【心情判：w,- -,,。】");
my $getRRes1F = sr("【截止】大约是字面意思吧【心情判：qwq,0 0,,。】");
my $getRRes2 = sr("。。。");
sub getR
{
    my ($windy, $msg, $name) = @_;
    my $rep = $subs->{getR}($name, 'AS_IS');
    if (msgSenderIsAdmin($windy, $msg)) {
        $rep ? $getRRes1->run($windy, $msg, $name, $rep) : $getRRes1F->run(@_);
    } else {
        $getRRes2->run(@_);
    }
}

my $reloadRes1 = sr("【截止】好的【心情判：w,0 0,,。】");
my $reloadRes2 = sr("【截止】我不会考虑的【心情判：x,- -,,。】");
sub reloadAll
{
    if (msgSenderIsAdmin(@_)) {
        $subs->{reloadR}();
        reloadDB;
        $reloadRes1->run(@_);
    } else {
        $reloadRes2->run(@_);
    }
}

my $quitRes = sr("【截止】我拒绝。");
sub quit
{
    if (msgSenderIsAdmin(@_)) {
        exit pop;
    } else {
        $quitRes->run(@_);
    }
}
reloadDB;

my $inviteRes1 = sr("【截止】拉了【好感判：w,- -,,。】");
#my $inviteRes1F = "【截止】woc你明明已经在了啊【好感判:x,- -,,。】";
my $inviteRes2 = sr("【截止】鬼知道什么原因不能拉- -给你个群号吧- -【捕获1】");
sub inviteMG
{
    my ($windy, $msg) = @_;
    # 很难过。
    # 因为这个eval从来没成功过。
    eval { invite($windy, $msg,
           group($windy, $msg, $windy->{MainGroup}),
                  friend(msgSenderId($windy, $msg))) }
        ? $inviteRes1->run(@_) :
            $inviteRes2->run($windy, $msg, $windy->{MainGroup});
}

### sandbook
use Scripts::Windy::Addons::Sandbook;
my $sandbook = Scripts::Windy::Addons::Sandbook->new;

my $getSandbookRes = sr("【截止】【来讯者名】，关于【捕获2】的一句。<下讯>【捕获1】");
my $getSandbookResF = sr("没找到- -");
sub getSandbook
{
    my ($windy, $msg, $db) = @_;
    my @a = $sandbook->read($db);
    @a ? $getSandbookRes->run($windy, $msg, @a)
        : $getSandbookResF->run($windy, $msg, $db);
}

my $addSandbookRes1 = sr("【截止】嗯。");
my $addSandbookRes1F = sr("【截止】没这说法。");
my $addSandbookRes2 = sr("？？？");
sub addSandbook
{
    my ($windy, $msg, $db, $sentence) = @_;
    if (msgSenderIsAdmin($windy, $msg)) {
        $sandbook->addSave($db, $sentence) ?
            $addSandbookRes1->run(@_) :
            $addSandbookRes1F->run(@_);
    } else {
        $addSandbookRes2->run(@_);
    }
}

my $repeatRes = sr("【捕获1】");
sub repeat
{
    my ($windy, $msg, $content) = @_;
    if (msgSenderIsAdmin($windy, $msg)) {
        sr($content)->run(@_);
    } else {
        $repeatRes->run(@_);
    }
}

sub reloadDB
{
    my @baseDB = (
        [smS(qr/【对我】出来/), \&start],
        [sm("【不是私讯而且不是群讯开启】"), sr("【截止】")],
        [smS(qr/<风妹>(?:<以后>)?<不要>理睬?(\d+)/), sub { blackList(@_, 1); }],
        [smS(qr/<风妹>(?:<以后>)?<不要>不理睬?(\d+)/), sub { blackList(@_, 0); }],
        [sm("【被屏蔽】"), sr("【截止】")],
        [smS(qr/【对我】回去/), \&stop],
        [sm(qr/^<风妹>当问(.+?)则答(.+)$/s), sub { teach(@_, 'S'); }],
        [sm(qr/^<风妹>对问(.+?)则答(.+)$/s), sub { teach(@_, 's'); }],
        [smS(qr/<判定〔<风妹>,<怎么>出来〕>/), \&callerName],
        [smS(qr/【对我】知道<多少>/), \&sizeOfDB],
        [sm(qr/^<风妹>若问(.+?)即答(.+)$/s), \&teach],
        [sm(qr/^<风妹>问(.+?)答(.+)$/s), sub { $_[2] = '^'.$_[2].'$'; teach(@_); }],
        [sm(qr/^<风妹>(?:<以后>)?<称呼><我>(?:作|为|叫)?(.+?)(?:<就好>)?$/), \&newNickname],
        [sm(qr/^<风妹>(?:<以后>)?<称呼>(\d+)(?:作|为|叫)?(.+?)(?:<就好>)?$/), \&assignNickname],
        [sm(qr/^<风妹>(?:<以后>)?一直都?<称呼>(\d+)(?:作|为|叫)?(.+?)(?:<就好>)?$/), sub { assignNickname @_, 1; }],
        [sm(qr/^喵 复述(.+)$/), \&repeat],
        [sm(qr/^<风妹>(?:<以后>)?<记得>(.+?)也是(.+)$/), sub { addR(@_, 0); }],
        [sm(qr/^<风妹>(?:<以后>)?<记得>(.+?)亦是(.+)$/), sub { addR(@_, 1); }],
        [sm(qr/^<风妹><什么><是>(.+)$/), \&getR],
        [smS(qr/【对我】重生/), \&reloadAll],
        [sm(qr/^<风妹>天降于?(\d+)<后>$/), \&startG],
        [sm(qr/^<风妹>消失于?(\d+)<后>$/), \&stopG],
        [smS(qr/<风妹>以神之名义命令<中>重生/), sub { quit(@_, 1); }],
        [smS(qr/【对我】主群拉<一下>/), \&inviteMG],
        [sm(qr/^沙书\s*(.*)\s*$/), \&getSandbook],
        [sm(qr/^<风妹>加一?句(.+?)「(.+)」$/s), \&addSandbook],
        [smS(qr/【对我】来扫个码/), sub { quit(@_, 0); }],
        );
    $database->set(@baseDB);
    $database->{_match} = $match;
    if (open my $f, '<', $configDir.'windy-conf/userdb.db') {
        my ($ask, $ans, $style);
        my $ref;
        while (<$f>) {
            if (s/^(.?)\tAsk//) {
                my $newStyle = $1;
                chomp ($ask, $ans);
                $database->add([sm({ style => $style }, $ask), sr($ans)]) if $ask and $ans;
                $ask = '';
                $ans = '';
                $ref = \$ask;
                $style = $newStyle;
            } elsif (s/^\tAns//) {
                $ref = \$ans;
            }
            $$ref .= $_ unless /^$/;
        }
        chomp ($ask, $ans);
        $database->add([sm({ style => $style }, $ask), sr($ans)]) if $ask and $ans;
        close $f;
    } else {
        debug 'cannot open';
    }
}
1;
