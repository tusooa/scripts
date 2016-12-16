package Scripts::TextAlias::Env;
use Scripts::Base;
use Scripts::TextAlias::Scope qw/isScope/;
sub new
{
    my $class = shift;
    my ($ta, $scope) = @_;
    isScope($scope) or $scope = $ta->newScope;
    my $self = { parser => $ta, scope => $scope };
    bless $self, $class;
}

sub ta
{
    shift->{parser};
}

sub scope
{
    shift->{scope};
}

1;
