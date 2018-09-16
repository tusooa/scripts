package Scripts::Windy::Addons::StartStop;
use Exporter;
use 5.012;
use Scripts::Base;
no warnings 'experimental';
use Scripts::Windy::Util;
use List::Util qw/first/;
our @ISA = qw/Exporter/;
our @EXPORT = qw/startOn stopOn isStartOn loadGroups/;
my %startGroup = ();

my $default;
sub loadConf
{
    $default = Scripts::Windy::Conf::smartmatch::sr($windyConf->get('startstop', 'default') // -1);
}

my $file = $configDir.'windy-conf/channels';
sub loadGroups
{
    %startGroup = ();
    if (open my $f, '<', $file) {
        while (<$f>) {
            chomp;
            if (/^(\d+[DP]?)(?:\t(-?\d+))?$/) {
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
    if (not isStartOn($groupId, $windy, $msg)) {
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
    my ($groupId, $windy, $msg) = @_;
    if (isStartOn($groupId, $windy, $msg)) {
        $startGroup{$groupId} = 0;
        saveGroups;
        $groupId;
    } else {
        undef;
    }
}

sub isStartOn
{
    my ($groupId, $windy, $msg) = @_;
    $startGroup{$groupId} // $default->run($windy, $msg);
}

1;
