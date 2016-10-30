#!/usr/bin/env perl

use 5.012;
use Scripts::scriptFunctions;
use Mojo::Webqq;
use Mojo::Util qw/md5_sum/;
use Scripts::Windy;
use Time::HiRes qw/time/;
use Scripts::Windy::Util;
no warnings 'experimental';
my $file = $accountDir.'windy';
my $uid;
if (open my $w, '<', $file) {
    chomp ($uid = <$w>);
    close $w;
} else {
    die term "打不开文件 $file: $!\n";
}

my $mainGroupFile = $configDir.'windy-conf/main-group';
my $mainGroupId = undef;
my $mainGroup = undef;
sub loadMainGroupId
{
    if (open my $f, '<', $mainGroupFile) {
        chomp($mainGroupId = <$f>);
        close $f;
    }
}
loadMainGroupId;
my $windy = Scripts::Windy->new(Admin => [], MainGroup => $mainGroupId);

my $t = Mojo::Webqq->new(
    qq => $uid,
    login_type => 'qrlogin',
    tmpdir => $configDir.'windy-cache/',
    qrcode_path => $Scripts::scriptFunctions::home.'/OneDrive/windy.png',
#    is_init_friend => 0,
#    is_init_group => 0,
#    is_init_discuss => 0,
#    is_init_recent => 0,
#    is_update_user => 0,
#    is_update_group => 0,
#    is_update_friend => 0,
#    is_update_discuss => 0,
    );
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
    my $inGroup = ($context ? " 在 ".($context eq 'group' ? $m->group->gname.'('.$m->group->gnumber.')' : $m->discuss->dname) : '');
    $windy->logger("收到 `".$text."` 从 ".$m->sender->displayname.$inGroup);
    #$windy->logger($m->dump);
    my $time = time;
    my $resp = $windy->parse($m);
    if ($resp) {
        $windy->logger("送出 `".$resp."`, 在 ".( time - $time )." 秒内");
        my $to = recordLast($m, $context);
        sendTo($to, $resp);
    }
}
$t->interval(60, \&saveLast);
#$SIG{INT} = sub { saveLast;$t->stop(['auto']); };
$t->timer(2400, sub { saveLast; exit 1; });
#$t->load("PostQRcode",data => $mailAccount ) if %$mailAccount;
$t->on(receive_message => \&onReceive);
$t->on(receive_pic => sub {
    ### 反正这个没成功过。。。
    my ($client,$filepath,$sender)=@_;
    say "receive image: ", $filepath;
    say "sender is: ", $sender->displayname;
       });

my $replyScan = Scripts::Windy::Conf::smartmatch::sr($windyConf->get('initMsg', 'scancode'));
my @reply = map
{ Scripts::Windy::Conf::smartmatch::sr($windyConf->get('initMsg', 'normal', $_)) }
$windyConf->childList('initMsg', 'normal');

use Scripts::Windy::FakeMessage;
my $loginMsg = Scripts::Windy::FakeMessage->loginMsg(_client => $t, receiver => $t->user, _context => $lastChannel);
$t->on(login => sub {
    my $scancode = $_[1];
    if (loadLast) {
        $windy->logger("正发送初始讯息。");
        $scancode and sendTo($lastChannel->[0], $replyScan->run($windy, $loginMsg));
        sendTo($lastChannel->[0], $reply[int rand @reply]->run($windy, $loginMsg));
    }
       });
# 管理权限和主群联通
sub loadMainGroup
{
    if ($mainGroupId) {
        $mainGroup = $t->search_group(gnumber => $mainGroupId);
    }
    $mainGroup;
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
