package Scripts::insLisp::Scope;
use Scripts::Base;
=head1 METHODS
=cut
=head2 Scripts::insLisp::Scope->new([PARENT], [VARS], [RO])

Creates a scope in PARENT.

If PARENT is not specified, the scope will be a toplevel.
=cut
sub new
{
    my ($class, $parent, $vars, $ro) = @_;
    my $self = {
        parent => $parent,
        vars => $vars ? { %$vars } : {},
        ro => $ro // 0,
    };
    bless $self, $class;
}

sub scope
{
    shift;
}

sub isRO
{
    shift->{ro};
}

sub makeRO
{
    my $self = shift;
    $self->{ro} = 1;
    $self;
}

sub makeRW
{
    my $self = shift;
    $self->{ro} = 0;
    $self;
}

sub hasVarInScope
{
    my $self = shift;
    my $var = shift;
    exists $self->{vars}{$var};
}

sub varScope
{
    my ($self, $var) = @_;
    if ($self->hasVarInScope($var)) {
        $self;
    } elsif ($self->{parent}) {
        $self->{parent}->varScope($var);
    } else {
        undef;
    }
}

sub varScopeRW
{
    my ($self, $var) = @_;
    if ($self->hasVarInScope($var)) {
        if ($self->isRO) {
            undef;
        } else {
            $self;
        }
    } elsif ($self->{parent}) {
        $self->{parent}->varScopeRW($var);
    } else {
        undef;
    }
}

sub getVar
{
    my ($self, $var) = @_;
    $self->{vars}{$var};
}

sub setVar
{
    my ($self, $var, $val) = @_;
    $self->{vars}{$var} = $val;
}

sub makeVar
{
    my ($self, $var) = @_;
    $self->{vars}{$var} = undef;
}

sub var
{
    my $self = shift;
    my $var = shift;
    #if (isSymbol($var)) {
    #    $var = $var->name;
    #}
    if (@_ == 1) { # set
        my $val = shift;
        my $s = $self->varScopeRW($var) // $self;
        $s->setVar($var, $val);
        $self;
    } else { # get
        my $s = $self->varScope($var);
        if ($s) {
            $s->getVar($var);
        } else {
            die "Unable to find variable $var\n";
        }
    }
}

1;
