package Scripts::TextAlias;
use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw//;
use utf8;
use Scripts::scriptFunctions;
use 5.012;
use Data::Dumper;
use Scripts::TextAlias::Expr;
#debugOn;

my @delims = qw/command string escape paren/;  
sub new
{
    my $class = shift;
    my %args = @_;
    my $self = { delim =>
                 { command => [[qw/`` ''/]],
                   string => [[qw/{ }/]],
                   escape => [['\\']],
                   paren => [[qw/( )/]],
                 },
                     regex => {},
                     vars => [] };
    bless $self, $class;
    $self->setDelim($args{delim}) if ref $args{delim} eq 'HASH';
    $self->regenRegex;
    $self->addVars(@{$args{vars}}) if ref $args{vars} eq 'ARRAY';
    $self;
}

sub regenRegex
{
    my $self = shift;
    my %r = ();
    for my $type (keys %{$self->{delim}}) {
        $r{$type} = { pair => {}};
        for my $subt (qw/start end/) {
            my @delims = $self->delim($type, $subt);
            my $regex = 
                join '|', map quotemeta $_, grep $_, @delims;
            $r{$type}->{$subt} = qr/$regex/;
            for my $p (@delims) {
                my $regex = quotemeta $self->delim($type, $subt, $p);
                $r{$type}->{pair}{$p} = qr/$regex/ if $regex;;
            }
        }
    }
    $self->{regex} = {%r};
    $self;
}

sub delim
{
    my $self = shift;
    if (@_ == 2) {
        my ($name, $pos) = @_;
        my $num = $pos eq 'end' ? 1 : 0;
        map { $_->[$num] } @{$self->{delim}{$name}};
    } elsif (@_ == 3) {
        my ($name, $pos, $match) = @_;
        my ($m, $r) = $pos eq 'end' ? (1, 0) : (0, 1);
        my ($found) = grep { $_->[$m] eq $match } @{$self->{delim}{$name}};
        #say "m: $m, r:$r match: $match";
        #print "$name", map { $_->[0], $_->[1] } @{$self->{delim}{$name}};
        $found->[$r];
    }
}

sub setDelim
{
    my $self = shift;
    if (@_ == 1) {
        my $h = $_[0];
        if (ref $h eq 'HASH') {
            for (keys %$h) {
                $self->setDelim($_, $h->{$_});
            }
        }
    } elsif (@_ == 2) {
        if (ref $_[1] eq 'ARRAY') {
            $self->{delim}{$_[0]} = $_[1];
        }
    }
    $self;
}

sub addVars
{
    my $self = shift;
    for my $var (@_) {
        my ($name, $value) = @$var;
        $self->{vars}{$name} = $value;
    }
    $self;
}

sub var
{
    my $self = shift;
    if (@_ == 2) {
        $self->{vars}{$_[0]} = $_[1];
        $self;
    } else {
        $self->{vars}{$_[0]};
    }
}

sub parse
{
    my ($self, $text) = @_;
    Scripts::TextAlias::Expr->new($self, $text);
}

1;
__END__
``set(num ''one``)''
``set(num {one})''
``set(num 1)''
``set(new-num +(1 num))''
There's more than ``num'' way to do it.

----

toplevel
`- symbol:var: set --type quoted
  `- args:
     `- symbol:var: num
     |- literal: "one"
|- symbol:var: set --type quoted
  `- args:
     `- symbol:var: num
     |- string: "one"
|- symbol:var: set --type quoted
  `- args:
     `- symbol:var: num
     |- number: 1
|- symbol:var: set --type quoted
  `- args:
     `- symbol:var: new-num
     |- symbol:var: +
        `- args:
           `- number: 1
           |- symbol:var: num
|- literal: "There's more than "
|- symbol: num
|- literal: " way to do it."
