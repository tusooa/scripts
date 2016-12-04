package Scripts::Windy::Addons::Nickname;
use Scripts::Windy::Util;
use Scripts::scriptFunctions;
#$Scripts::scriptFunctions::debug = 1;
use Exporter;
use 5.012;
use utf8;
use Encode qw/_utf8_on _utf8_off/;
our @ISA = qw/Exporter/;
our @EXPORT = qw/userNickname nicknameById senderNickname newNick loadNicknames/;
our @EXPORT_OK = qw//;

my %nick;

sub userNickname
{
    my ($self, $user) = @_;
    $user or return;
    my $id = uid($user);
    $nick{$id}->[0] or do { my $name = uName($user); _utf8_on($name); $name; };
}

sub nicknameById
{
    my ($self, $id) = @_;
    $nick{$id}->[0] or $id;
}

sub senderNickname
{
    my ($self, $windy, $msg) = @_;
#    debug Dumper($msg);
    my $sender = msgSender($windy, $msg);
    userNickname($self, $sender);
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
            _utf8_on($_);
            my ($id, $sticky, $nickname) = /^(\d+)(S?)\t(.+)$/;
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
    $nick{$id} = [] if not $nick{$id};
    makeSticky $nick{$id} if $sticky;
    if ($sticky or not isSticky $nick{$id}) {
        unshift @{$nick{$id}}, $nick;
        if (open my $f, '>>', $configDir.'windy-conf/nickname') {
            my $n = $nick;_utf8_off($n);
            binmode $f, ':unix';
            say $f $id.($sticky ? 'S' : '')."\t".$n;
        }
        $nick; # return the nickname
    } else {
        undef; # failed
    }
}

1;
