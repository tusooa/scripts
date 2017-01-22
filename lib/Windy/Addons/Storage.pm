package Scripts::Windy::Addons::Storage;
use Exporter;
use Scripts::Base;
use Scripts::Windy::Util;
use Scripts::TextAlias::Parser;

our @ISA = qw/Exporter/;
our @EXPORT = qw/storage/;

our $storage;

sub storage
{
    $storage // __PACKAGE__->new;
}

sub new
{
    my $class = shift;
    my $self = { file => $configDir.'windy-conf/storage.db', data => {}, };
    bless $self, $class;
}

sub load
{
    my $self = shift;
    if (open my $f, '<', $self->{file}) {
        while (<$f>) {
            chomp;
            $self->setOrig(split /\t/);
        }
        close $f;
    }
}

sub setOrig
{
    my ($self, $section, $id, @content) = @_;
    $section or return;
    if (not $self->{data}{$section}) {
        $self->{data}{$section} = {};
    }
    $self->{data}{$section}{$id} = [@content];
}

sub set
{
    my ($self, @rest) = @_;
    $self->setOrig($self->runHooks('storage-set-hook', @rest));
}

sub store
{
    my ($self, @rest) = @_;
    if ($self->set(@rest)) {
        if (open my $f, '>>', $self->{file}) {
            binmode $f, ':unix';
            say $f join "\t", $self->getOrig(@rest);
            close $f;
        }
    }
}

sub getOrig
{
    my ($self, $section, $id) = @_;
    $self->{data}{$section} or return;
    my $ret = $self->{data}{$section}{$id};
    $ret or return;
    wantarray ? @$ret : $ret;
}

sub get
{
    my ($self, $section, $id) = @_;
    my @ret = $self->runHooks('storage-get-hook', $section, $id, $self->getOrig($section, $id));
    wantarray ? @ret : $ret[2];
}

sub getP
{
    my ($self, $section, $id) = @_;
    $self->get($section, $id.'P');
}

sub getG
{
    my ($self, $section, $id) = @_;
    $self->get($section, $id.'G');
}

sub getU # U for universal == global
{
    my ($self, $section) = @_;
    $self->get($section, 'U');
}

sub getPByMsg
{
    my ($self, $windy, $msg, $section) = @_;
    $self->getP($section, uid(msgSender($windy, $msg)));
}

sub getGByMsg
{
    my ($self, $windy, $msg, $section) = @_;
    $self->getG($section, msgGroupId($windy, $msg));
}

=comment example
ta->parse(<<'EOF')->evalOutOfBox(topEnv);
``
set(run-hooks lambda(
arguments(hooks array)
map(lambda(arguments(hook) set(array symbol-call(hook array))) hooks)
array
))
set(storage-set-hook:FORBIDDEN lambda(
arguments(section id orig &rest(arr))
if(eq(orig {baz}) set(orig {XXX}))
list(section id orig |(arr))
))
set(storage-get-hook:ALL-DEFAULT lambda(
arguments(section id orig &rest(arr))
if(orig # set(orig {DEFAULT}))
list(section id orig |(arr))
))
set(storage-set-hook list(qs(storage-set-hook:FORBIDDEN)))
set(storage-get-hook list(qs(storage-get-hook:ALL-DEFAULT)))
EOF
=cut
sub runHooks
{
    my ($self, $name, @args) = @_;
    my $hookList = topScope->var($name);
    UNIVERSAL::isa($hookList, 'ARRAY') or return @args;
    for (@$hookList) {
        @args = @{ ta->newExpr(varname => 'symbol-call', args => [$_, @args])->value(topEnv) };
    }
    @args;
}

$storage = __PACKAGE__->new;
1;
