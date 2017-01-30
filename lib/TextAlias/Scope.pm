package Scripts::TextAlias::Scope;
use Scripts::Base;
use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/isScope $argListVN/;
our $argListVN = 'ArgList';
#debugOn;

sub isScope
{
    ref shift eq __PACKAGE__;
}

sub new
{
    my ($class, $ta, $parent, $var) = @_;
    $var = {} if ref $var ne 'HASH';
    isScope($parent) or $parent = undef;
    my $self = {
        parser => $ta,
        vars => $var,
        parent => $parent,
        depth => $parent ? $parent->{depth} + 1 : 1,
    };
    if ($self->{parser}{maxdepth} > 0 and $self->{depth} > $self->{parser}{maxdepth}) {
        die "exceeding max depth.";
    }
    bless $self, $class;
}

sub clone
{
    my ($self) = @_;
    my $class = ref $self;
    my $new = {
        parser => $self->{parser},
        vars => { %{$self->{vars}} },
        parent => $self->{parent},
    };
    bless $new, $class;
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
        my $scope = $self->varScopeRW($var) // $self;
        $scope->setVar($var, $val);
        $self;
    } else {
        $self->varScope($var) ? $self->getVar($var) : $self->ta->var($var);
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

sub varScopeRW
{
    my $self = shift;
    my $var = shift;
    if ($self->hasVarInScope($var)) {
        if ($self->isRO) {
            undef;
        } else {
            $self;
        }
    } elsif ($self->parent) {
        $self->parent->varScopeRW($var);
    } else {
        undef;
    }
}

sub makeRO
{
    my $self = shift;
    $self->{readonly} = 1;
    $self;
}

sub makeRW
{
    my $self = shift;
    $self->{readonly} = 0;
    $self;
}

sub isRO
{
    my $self = shift;
    $self->{readonly};
}

sub makeVar
{
    my $self = shift;
    $self->{vars}{$_} = undef for @_;
}

1;
