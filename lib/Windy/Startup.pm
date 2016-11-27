package Scripts::Windy::Startup;
use Exporter;
use 5.012;
use Scripts::scriptFunctions;
use Scripts::Windy;
use Scripts::Windy::Util;
our @ISA =  qw/Exporter/;
our @EXPORT = qw/$uid $mainGroupId $windy $replyScan @reply/;

my $file = $accountDir.'windy';
our $uid;
if (open my $w, '<', $file) {
    chomp ($uid = <$w>);
    close $w;
} else {
    die term "打不开文件 $file: $!\n";
}

my $mainGroupFile = $configDir.'windy-conf/main-group';
our $mainGroupId = undef;
sub loadMainGroupId
{
    if (open my $f, '<', $mainGroupFile) {
        chomp($mainGroupId = <$f>);
        close $f;
    }
}
loadMainGroupId;

our $windy = Scripts::Windy->new(Admin => [], MainGroup => $mainGroupId);
our $replyScan = Scripts::Windy::Conf::smartmatch::sr($windyConf->get('initMsg', 'scancode'));
our @reply = map
{ Scripts::Windy::Conf::smartmatch::sr($windyConf->get('initMsg', 'normal', $_)) } $windyConf->childList('initMsg', 'normal');

1;
