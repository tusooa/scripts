package Scripts::Windy::Addons::Nickname;
use Scripts::Windy::Util;
use Scripts::scriptFunctions;
$Scripts::scriptFunctions::debug = 1;
use Exporter;
use 5.012;
our @ISA = qw/Exporter/;
our @EXPORT = qw/senderNickname newNick loadNicknames/;
our @EXPORT_OK = qw//;

my %nick;

sub senderNickname
{
    my ($self, $windy, $msg) = @_;
#    debug Dumper($msg);
    my $sender = msgSender($windy, $msg);
    my $id = uid($sender);
    $nick{$id}->[0] // uName($sender);
}

sub loadNicknames
{
    if (open my $f, '<', $configDir.'windy-conf/nickname') {
        while (<$f>) {
            chomp;
            /^(.+)\t(.+)$/;
            $nick{$1} = [] if not $nick{$1};
            unshift @{$nick{$1}}, $2;
        }
    }
}

sub newNick
{
    my ($id, $nick) = @_;
    unshift @{$nick{$id}}, $nick;
    if (open my $f, '>>', $configDir.'windy-conf/nickname') {
        say $f $id."\t".$nick;
    }
}

1;
