package Scripts::Windy::Addons::StartStop;
use Exporter;
use 5.012;
use Scripts::scriptFunctions;
no warnings 'experimental';
use Scripts::Windy::Util;
use List::Util qw/first/;
our @ISA = qw/Exporter/;
our @EXPORT = qw/startOn stopOn isStartOn loadGroups/;
my @startGroup = ();

my $file = $configDir.'windy-conf/channels';
sub loadGroups
{
    @startGroup = ();
    if (open my $f, '<', $file) {
        while (<$f>) {
            chomp;
            if (/^(\d+)(?:\t(-?\d+))?$/) {
                my ($group, $start) = ($1, $2);
                push @startGroup, [$group, $start];
            }
        }
        close $f;
    }
    @startGroup;
}

sub saveGroups
{
    if (open my $f, '>', $file) {
        binmode $f, ':unix';
        for (@startGroup) {
            say $f join "\t", @$_;
        }
        close $f;
    }
    @startGroup;
}

sub startOn
{
    my $groupId = shift;
    my $windy = shift;
    my $msg = shift;
    if (! grep $_->[0] eq $groupId, @startGroup) {
        my $uid;
        $uid = ($windy and $msg) ? uid(msgSender($windy, $msg)) : -1;
        push @startGroup, [$groupId, $uid];
        saveGroups;
        $groupId;
    } else {
        undef;
    }
}

sub stopOn
{
    my $groupId = shift;
    if (grep $_->[0] eq $groupId, @startGroup) {
        @startGroup = grep $_->[0] ne $groupId, @startGroup;
        saveGroups;
        $groupId;
    } else {
        undef;
    }
}

sub isStartOn
{
    my $groupId = shift;
    my $array = first { $_->[0] eq $groupId } @startGroup;
    #say "is ?". @$array;
    $array and ($array->[1] or -1);
}

1;
