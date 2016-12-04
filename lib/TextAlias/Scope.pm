package Scripts::TextAlias::Scope;
use utf8;
use 5.012;
use Scripts::scriptFunctions;
debugOn;

sub new
{
    my ($class, $ta, $var, $list, $parent) = @_;
    $var = {} if ref $var ne 'HASH';
    $list = [] if ref $list ne 'ARRAY';
    $parent = undef if ref $parent ne __PACKAGE__;
    my $self = {
        parser => $ta,
        var => $var,
        list => $list,
        parent => $parent,
    };
    bless $self, $class;
}

sub ta
{
    my $self = shift;
    $self->{parser};
}

sub parent
{
    my $self = shift;
    $self->{parent};
}

sub var
{
    my $self = shift;
    my ($var, $val) = @_;
    if (@_ == 2) {
        my $scope = $self->varScope($var) // $self;
        $scope->setVar($var, $val);
        $self;
    } else {
        $self->getVar($var) or $self->ta->var($var);
    }
}

sub setVar
{
    my ($self, $var, $val) = @_;
    $self->{vars}{$var} = $val;
}

sub getVar # no parser
{
    my $self = shift;
    if ($self->hasVarInScope($_[0])) {
        $self->{vars}{$_[0]};
    } else {
        my $p = $self->parent;
        if ($p) {
            $p->var($_[0]);
        } else {
            undef;
        }
    }
}

sub hasVarInScope
{
    my $self = shift;
    exists $self->{vars}{$_[0]};
}

sub varScope
{
    my $self = shift;
    my $var = shift;
    if ($self->hasVarInScope($var)) {
        $self;
    } elsif ($self->parent) {
        $self->parent->varScope($var);
    } else {
        undef;
    }
}

sub makeVar
{
    my $self = shift;
    $self->{vars}{$_} = undef for @_;
}

1;
