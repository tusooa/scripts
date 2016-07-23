package Scripts::Windy::Addons::Sign;

use 5.012;
use Exporter;
use Scripts::scriptFunctions;
use Scripts::Windy::Util;
our @ISA = qw/Exporter/;
our @EXPORT = qw/sign loadSign/;

my $conf = conf 'windy-conf/sign.conf';
my $maxSense = $conf->get('maxSense') // 5;
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
    $windy->logger("${id}签到了。");
    if ($sign{$id} ne $thisTime) {
        $sign{$id} = $thisTime;
        if (open my $f, '>>', $signFile) {
            binmode $f, ':unix';
            say $f $id."\t".$sign{$id};
        }
        (int rand $maxSense) + 1;
    } else {
        0;
    }
}
1;
