package Scripts::Windy::Addons::Mood;

use Exporter;
use 5.012;
use Scripts::scriptFunctions;
our @ISA = qw/Exporter/;
our @EXPORT = qw/loadMood addMood curMood/;

my $file = $configDir.'windy-conf/mood.db';
my @mood = ();
my $cfg = conf 'windy-conf/mood';
my $max = $cfg->get('max') // 100;
my $min = $cfg->get('min') // -100;
my $maxc = $cfg->get('max-change-after-midnight') // 40;
my $minc = $cfg->get('min-change-after-midnight') // -40;
my $posi = $cfg->get('posibility-reverse') // 0.0001; # 最高和最低心情的转化
sub fixMood
{
    my $today = time2date;
    my $changed = 0;
    if ($mood[1] ne $today) {
        $mood[0] += int(rand($maxc-$minc)+$minc);
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

# 蹇冩儏鍔犳垚
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
    $mood[0] += $add;
    $mood[1] = time2date;
    $mood[2] = $id;
    fixMood;
    writeMood;
    $mood[0];
}

1;
