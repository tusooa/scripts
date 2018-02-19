package Scripts::Windy::Web::Model::Group;

use Mojo::Base 'Scripts::Windy::Web::Model::Base';
use Scripts::Base;
use Scripts::Windy::Web::Util;

has [qw/name number ownerTencent myRelationship
     adminMax memberMax levelName/];
has members => sub { []; };

sub findMember
{
    my ($self, $attr, $val) = @_;
    findIn($self->members, $attr, $val);
}

1;
