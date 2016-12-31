package Scripts::Windy::Util::Base;

use 5.012;
use Exporter;
use Scripts::scriptFunctions;
use utf8;

our @ISA = qw/Exporter/;
our @EXPORT = qw/$nextMessage $windyConf $mainConf msgTAEnv/;
our $nextMessage = "\n\n";
our $mainConf = "windy-conf/main.conf";
our $windyConf = conf $mainConf;
sub msgTAEnv : lvalue
{
    my ($windy, $msg) = @_;
    $msg->{__ta_env};
}
1;
