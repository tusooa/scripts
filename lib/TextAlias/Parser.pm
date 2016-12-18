package Scripts::TextAlias::Parser;
use Scripts::Base;
use Scripts::TextAlias;
use Scripts::TextAlias::Scope qw/$argListVN/;
use Scripts::TextAlias::Expr qw/quoteExpr/;
use Scripts::TextAlias::SpecialVars;
use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/ta topEnv topScope/;

my $parser = Scripts::TextAlias->new;
my $topScope = $parser->newScope;
my $topEnv = $parser->newEnv($topScope);
sub ta { $parser; }
sub topEnv { $topEnv; }
sub topScope { $topScope; }
my %func;
$func{arguments} = quoteExpr sub {
    my $env = shift;
    my $ta = $env->ta;
    my $vars = shift;
    my @varname = map { $_->{varname} } @$vars;
    my @arg = @{ $env->scope->var($argListVN) };
    for (0..$#varname) {
        $env->scope->makeVar($varname[$_]);
        $env->scope->var($varname[$_], $ta->getValue($arg[$_], $env));
    }
};
$func{def} = quoteExpr sub {
    my ($env, $args) = shift;
    for (@$args) {
        $env->scope->makeVar($_->{varname});
    }
};
$func{set} = quoteExpr sub {
    my $env = shift;
    my $args = shift;
    my $ta = $env->ta;
    my @kv = @{$args};
    for (1..(@kv/2)) {
        my $value = $ta->getValue($kv[2*$_-1], $env);
        $env->scope->var($kv[2*$_-2]->{varname}, $value);
    }
};
$func{print} = sub {
    my ($env, $args) = @_;
    print @$args;
};
$func{'+'} = sub {
    my ($env, $args) = @_;
    my $sum;
    $sum += $_ for @$args;
    $sum;
};
$func{'-'} = sub {
    my ($env, $args) = @_;
    my @list = $args;
    my $result = shift @list;
    if (@list) {
        $result -= $_ for @list;
    } else {
        $result = - $result;
    }
    $result;
};
$func{'*'} = sub {
    my ($env, $args) = @_;
    my $result = 1;
    $result *= $_ for @$args;
    $result;
};
$func{'/'} = sub {
    my ($env, $args) = @_;
    my @list = @$args;
    my $result = shift @list;
    if (@list) {
        $result /= $_ for @list;
    }
    $result;
};
$func{'.'} = sub { # str concat
    my ($env, $args) = @_;
    my $str;
    $str .= $_ for @$args;
    $str;
};
$func{'lambda'} = quoteExpr sub {
    my ($env, $args) = @_;
    my @list = @$args;
    $env->ta->newLambda(@list);
};
$func{'q'} = quoteExpr sub { # quote
    my ($env, $args) = @_;
    my @list = @$args;
    $list[0];
};
$func{'#'} = quoteExpr sub {}; # do nothing
#list func
$func{'list'} = sub {
    my ($env, $args) = @_;
    $args;
};
$func{'xth'} = sub {
    my ($env, $args) = @_;
    my ($list, $num) = @$args;
    UNIVERSAL::isa($list, 'ARRAY') or return;
    $list->[$num];
};
$func{'push'} = sub {
    my ($env, $args) = @_;
    my ($list, @rest) = @$args;
    push @$list, @rest;
};
$func{'pop'} = sub {
    my ($env, $args) = @_;
    my ($list, @rest) = @$args;
    pop @$list, @rest;
};
$func{'shift'} = sub {
    my ($env, $args) = @_;
    my ($list, @rest) = @$args;
    shift @$list, @rest;
};
$func{'unshift'} = sub {
    my ($env, $args) = @_;
    my ($list, @rest) = @$args;
    unshift @$list, @rest;
};
#conditions
$func{'progn'} = sub {
    my ($env, $args) = @_;
    $args->[-1];
};
$func{'if'} = quoteExpr sub {
    my ($env, $args) = @_;
    my $ta = $env->ta;
    my ($cond, $true, @false) = @$args;
    if ($ta->valueTrue($ta->getValue($cond, $env))) {
        $ta->getValue($true, $env);
    } else {
        (map { $ta->getValue($_, $env) } @false)[-1];
    }
};
$func{'and'} = quoteExpr sub {
    my ($env, $args) = @_;
    my $ta = $env->ta;
    my $result;
    for (@$args) {
        if (not $ta->valueTrue($result = $ta->getValue($_, $env))) {
            last;
        }
    }
    $result;
};
$func{'or'} = quoteExpr sub {
    my ($env, $args) = @_;
    my $ta = $env->ta;
    my $result;
    for (@$args) {
        if ($ta->valueTrue($result = $ta->getValue($_, $env))) {
            last;
        }
    }
    $result;
};
$func{'not'} = sub {
    my ($env, $args) = @_;
    not $env->valueTrue($args->[0]);
};
# comparisons
$func{'>'} = sub {
    my ($env, $args) = @_;
    my @nums = @$args;
    my $ret = 1;
    for (0..$#nums-1) {
        if (not $nums[$_] > $nums[$_+1]) {
            $ret = 0;
            last;
        }
    }
    $ret;
};
$func{'='} = sub {
    my ($env, $args) = @_;
    my @nums = @$args;
    my $ret = 1;
    for (0..$#nums-1) {
        if (not $nums[$_] == $nums[$_+1]) {
            $ret = 0;
            last;
        }
    }
    $ret;
};
$func{'<'} = sub {
    my ($env, $args) = @_;
    my @nums = @$args;
    my $ret = 1;
    for (0..$#nums-1) {
        if (not $nums[$_] < $nums[$_+1]) {
            $ret = 0;
            last;
        }
    }
    $ret;
};
$func{'>='} = sub {
    my ($env, $args) = @_;
    my @nums = @$args;
    my $ret = 1;
    for (0..$#nums-1) {
        if (not $nums[$_] >= $nums[$_+1]) {
            $ret = 0;
            last;
        }
    }
    $ret;
};
$func{'<='} = sub {
    my ($env, $args) = @_;
    my @nums = @$args;
    my $ret = 1;
    for (0..$#nums-1) {
        if (not $nums[$_] <= $nums[$_+1]) {
            $ret = 0;
            last;
        }
    }
    $ret;
};
$func{'!='} = sub {
    my ($env, $args) = @_;
    my @nums = @$args;
    my $ret = 1;
    for (0..$#nums-1) {
        if (not $nums[$_] != $nums[$_+1]) {
            $ret = 0;
            last;
        }
    }
    $ret;
};
$func{'gt'} = sub {
    my ($env, $args) = @_;
    my @nums = @$args;
    my $ret = 1;
    for (0..$#nums-1) {
        if (not $nums[$_] gt $nums[$_+1]) {
            $ret = 0;
            last;
        }
    }
    $ret;
};
$func{'lt'} = sub {
    my ($env, $args) = @_;
    my @nums = @$args;
    my $ret = 1;
    for (0..$#nums-1) {
        if (not $nums[$_] lt $nums[$_+1]) {
            $ret = 0;
            last;
        }
    }
    $ret;
};
$func{'eq'} = sub {
    my ($env, $args) = @_;
    my @nums = @$args;
    my $ret = 1;
    for (0..$#nums-1) {
        if (not $nums[$_] eq $nums[$_+1]) {
            $ret = 0;
            last;
        }
    }
    $ret;
};
$func{'ge'} = sub {
    my ($env, $args) = @_;
    my @nums = @$args;
    my $ret = 1;
    for (0..$#nums-1) {
        if (not $nums[$_] ge $nums[$_+1]) {
            $ret = 0;
            last;
        }
    }
    $ret;
};
$func{'le'} = sub {
    my ($env, $args) = @_;
    my @nums = @$args;
    my $ret = 1;
    for (0..$#nums-1) {
        if (not $nums[$_] le $nums[$_+1]) {
            $ret = 0;
            last;
        }
    }
    $ret;
};
$func{'ne'} = sub {
    my ($env, $args) = @_;
    my @nums = @$args;
    my $ret = 1;
    for (0..$#nums-1) {
        if (not $nums[$_] ne $nums[$_+1]) {
            $ret = 0;
            last;
        }
    }
    $ret;
};

