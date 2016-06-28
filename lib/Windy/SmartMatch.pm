package Scripts::Windy::SmartMatch;

use 5.012;
use Exporter;
use Scripts::scriptFunctions;
use Scripts::Windy::Util;
$Scripts::scriptFunctions::debug = 1;
use List::Util qw/all/;
no warnings 'experimental';
use Data::Dumper;
our @ISA = qw/Exporter/;
our @EXPORT = qw/sm sr/;
our @EXPORT_OK = qw//;

# d1 d2: command
# d3 d4: plain text
# d5 d6: regexp shortcut
my ($d1, $d2, $d3, $d4, $d5, $d6);
my $aliases = [];
my $replacements = {};
if (open my $f, '<', $configDir."windy-conf/smartmatch.pm") {
    eval join '', <$f>;
    die $@ if $@;
} else {
    debug 'cannot open';
}

sub smartParse
{
    my $text = shift;
    my @s = (); #/$d1(.*?)$d2(.*?)(?=$d2)/g;
    my @pattern;
    while ($text) {
        debug "text = `$text`";
        if ($text =~ s/^$d1(.*?)$d2//) {
            debug "command `$1`";
            push @s, [$1];
        } elsif ($text =~ s/^(?<!$d1)(.+?)(?=$d1|$)//) {
            debug "match `$1`";
            push @s, $1;
        } else {
            die "not match";
        }
        #debug chomp ($_ = <>);
    }
    for (@s) {
        if (ref $_) {
            my $t = $_->[0];
            my $found = 0;
Alias:      for my $a (@$aliases) {
                debug "sm #45:" .Dumper $a;
                if (my @matches = $t =~ $a->[0]) {
                    debug "sm #47:".Dumper @matches;
                    push @pattern, [$a->[1], @matches];
                    $found = 1;
                    last Alias;
                }
            }
            push @pattern, [sub { $t }] if not $found; # Plain word(as a condition of match)
        } else {
            s/<(.+)?>/$replacements->{$1}/e;
            push @pattern, $_; # Plain word(as regexp)
        }
    }
    @pattern;
}
sub sm
{
    my $text = shift;
    my @pattern = smartParse $text;
    my $textMatch = join '', grep !ref $_, @pattern;
    my @pattern = grep ref $_, @pattern;
    sub {
        my $windy = shift;
        my $msg = shift;
        my $t = msgText ($windy, $msg);
        debug 'cond:'. Dumper @pattern;
        debug 'match pattern:'.$textMatch;
        # References could be changed,
        # Be aware when using them.
        if (@pattern ? all { debug 'sm #81'. Dumper ($_); my @arr = @$_; my $p = shift @arr; $p->($windy, $msg, @arr); } @pattern : 1) {
            debug 'i am returning a value:';
            return $t =~ $textMatch;
        }
        debug 'i am NOT returning a value';
        ();
    }
}

sub sr
{
    my $text = shift;
    my @pattern = smartParse $text;
    sub {
        my $windy = shift;
        my $msg = shift;
        my $t = msgText ($windy, $msg);
        debug Dumper @pattern;
        # Evaluate if code
        # Plain text leave it as-is
        join '', map { if (ref $_) { my @arr = @$_; my $p = shift @arr; $p->($windy, $msg, @arr); } else { $_ } } @pattern;
    }
}

sub expr
{
    sm $d1.shift.$d2;
}
1;
