package Scripts::insLisp::Lambda;

use Scripts::Base;
use Scripts::insLisp::Types;
=head1 NAME

Scripts::insLisp::Lambda - lambda objects in insLisp
=cut
=head1 SYNPOSIS

    use Scripts::insLisp::Lambda;
    use Scripts::insLisp::Scope;
    my $lambda = Scripts::insLisp::Lambda->new(
        [[Scripts::insLisp::Symbol->new("arg")],
         [Scripts::insLisp::Symbol->new("say"),
          Scripts::insLisp::Symbol->new("arg")]],
        Scripts::insLisp::Scope->new,
    );
=cut
=head1 METHODS
=cut
=head2 LAMBDA = Scripts::insLisp::Lambda->new(EXPRS, SCOPE)

Creates a lambda with EXPRS, defined in SCOPE.
EXPRS is a list ref. Its first item is a list ref containing the names of arguments and rest items are the expressions to be execuated in the lambda.
=cut
sub new
{
    my ($class, $expr, $defScope) = @_;
    my @expr = @$expr;
    my $args = shift @expr;
    my $self = {
        args => parseArgs($args),
        exprs => [@expr],
        defScope => $defScope,
    };
    bless $self, $class;
}

sub parseArgs
{
    my $args = shift;
    die "Invalid form of ARGS\n" if not isArray($args);
    my ($opt, $rest);
    for (@$args) {
        die "Argument is not a symbol\n" if not isSymbol($_);
        my $name = $_->name;
        if ($rest) {
            die "Only one argument is allowed after &rest" if $rest > 1;
            ++$rest;
        }
        if ($name eq '&rest') {
            $rest = 1;
        } elsif ($name eq '&optional') {
            die "&optional not allowed after &rest" if $rest;
            $opt = 1;
        }
    }
    $args;
}

sub args
{
    my $self = shift;
    @{ $self->{args} };
}

sub exprs
{
    my $self = shift;
    @{ $self->{exprs} };
}

sub pairKV
{
    my $self = shift;
    my %kv;
    my $opt = 0;
    my $rest = 0;
    for ($self->args) {
        my $name = $_->name;
        if ($name eq '&optional') {
            $opt = 1;
            next;
        }
        if ($name eq '&rest') {
            $rest = 1;
            next;
        }
        if ($opt and ! @_) {
            $kv{$name} = undef;
        } elsif ($rest) {
            $kv{$name} = [@_];
            @_ = ();
        } else {
            @_ or die "Not enough arguments.\n";
            $kv{$name} = shift;
        }
    }
    if (@_) {
        die "Too many arguments.\n";
    }
    %kv;
}

sub defScope
{
    my $self = shift;
    $self->{defScope};
}
1;
