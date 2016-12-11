package Scripts::TextAlias::VarCall;
use utf8;
use 5.012;
use Scripts::scriptFunctions;
use Scripts::TextAlias::Scope;
use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/quoteExpr exprQuoted/;
debugOn;

sub new
{
    my ($class, $ta, $scope, $var, @args) = @_;
    $scope = Scripts::TextAlias::Scope->new($ta) if ref $scope ne 'Scripts::TextAlias::Scope';
    my $self = {
        parser => $ta,
        parent => $scope,
        var => $var, # name of var
        args => [@args],
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

sub value
{
    my $self = shift;
    my $ta = $self->ta;
    my $name = $self->{var};
    my $var = $self->parent->var($name);
    my $e = 0;
    my @args = ();
    if (exprQuoted($var)) {
        $e = 1;
        @args = @{$self->{args}};
    } elsif (ref $var eq 'CODE') {
        $e = 1;
        @args = map { $ta->getValue($_) } @{$expr->{args}};
    }
    if ($e) {
        $var->($expr, @args);
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

1;
