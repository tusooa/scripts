package Scripts::Windy::Addons::BlackList;
use Exporter;
use Scripts::scriptFunctions;
our @ISA = qw/Exporter/;
our @EXPORT = qw/addBlackList loadBlackList removeBlackList onBlackList/;

my %blackList;
my $file = $configDir.'windy-conf/blacklist';
sub loadBlackList
{
    if (open my $f, '<', $file) {
        while (<$f>) {
            if (/(-?)(\d+)/) {
                $blackList{$2} = ! $1;
            }
        }
    }
}

sub addBlackList
{
    my $id = shift;
    $blackList{$id} = 1;
    if (open my $f, '>>', $file) {
        binmode $f, ':unix';
        say $f $id;
    }
}

sub removeBlackList
{
    my $id = shift;
    $blackList{$id} = 0;
    if (open my $f, '>>', $file) {
        binmode $f, ':unix';
        say $f '-'.$id;
    }
}

sub onBlackList
{
    my $id = shift;
    $blackList{$id};
}

1;
