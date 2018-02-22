package Scripts::Windy::Web::Model::Discuss;

use Mojo::Base 'Scripts::Windy::Web::Model::Base';
use Scripts::Base;
use Scripts::Windy::Web::Model::DiscussMember;
use Scripts::Windy::Web::Util;

has [qw/id client/];
has members => sub { []; };

sub name
{
    my $self = shift;
    # MPQ does not have discuss name for us
    $self->id;
}

sub findMember
{
    my ($self, $attr, $val) = @_;
    findIn($self->members, $attr, $val);
}

sub newMember
{
    my $self = shift;
    my @args = @_;
    if (@args == 1 and ref $args[0] eq 'HASH') {
        @args = %{$args[0]};
    }
    my $member = Scripts::Windy::Web::Model::DiscussMember->new
        (@args, discuss => $self, client => $self->client);
    push @{$self->members}, $member;
    $member;
}

sub send
{
    my ($self, $text) = @_;
    $self->client->sendMessage
        ('discuss-message',
         $self->id, # source
         '', # receiver
         $text,
        );
}

1;
