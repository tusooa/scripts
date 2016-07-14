package Scripts::Windy::Addons::StartStop;
use Exporter;
use 5.012;
use Scripts::scriptFunctions;
no warnings 'experimental';
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
            push @startGroup, $_ if $_;
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
            say $f $_;
        }
        close $f;
    }
    @startGroup;
}

sub startOn
{
    my $groupId = shift;
    if (! grep $_ eq $groupId, @startGroup) {
        push @startGroup, $groupId;
        saveGroups;
        $groupId;
    } else {
        undef;
    }
}

sub stopOn
{
    my $groupId = shift;
    if (grep $_ eq $groupId, @startGroup) {
        @startGroup = grep $_ ne $groupId, @startGroup;
        $groupId;
    } else {
        undef;
    }
}

sub isStartOn
{
    my $groupId = shift;
    $groupId ~~ @startGroup;
}

1;
