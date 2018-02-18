=encoding utf8
=cut
=head1 NAME
    Scripts::Windy::Web::Model::Event

=cut
package Scripts::Windy::Web::Model::Event;

use Scripts::Base;
use Mojo::Base 'Mojo::EventEmitter';
use MIME::Base64;

has [qw/tencent type subtype source
     subject object msg rawmsg/];
=head1 METHODS
=cut
=head2 new
    $event = Scripts::Windy::Web::Model::Event->new(
        tencent => "", type => 0, subtype => 0, source => "",
        subject => "", object => "", msg => "", rawmsg => "",
    )

Creates an Event object from the hash.
=cut

1;
