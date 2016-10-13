
package Scripts::Windy::MyPCQQ;
use 5.012;
use Scripts::scriptFunctions;
use utf8;
use Scripts::Windy;
use Time::HiRes qw/time/;
use Scripts::Windy::Util::MPQ;
no warnings 'experimental';
use Scripts::Windy::Constants;
use Scripts::Windy::Event;
#use MPQ;
our @ISA = qw/Exporter/;
our @EXPORT = qw/info set about EventFun Message/;

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
our $windy = Scripts::Windy->new(Admin => [], MainGroup => $mainGroupId);
sub loadAdmins
{
    my ($msg) = @_;
    $windy->{Admin} = [getAdminList($windy, $msg, $mainGroupId)];
    $windy->logger("管理列表: ".(join ',', @{$windy->{Admin}}));
}

sub info { term "何事西风不待人w"; }
sub set {}
sub about {}

my @initMsg = map $Events{$_}, 'login', 'plugin-load', 'plugin-enable';
sub EventFun
{
    my $ret = $EventRet{pass};
    my $event = Scripts::Windy::Event->new(@_);
    if ($event->{type} ~~ @initMsg) {
        loadAdmins($event);
    }
    my $time = time;
    parseRichText($windy, $event);
    $windy->logger("收到".msgText($windy, $event));
    my $resp = $windy->parse($event);
    if ($resp) {
        $windy->logger("送出 `$resp` 在 ". (time - $time)." 秒内");
        $ret = replyToMsg($windy, $event, $resp);
    } else {
        #$windy->logger("没送出什么。");
    }
    $ret;
}
1;
