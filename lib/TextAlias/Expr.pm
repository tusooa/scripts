package Scripts::TextAlias::Expr;
use Scripts::Base;
use Scripts::TextAlias::Lambda;
use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/quoteExpr exprQuoted/;
debugOn;

sub new
{
    my ($class, %data) = @_;
    $data{parser} or return;
    my $self = {
        parser => $data{parser},
        args => [ref $data{args} eq 'ARRAY' ? @{$data{args}} : ()],
    };
    if ($data{varname}) {
        $self->{varname} = $data{varname};
    } else {
        $self->{expr} = $data{expr};
    }
    bless $self, $class;
}

sub ta
{
    my $self = shift;
    $self->{parser};
}
sub getVar
{
    my ($self, $name, $env) = @_;
    my $scope = $env->scope;
    my $defScope = $env->{defscope};
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
sub value
{
    my $self = shift;
    my $env = shift;
    my $ta = $self->ta;
    my $name = $self->{varname};
    my $var = $name ? $env->var($name) : $self->{expr};
    if (exprIsFunc($var)) {
        my $args = [];
        if (exprQuoted($var)) {
            $args = [@{$self->{args}}];
        } else {
            $args = [map { $ta->getValue($_, $env) } @{$self->{args}}];
        }
        my @ret = $var->($env, $args);
        wantarray ? @ret : $ret[-1];
    } elsif (isLambda($var)) {
        $var->value($env, map { $ta->getValue($_, $env) } @{$self->{args}});
    } else {
        $var;
    }
}

sub quoteExpr
{
    my $expr = shift;
    return $expr if ref $expr ne 'CODE';
    bless $expr, 'Scripts::TextAlias::Quote';
}

sub exprQuoted
{
    my $expr = shift;
    ref $expr eq 'Scripts::TextAlias::Quote';
}

sub exprIsFunc
{
    my $expr = shift;
    exprQuoted($expr) or ref $expr eq 'CODE';
}
1;