#loops
=comment
$func{'while'} = quoteExpr sub {
    my ($env, $args) = @_;
    my $ta = $env->ta;
    my ($cond, @list) = @$args;
    while ($ta->valueTrue($ta->getValue($cond)))
}
=cut
$func{'SUPER'} = quoteExpr sub {
    my ($env, $args) = @_;
    my $ta = $env->ta;
    my ($var) = @$args;
    my $parent = $env->scope->parent // $ta;
    $parent->var($var->{varname});
};
$func{'call'} = quoteExpr sub {
    my ($env, $args) = @_;
    my $ta = $env->ta;
    my ($var, @list) = @$args;
    my $expr = $ta->newExpr(expr => $ta->getValue($var, $env),
                            args => [map { $ta->getValue($_, $env) } @list]);
    $expr->value($env);
};
# regexp func
$func{'rx'} = sub {
    my ($env, $args) = @_;
    my ($regex, $modifiers) = @$args;
    if ($modifiers and $modifiers =~ /^[msixpadlun]$/) {
        qr/(^$modifiers:$regex)/;
    } else {
        qr/$regex/;
    }
};
$func{'m'} = sub {
    my ($env, $args) = @_;
    my ($regex, $string) = @$args;
    my @match = $string =~ /$regex/;
    $env->scope->var($matchVN, [@match]);
    @match;
};
$func{'s'} = sub {
    my ($env, $args) = @_;
    my ($regex, $replacement, $string) = @$args;
    # 喵喵喵?要怎么替换?
};
for (keys %func) {
    $parser->var($_, $func{$_});
}

1;
