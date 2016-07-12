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
our @ISA = qw/Exporter/;
our @EXPORT = qw/$database loadGroups/;
our $database;
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
    $id ~~ @adminList;
}

my $channelFile = $configDir.'windy-conf/channels';
sub loadGroups
{
    my @lastGroups;
    if (open my $f, '<', $channelFile) {
        while (<$f>) {
            chomp;
            push @lastGroups, $_ if $_;
        }
        close $f;
    }
    @lastGroups;
}
my $startRes1 = sr("【截止】咱在这里呢w");
#use Data::Dumper;
#use Mojo::Webqq::Message::Recv::GroupMessage;
#die Dumper (($startRes1)->({}, bless { content => '1234',}, 'Mojo::Webqq::Message::Recv::GroupMessage'));
my $startRes2 = sr("【截止】嗯哼0 0?");
sub start
{
    my $windy = shift;
    my $msg = shift;
    #$windy->{startGroup} = [@lastGroups] if ref $windy->{startGroup} ne 'ARRAY';# 初始化.
    if ((msgSenderIsGroupAdmin($windy, $msg)
         or msgSenderIsAdmin($windy, $msg))
        and ! grep $_ eq msgGroupId($windy, $msg), @{$windy->{startGroup}}) {
        push @{$windy->{startGroup}}, msgGroupId($windy, $msg);
        debug "starting on ".msgGroupId($windy, $msg);
        if (open my $f, '>', $channelFile) {
            debug "opening file,";
            binmode $f, ':unix';
            say $f $_ for @{$windy->{startGroup}};
            close $f;
        } else {
            debug "cannot open file:$!";
        }
        $startRes1->($windy, $msg, @_);
    } else {
        $startRes2->($windy, $msg, @_);
    }
}

my $stopRes1 = sr("【截止】那...咱走惹QAQ");
my $stopRes2 = sr("【截止】诶..?qwq");
sub stop
{
    my $windy = shift;
    my $msg = shift;
#    $windy->{startGroup} = [@{$windy->{startGroup}}] if ref $windy->{startGroup} ne 'ARRAY';
    if (msgSenderIsGroupAdmin($windy, $msg)
        or msgSenderIsAdmin($windy, $msg)# and grep $_ eq msgGroupId($windy, $msg), @{$windy->{startGroup}}
        ) {
        @{$windy->{startGroup}} = grep $_ ne msgGroupId($windy, $msg), @{$windy->{startGroup}};
        if (open my $f, '>', $channelFile) {
            binmode $f, ':unix';
            say $f $_ for @{$windy->{startGroup}};
            close $f;
        }
        $stopRes1->($windy, $msg, @_);
    } else {
        $stopRes2->($windy, $msg, @_);
    }
}

my $teachRes1 = sr("【截止】咱好像明白惹w");
my $teachRes2 = sr("诶...?QAQ");
my $teachRes3 = sr("...");
sub teach
{
    my $windy = shift;
    my $msg = shift;
    my ($ask, $ans) = @_;
    debug 'teaching:';
    debug 'ques:'.$ask;
    debug 'answ:'.$ans;
    return if !$ask or !$ans;
    my $sense = $subs->{sense}(undef, $windy, $msg);
    if (#$sense > $sl1,
        msgSenderIsAdmin($windy, $msg)) { # 正常运作
        debug "adding";
        $database->add([sm($ask), sr($ans)]);
        if (open my $f, '>>', $configDir.'windy-conf/userdb.db') {
            binmode $f, ':unix';
            say $f "\tAsk$ask\n\tAns$ans";
        } else {
            debug 'cannot open db for write'."$!";
        }
        $teachRes1->($windy, $msg, @_);
    } elsif ($sense > $sl2) { # 
        $teachRes2->($windy, $msg, @_);
    } else {
        $teachRes3->($windy, $msg, @_);
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
        $nickRes->($windy, $msg, @_) :
        $nickResF->($windy, $msg, @_);
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
            $assignRes1->($windy, $msg, @_) :
            $assignRes1F->($windy, $msg, @_);
    } elsif ($sense > $sl2) {
        $assignRes2->($windy, $msg, @_);
    } else {
        $assignRes3->($windy, $msg, @_);
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
        $blackListRes1->($windy, $msg, @_);
    } elsif ($sense > $sl2) {
        $blackListRes2->($windy, $msg, @_);
    } else {
        $blackListRes3->($windy, $msg, @_);
    }
}

my $nowAndThen = qr/(?:(?:以|今|而)后)?/;
$database = Scripts::Windy::Userdb->new(
[sm(qr/^<风妹>出来$/), \&start],
[sm("【不是群讯】"), sr("【截止】")],
[sm(qr/^<风妹>${nowAndThen}别理(\d+)(?:了)?$/), sub { blackList(@_, 1); }],
[sm(qr/^<风妹>${nowAndThen}别不理(\d+)(?:了)?$/), sub { blackList(@_, 0); }],
[sm("【被屏蔽】"), sr("【截止】")],
[sm(qr/^<风妹>回去$/), \&stop],
[sm(qr/^<风妹>若问(.+?)即答(.+)$/), \&teach],
[sm(qr/^<风妹>问(.+?)答(.+)$/), sub { $_[2] = '^'.$_[2].'$'; teach(@_); }],
[sm(qr/^<风妹>当问(.+?)则答(.+)$/), sub { $_[2] = '^<前>'.$_[2].'<后>$'; teach(@_); }],
[sm(qr/^<风妹>$nowAndThen(?:叫|称呼|呼|唤|喊)<我>(?:作|为|叫)?(.+?)(?:就好|就行|就可以(?:了)?|就是(?:了)?)?$/), \&newNickname],
[sm(qr/^<风妹>$nowAndThen(?:叫|称呼|呼|唤|喊)(\d+)(?:作|为|叫)?(.+?)(?:就好|就行|就可以(?:了)?|就是(?:了)?)?$/), \&assignNickname],
[sm(qr/^<风妹>${nowAndThen}一直(?:都)?(?:叫|称呼|呼|唤|喊)(\d+)(?:作|为|叫)?(.+?)(?:就好|就行|就可以(?:了)?|就是(?:了)?)?$/), sub { assignNickname @_, 1; }],
);


if (open my $f, '<', $configDir.'windy-conf/userdb.db') {
    my ($ask, $ans);
    my $ref;
    while (<$f>) {
        if (s/^\tAsk//) {
            chomp ($ask, $ans);
            $database->add([sm($ask), sr($ans)]) if $ask and $ans;
            $ask = '';
            $ans = '';
            $ref = \$ask;
        } elsif (s/^\tAns//) {
            $ref = \$ans;
        }
        $$ref .= $_;
    }
    chomp ($ask, $ans);
    $database->add([sm($ask), sr($ans)]) if $ask and $ans;
    close $f;
} else {
    debug 'cannot open';
}

1;
