=encoding utf8
=cut
=head1 名称

Scripts::Base - 引用了一些基础库
=cut
=head1 用法

    use Scripts::Base;

=cut
=head1 概述

相当于执行了如下语句:

    use 5.012;
    use utf8;
    no warnings 'experimental';
    use Scripts::scriptFunctions;
    use Encode qw/_utf8_on _utf8_off/;

=cut
package Scripts::Base;
use feature ();
use utf8;
use warnings;
use Encode qw/_utf8_on _utf8_off/;
use strict;
use Scripts::scriptFunctions ();
sub import
{
    my $self = shift;
    my $pack = (caller 0)[0];
    'feature'->import(':5.12');
    'utf8'->import;
    'strict'->import;
    'warnings'->unimport('experimental');
    no strict 'refs';
    *{$pack.'::_utf8_on'} = \&_utf8_on;
    *{$pack.'::_utf8_off'} = \&_utf8_off;
    if (@_ && $_[0] eq '-minimal') {
        shift;
        Scripts::scriptFunctions->export_to_level(1, $self, @_);
    } else {
        require Scripts::Path;
        Scripts::Path->export_to_level(1, $self, @_);
        Scripts::scriptFunctions->export_to_level(1, $self, @_);
    }
}
1;
