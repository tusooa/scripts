package Scripts::Windy::Addons::Nickname;
use Scripts::Windy::Util;
use Scripts::scriptFunctions;
#$Scripts::scriptFunctions::debug = 1;
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
my $s = 'Scripts::Windy::Addons::Nickname::Sticky';

sub makeSticky
{
    bless shift, $s;
}

sub isSticky
{
    ref shift eq $s;
}

sub loadNicknames
{
    if (open my $f, '<', $configDir.'windy-conf/nickname') {
        while (<$f>) {
            chomp;
            my ($id, $sticky, $nickname) = /^(.+)(S?)\t(.+)$/;
            $nick{$id} = [] if not $nick{$id};
            if ($sticky or not isSticky $nick{$id}) {
                unshift @{$nick{$id}}, $nickname;
            }
            makeSticky $nick{$id} if $sticky;
        }
    }
}

sub newNick
{
    my ($id, $nick, $sticky) = @_;
    makeSticky $nick{$id} if $sticky;
    if ($sticky or not isSticky $nick{$id}) {
        unshift @{$nick{$id}}, $nick;
        if (open my $f, '>>', $configDir.'windy-conf/nickname') {
            binmode $f, ':unix';
            say $f $id.($sticky ? 'S' : '')."\t".$nick;
        }
        $nick; # return the nickname
    } else {
        undef; # failed
    }
}

1;
