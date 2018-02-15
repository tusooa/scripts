package Scripts::insLisp::Symbol;

use Scripts::Base;

sub new
{
    my ($class, $name) = @_;
    my $self = { name => $name };
    bless $self, $class;
}

sub name
{
    my $self = shift;
    $self->{name};
}

1;
