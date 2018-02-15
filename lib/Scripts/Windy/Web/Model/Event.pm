package Scripts::Windy::Web::Model::Event;

use Scripts::Base;
use Mojo::Base 'Mojo::EventEmitter';
use MIME::Base64;

sub new {
    my ($class, $event) = @_;
    $event->{msg} = utf8 decode_base64($event->{msg});
    $event->{rawmsg} = utf8 decode_base64($event->{rawmsg});
    bless $event, $class;
}



1;
