package Scripts::Windy::Expr;
use 5.012;

sub new
{
    my $class = shift;
    my $self = {};
    $self->{run} = shift;
    $self->{args} = [@_];
    bless $self, $class;
}

sub run
{
    my $self = shift;
    ($self->{run})->(@_, @{$self->{args}});
}

sub quoted
{
    my $self = shift;
    ref $self->{run} eq 'Scripts::Windy::Quote';
}

1;
