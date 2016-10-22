package Scripts::Windy::Addons::Mood;

use Exporter;
use 5.012;
use Scripts::scriptFunctions;
use Scripts::Windy::Util;
our @ISA = qw/Exporter/;
our @EXPORT = qw/loadMood addMood curMood/;

my $file = $configDir.'windy-conf/mood.db';
my @mood = ();
my ($max, $min, $maxc, $minc, $posi);
sub loadConf
{
    my $cfg = $windyConf;
    $max = $cfg->get('mood', 'max') // 100;
    $min = $cfg->get('mood', 'min') // -100;
    $maxc = $cfg->get('mood', 'max-change-after-midnight') // 40;
    $minc = $cfg->get('mood', 'min-change-after-midnight') // -40;
    $posi = $cfg->get('mood', 'posibility-reverse') // 0.0001; # 最高和最低心情的转化
}
loadConf;
sub fixMood
{
    my $today = time2date;
    my $changed = 0;
    if ($mood[1] ne $today) {
        $mood[0] += randFromTo($minc, $maxc);
        $mood[1] = $today;
        $mood[2] = '';
        $changed = 1;
    }
    if ($mood[0] > $max) { $mood[0] = rand > $posi ? $max : $min; $changed = 1; }
    if ($mood[0] < $min) { $mood[0] = rand > $posi ? $min : $max; $changed = 1; }
    $changed;
}

sub writeMood
{
    if (open my $f, '>>', $file) {
        binmode $f, ':unix';
        say $f join "\t", @mood;
    } else {
        undef;
    }
}

# current-mood<tab>date<tab>id
sub loadMood
{
    if (open my $f, '<', $file) {
        while (<$f>) {
            chomp;
            if (/^(\d+)\t(\d+-\d+-\d+)\t(\d*)$/) {
                @mood = ($1, $2, $3);
            }
        }
        close $f;
    }
    fixMood and writeMood;
    wantarray ? @mood : $mood[0];
}

sub curMood
{
    fixMood and writeMood;
    $mood[0];
}

sub addMood
{
    my ($add, $id) = @_;
    fixMood and writeMood;
    my $oldMood = $mood[0];
    $mood[0] += $add;
    $mood[1] = time2date;
    $mood[2] = $id;
    fixMood;
    writeMood;
    wantarray ? ($mood[0], $mood[0]-$oldMood) : $mood[0];
}

1;
