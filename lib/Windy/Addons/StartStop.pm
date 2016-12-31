package Scripts::Windy::Addons::StartStop;
use Exporter;
use 5.012;
use Scripts::scriptFunctions;
no warnings 'experimental';
use Scripts::Windy::Util;
use List::Util qw/first/;
our @ISA = qw/Exporter/;
our @EXPORT = qw/startOn stopOn isStartOn loadGroups/;
my %startGroup = ();

my $default;
sub loadConf
{
    $default = $windyConf->get('startstop', 'default') // -1;
}

my $file = $configDir.'windy-conf/channels';
sub loadGroups
{
    %startGroup = ();
    if (open my $f, '<', $file) {
        while (<$f>) {
            chomp;
            if (/^(\d+)(?:\t(-?\d+))?$/) {
                my ($group, $start) = ($1, $2);
                $startGroup{$group} = $start;
            }
        }
        close $f;
    }
    %startGroup;
}

sub saveGroups
{
    if (open my $f, '>', $file) {
        binmode $f, ':unix';
        for (keys %startGroup) {
            say $f join "\t", $_, $startGroup{$_};
        }
        close $f;
    }
    %startGroup;
}

sub startOn
{
    my $groupId = shift;
    my $windy = shift;
    my $msg = shift;
    if (not isStartOn($groupId)) {
        my $uid;
        $uid = ($windy and $msg) ? uid(msgSender($windy, $msg)) : -1;
        $startGroup{$groupId} = $uid;
        saveGroups;
        $groupId;
    } else {
        undef;
    }
}

sub stopOn
{
    my $groupId = shift;
    if (isStartOn($groupId)) {
        $startGroup{$groupId} = 0;
        saveGroups;
        $groupId;
    } else {
        undef;
    }
}

sub isStartOn
{
    my $groupId = shift;
    $startGroup{$groupId} //= $default;
}

1;
