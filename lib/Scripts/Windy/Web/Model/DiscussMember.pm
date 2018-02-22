package Scripts::Windy::Web::Model::DiscussMember;

use Mojo::Base 'Scripts::Windy::Web::Model::User';
use Scripts::Base;

has [qw/joinTime lastSpeakTime level point role discuss/];

sub displayname
{
    my $self = shift;
    # same as Tencent policy:
    #   if the member is my friend, get their mark name (if possible)
    #     or get nick
    my $friend = $self->client->findFriend(tencent => $self->tencent);
    if ($friend) {
        $friend->name;
    } else {
        $self->name;
    }
}

sub send
{
    my ($self, $text) = shift;
    my $friend = $self->client->findFriend(tencent => $self->tencent);
    if ($friend) { # then we can send friend-message
        my $tencent = $friend->tencent;
        $self->client->sendMessage
            ('friend-message',
             $tencent, # source
             $tencent, # receiver
             $text,
            );
    } else {
        $self->client->sendMessage
            ('discuss-sess-message',
             $self->discuss->id, # source
             $self->tencent, # receiver
             $text,
            );
    }
}

1;
