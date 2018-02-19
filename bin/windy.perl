#!/usr/bin/env perl

BEGIN
{
    $ENV{WINDY_BACKEND} = 'mojo';
}
use 5.012;
use Scripts::scriptFunctions;
use Mojo::Webqq;
use Mojo::Util qw/md5_sum/;
use Time::HiRes qw/time/;
use Scripts::Windy::Util;
no warnings 'experimental';
use Scripts::Windy::Startup;
use Getopt::Long;
use Digest::MD5;
use utf8;
my $debug = 0;
GetOptions('d' => \$debug);
my $mainGroup = undef;
my $t = Mojo::Webqq->new(
    account => $uid,
    pwd => Digest::MD5::md5_hex($password),
    login_type => 'login',
    tmpdir => $configDir.'windy-cache/',
    qrcode_path => $Scripts::scriptFunctions::home.'/OneDrive/windy.png',
    log_level => $debug ? 'debug' : 'info',
    group_member_use_fullcard => 1,
    model_ext => 1,
    group_member_use_markname => 0,
    );

$windy->{_client} = $t;
# last channel
my $lastChannelFile = $configDir."windy-conf/last-channel";
my $lastChannel = [];
sub loadLast
{
    if (open my $f, '<', $lastChannelFile) {
        chomp (my $line = <$f>);
        my ($context, $lastid) = $line =~ /^([DP]?)(\d+)$/;
        my $channel = undef;
        given ($context) {
            $channel = $t->search_discuss(did => $lastid) when 'D';
            $channel = $t->search_friend(qq => $lastid) when 'P';
            $channel = $t->search_group(gnumber => $lastid) when '';
        }
        close $f;
        $windy->logger("上一次的channel是: ".$line);
        $lastChannel = [$channel, $context];
        $channel;
    } else {
        undef;
    }
}
sub recordLast
{
    my ($last, $context) = @_;
    given ($context) {
        $lastChannel = [$last->group, ''] when 'group';
        $lastChannel = [$last->discuss, 'D'] when 'discuss';
        $lastChannel = [$last->sender, 'P'] when undef;
        default { $windy->logger("不能记下现在的channel。"); }
    };
    $lastChannel->[0];
}
sub saveLast
{
    if ($lastChannel and open my $f, '>', $lastChannelFile) {
        binmode $f, ':unix';
        my $id;
        given ($lastChannel->[1]) {
            $id = $lastChannel->[0]->did when 'D';
            $id = $lastChannel->[0]->qq when 'P';
            $id = $lastChannel->[0]->gnumber when '';
        }
        $windy->logger("记下现在的channel是 ".$id."(".$lastChannel->[1].")");
        say $f $lastChannel->[1].$id;
        close $f;
    }
}
sub onReceive
{
    my ($c, $m) = @_;
    my $text = parseRichText($windy, $m);
    #my $text = $m->content;
    my ($context) = $m->type =~ /^(group|discuss)_message$/;
    my $inGroup = ($context ? " 在 ".($context eq 'group' ? msgGroupName($windy, $m) .'('.$m->group->gnumber.')' : msgDiscussName($windy, $m)) : '');
    $windy->logger("收到 `".$text."` 从 ".uName(msgSender($windy, $m)).'('.uid(msgSender($windy, $m)).')'.$inGroup);
    #$windy->logger($m->dump);
    my $time = time;
    my $r = $windy->parse($m);
    my $resp = $r->{Text};
    if (length $resp) {
        my $num = $r->{Num};
        $windy->logger("送出第 ${num} 条 `".$resp."`, 在 ".( time - $time )." 秒内");
        my $to = recordLast($m, $context);
        sendTo($to, $resp);
    }
}
$t->interval(60, \&saveLast);
#$SIG{INT} = sub { saveLast;$t->stop(['auto']); };
$t->timer(2400, sub { saveLast; $t->clean_qrcode; $t->clean_pid; exit 1; });

$t->on(receive_message => \&onReceive);

if ($windyConf->get('initMsg', 'on') == 1) {
$t->on(login => sub {
    my $scancode = $_[1];
    if (loadLast) {
        use Scripts::Windy::FakeMessage;
        my $loginMsg = Scripts::Windy::FakeMessage->loginMsg(_client => $t, receiver => $t->user, _context => $lastChannel);
        $windy->logger("正发送初始讯息。");
        $scancode and sendTo($lastChannel->[0], $replyScan->run($windy, $loginMsg));
        sendTo($lastChannel->[0], $reply[int rand @reply]->run($windy, $loginMsg));
    }
       });
}
# 管理权限和主群联通
sub loadMainGroup
{
    if ($mainGroupId) {
        $mainGroup = $t->search_group(gnumber => $mainGroupId);
    }
    $windy->{mainGroup} = $mainGroup;
}
sub loadAdmins
{
    $windy->{Admin} = [];
    if (loadMainGroup) {
        $windy->{Admin} = [(map { $_->qq } $mainGroup->search_group_member(role => 'admin')),
            (map { $_->qq } $mainGroup->search_group_member(role => 'owner'))];
        $windy->logger("管理列表: ".(join ',', @{$windy->{Admin}}));
    }
}
sub updateAdmin
{
    my (undef,$member,$property,$old,$new) = @_;
    return if $member->group->gnumber ne $mainGroupId or $property ne 'role';
    if ($new eq 'admin' or $new eq 'owner') { # 成为管理就添加
        $windy->logger("添加管理: ". $member->qq);
        push @{$windy->{Admin}}, $member->qq;
    } elsif (($old eq 'admin' or $old eq 'owner') and $new eq 'member') { # 撤销管理就删去
        $windy->logger("撤销管理: ". $member->qq);
        @{$windy->{Admin}} = grep { $member->qq ne $_ } @{$windy->{Admin}};
    }
}
$t->on(login => \&loadAdmins,
    group_member_property_change => \&updateAdmin);
if ($ARGV[0] eq 'scancode') {
    $t->relogin;
} else {
    $t->login;
}
$t->run;
exit 1;
