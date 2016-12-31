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

sub defscope
{
    shift->{defscope};
}

sub var
{
    my $self = shift;
    my ($name, $val) = @_;
    my $scope = $self->scope;
    my $defScope = $self->{defscope};
    if (@_ == 2) {
        if (not $defScope) {
            $scope->var($name, $val);
        } else {
            if ($scope->hasVarInScope) {
                $scope->var($name, $val);
            } elsif (my $s = $defScope->varScopeRW($name)) {
                $s->setVar($name, $val);
            } else {
                $scope->var($name, $val);
            }
        }
        $self;
    } else {
        if (not $defScope) {
            $scope->var($name);
        } else {
            if ($scope->hasVarInScope) {
                $scope->var($name);
            } elsif (my $ret = $defScope->var($name)) {
                $ret;
            } else {
                $scope->var($name);
            }
        }
    }
}

1;
