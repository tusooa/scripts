package Scripts::Windy::Web::Model::GroupMember;
use Mojo::Base 'Scripts::Windy::Web::Model::User';
use Scripts::Base;

has [qw/card joinTime lastSpeakTime level point role/];

sub isAdminOrFounder
{
    my $self = shift;
    my $role = $self->role;
    $role eq 'admin' or $role eq 'founder';
}

1;
