package Scripts::Base;
use Scripts::scriptFunctions ();
use feature ();
use utf8;
use warnings;
use Encode qw/_utf8_on _utf8_off/;
use strict;
sub import
{
    my $pack = (caller 0)[0];
    'feature'->import(':5.12');
    'utf8'->import;
    'strict'->import;
    'warnings'->unimport('experimental');
    no strict 'refs';
    *{$pack.'::_utf8_on'} = \&_utf8_on;
    *{$pack.'::_utf8_off'} = \&_utf8_off;
    Scripts::scriptFunctions->export_to_level(1, @_);
}
1;
