package Scripts::TimeDay;

use Exporter;
use List::Util qw/sum/;
use DateTime;
use 5.012;
our $VERSION = 0.1;
our @ISA = qw/Exporter/;
our @EXPORT_OK = qw/yDay mDay/;
our @EXPORT = qw/timeDiff/;

my @mdays = (0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

sub newFromString
{
    my ($class, $string) = @_;
    $class->new (map { int $_ } split /[^\d]+/, $string);
}

sub newFromRepublic
{
    shift->new (shift () - 1911, shift, shift);
}

sub newFromRepublicString
{
    my ($class, $string) = @_;
    my @date = map { int $_ } split /[^\d]+/, $string;
    $date[0] -= 1911;
    $class->new (@date);
}

sub new
{
    my $class = shift;
    my $self = \timeSecond (@_);
    bless $self, $class;
}

sub now
{
    my $class = shift;
    my @t = localtime;
    $class->new ($t[5]+1900, $t[4]+1, $t[3]);
}

sub timeSecond
{
    my $date = DateTime->new (
        year => shift,
        month => shift,
        day => shift);
    $date->epoch;
}

sub timeDiff
{
    my ($first, $second) = @_;
    return ($$second - $$first) / 60 / 60 / 24;
}

=end
sub leapP
{
    my $year = shift;
    $year % 4 == 0 && $year % 100 != 0 || $year % 400 == 0;
}

sub mDay
{
    my ($year, $month) = @_;
    $month == 2 ? ((leapP $year) ? 29 : 28) : $mdays[$month];
}

sub yDay
{
    my $year = shift;
    (leapP $year) ? 366 : 365;
}

sub timeDiff
{
    my ($first, $second) = @_;
    return -(timeDiff $second, $first)
        if $first->[0] > $second->[0]
        or $first->[1] > $second->[1]
        or $first->[2] > $second->[2];
    my $ydays = $first->[0] < $second->[0] ? (sum map { yDay $_ }
        ($first->[0]+1)..($second->[0]-1)) : -(yDay $first->[0]);
    my $mdays1 = (yDay $first->[0]) -
        ($first->[2] + sum map { mDay $first->[0], $_ }
         1..($first->[1]-1));
    my $mdays2 = $second->[2] + sum map { mDay $second->[0], $_ }
        1..($second->[1]-1);
    my $diff = $ydays + $mdays1 + $mdays2;
}
=cut
