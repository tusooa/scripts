package Scripts::Windy::Web::Model::EventQueue;

use Scripts::Base;
use Mojo::Base 'Mojo::EventEmitter';

sub new
{
    my $class = shift;
    my $self = {
        maxNum => 10,
        list => [],
    };
    bless $self, $class;
}

sub size
{
    my $self = shift;
    scalar @{$self->{list}};
}



1;
