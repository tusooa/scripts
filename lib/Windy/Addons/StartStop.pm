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
            push @startGroup, [$1, $2] if /^(\d+)(?:\t(\d+))?$/;
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
        $uid = uid(msgSender($windy, $msg)) if $windy and $msg;
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
