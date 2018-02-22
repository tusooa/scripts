package Scripts::Windy::Web::Model::Friend;

use Scripts::Base;
use Mojo::Base 'Scripts::Windy::Web::Model::User';

has [qw/category markname/];

sub displayname
{
    my $self = shift;
    # MPQ does not record nicks, only mark-names
    $self->markname // $self->name;
}

sub send
{
    my ($self, $text) = @_;
    $self->client->sendMessage
        ('friend-message',
         $self->tencent, # source
         $self->tencent, # receiver
         $text,
        );
}

1;
