package Scripts::Base;
use Scripts::scriptFunctions ();
use feature ();
use utf8;
use warnings;
use Encode ();
sub import
{
    my $class = shift;
    'feature'->import(':5.12');
    'utf8'->import;
    'warnings'->unimport('experimental');
    Encode->import('_utf8_on', '_utf8_off');
}
1;
