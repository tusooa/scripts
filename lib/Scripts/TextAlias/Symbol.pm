package Scripts::TextAlias::Symbol;
use Scripts::Base;
use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/isSymbol/;

sub new
{
    my ($class, $ta, $name) = @_;
    my $self = { parser => $ta, name => $name };
    bless $self, $class;
    $ta->addSymbol($name, $self);
    $self;
}

sub ta
{
    shift->{parser};
}

sub name
{
    shift->{name};
}
sub isSymbol
{
    ref shift eq __PACKAGE__;
}

