package Scripts::Windy::Web::Model::User;

use Scripts::Base;
use Mojo::Base 'Scripts::Windy::Web::Model::Base';

has [qw/tencent/];

sub displayname
{
    my $self = shift;
    $self->name;
}

sub name
{
    my $self = shift;
    if (@_ == 0) {
        $self->{name} //= $self->client->GetNick($self->tencent);
    } else {
        $self->{name} = shift;
        $self;
    }
}

1;
