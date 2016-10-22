package Scripts::Windy::Addons::Sign;

use 5.012;
use Exporter;
use Scripts::scriptFunctions;
use Scripts::Windy::Util;
our @ISA = qw/Exporter/;
our @EXPORT = qw/sign loadSign/;

my $conf = $windyConf;
my ($maxSense, $minSense);
sub loadConf
{
    $maxSense = $conf->get('sign', 'maxSense') // 5;
    $minSense = $conf->get('sign', 'minSense') // 0;
}
loadConf;
my $signFile = $configDir.'windy-conf/sign';
our %sign = ();
sub loadSign
{
    if (open my $f, '<', $signFile) {
        while (<$f>) {
            chomp;
            $sign{$1} = $2 if /^(.+)\t(.+)$/;
        }
    }
}

sub sign
{
    my ($self, $windy, $msg) = @_;
    my $thisTime = time2date;
    my $id = uid(msgSender($windy, $msg));
    if ($sign{$id} ne $thisTime) {
        $windy->logger("${id}签到了。");
        $sign{$id} = $thisTime;
        if (open my $f, '>>', $signFile) {
            binmode $f, ':unix';
            say $f $id."\t".$sign{$id};
        }
        randFromTo($minSense, $maxSense);
    } else {
        $windy->logger("${id}已经签到过了。");
        undef;
    }
}
1;
