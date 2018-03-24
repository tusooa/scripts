package Scripts::Windy::Util;

use 5.012;
use Exporter;
use Scripts::Base;
use utf8;
use Encode qw/_utf8_on _utf8_off/;
use constant BACKEND => $ENV{WINDY_BACKEND} =~ /^(?:mojo|mpq)$/ ? $ENV{WINDY_BACKEND} : 'mojo';
use Scripts::Windy::Util::Base;
use if BACKEND eq 'mpq', 'Scripts::Windy::Util::MPQ';
use if BACKEND eq 'mojo', 'Scripts::Windy::Util::Mojo';

our @ISA = qw/Exporter/;
our @EXPORT = (@Scripts::Windy::Util::Base::EXPORT, 'BACKEND');
if (BACKEND eq 'mpq') {
    push @EXPORT, @Scripts::Windy::Util::MPQ::EXPORT;
} elsif (BACKEND eq 'mojo') {
    push @EXPORT, @Scripts::Windy::Util::Mojo::EXPORT;
} else {
    
}
our @EXPORT_OK = qw//;

1;
