package Scripts::TextAlias::Lambda;
use Scripts::Base;

use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/isLambda $argListVN/;
our $argListVN = 'ArgList';

sub new
{
    my $class = shift;
    my %args = @_;
    my $ta = $args{parser};
    my @list = @{$args{list}};
    my $scope = $args{defscope};
    my $quoted = $args{quoted};
    my $self = { parser => $ta, list => [@list], defscope => $scope, quoted => $quoted };
    bless $self, $class;
}

sub ta
{
    shift->{parser};
}

sub valueWithScope
{
    my $self = shift;
    my $ta = $self->ta;
    my $env = shift;
    my $scope = $ta->newScope($env->scope);
    $scope->var($argListVN, [@_]);
    my $childEnv = $ta->newEnv($scope);
    $childEnv->{defscope} = $self->{defscope};
    my @ret = ($scope, (map { $ta->getValue($_, $childEnv) } @{$self->{list}})[-1]);
    @ret;
}

sub value
{
    my $self = shift;
    ($self->valueWithScope(@_))[-1];
}

sub isLambda
{
    my $self = shift;
    ref $self eq __PACKAGE__;
}
1;

