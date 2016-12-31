package Scripts::Windy::Addons::Sense;
use Scripts::Windy::Util;
use Scripts::scriptFunctions;
#$Scripts::scriptFunctions::debug = 1;
use Exporter;
use 5.012;
our @ISA = qw/Exporter/;
our @EXPORT = qw/sense addSense loadSense/;

my $cfg = $windyConf;
my $maxAdd;
sub loadConf
{
    $maxAdd = $cfg->get('sense', 'maxAdd') // 10;#每日最多增加多少好感
}

# (id => [sense, added-today, last-time-modified])
my %sense;
my $filename = $configDir.'windy-conf/sense';
sub loadSense
{
    if (open my $f, '<', $filename) {
        while (<$f>) {
            chomp;
            /^(.+)\t(.+)\t(.+)\t(.+)$/;
            $sense{$1} = [$2, $3, $4];
        }
    }
}

sub sense
{
    my $id = shift;
    $sense{$id} = [0, 0, time2date] if not $sense{$id};
    $sense{$id}->[0];
}

sub addSense
{
    my $id = shift;
    my $add = shift;
    debug "\e[33madding $add to $id.\e[0m";
    $sense{$id} = [0, 0, time2date] if not $sense{$id};
    my $lastTime = $sense{$id}->[2];
    my $thisTime = time2date;
    if ($lastTime ne $thisTime) {
        $sense{$id}->[1] = 0;
        $sense{$id}->[2] = $thisTime;
    }
    my $addedToday = $sense{$id}->[1];
    if ($addedToday + $add > $maxAdd) { # 超过上限
        $add = $maxAdd - $addedToday;
        debug "\e[33mActually add $add\e[0m";
    }
    $sense{$id}->[1] += $add;
    $sense{$id}->[0] += $add;
    debug "\e[33m".$sense{$id}->[0].",".$sense{$id}->[1]."\e[0m";
    if (open my $f, '>>', $filename) {
        binmode $f, ':unix';
        say $f join "\t", $id, @{$sense{$id}};
    }
    wantarray ? ($sense{$id}->[0], $add) : $sense{$id}->[0];
}

sub clearUp
{
    scalar keys %sense or return; # not loading anything
    if (open my $f, '>', $filename) {
        binmode $f, ':unix';
        for (sort { $a <=> $b } keys %sense) {
            say $f join "\t", $_, @{$sense{$_}};
        }
    } else {
        die term "Cannot open $filename for write:$!\n";
    }
}

1;
