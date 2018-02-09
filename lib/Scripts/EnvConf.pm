package Scripts::EnvConf;

require Exporter;
use 5.012;

our @ISA = qw/Exporter/;
our @EXPORT_OK = qw//;
our @EXPORT = qw//;

sub new
{
    my ($class, $env) = @_;
    #my $this = {};
    my @vars = split /:/, $env;
    my $this = {map { split /=/,$_; } @vars};
    #use Data::Dumper;
    #print Dumper ($this);
    bless $this, $class;
}

1;
