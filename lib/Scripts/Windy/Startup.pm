package Scripts::Windy::Startup;
use Exporter;
use 5.012;
use Scripts::scriptFunctions;
use Scripts::Windy;
use Scripts::Windy::Util;
our @ISA =  qw/Exporter/;
our @EXPORT = qw/$uid $password $mainGroupId $windy $replyScan @reply/;

my $file = $accountDir.'windy';
our $uid;
our $password;
if (open my $w, '<', term $file) {
    chomp ($uid = <$w>);
    chomp ($password = <$w>);
    close $w;
} else {
    say term "打不开文件 $file: $!\n";
}

my $mainGroupFile = $configDir.'windy-conf/main-group';
our $mainGroupId = undef;
sub loadMainGroupId
{
    if (open my $f, '<', term $mainGroupFile) {
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
