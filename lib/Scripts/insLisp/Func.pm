package Scripts::insLisp::Func;

sub new
{
    my ($class, $func, $quoted) = @_;
    ref $func eq 'CODE' or die "func must be coderef";
    my $self = {
        func => $func,
        quoted => $quoted // 0,
    };
    bless $self, $class;
}

sub quoted
{
    my $self = shift;
    $self->{quoted};
}

sub call
{
    my ($self, $scope, $args) = @_;
    $self->{func}($scope, $args);
}

1;
