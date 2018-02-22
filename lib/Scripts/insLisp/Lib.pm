package Scripts::insLisp::Lib;
use Scripts::Base;
use Scripts::insLisp;
use Scripts::insLisp::Scope;
use Scripts::insLisp::Symbol;
use Scripts::insLisp::Parser;
use Scripts::insLisp::Eval;
use Scripts::insLisp::Func;
use Scripts::insLisp::Lambda;
use Scripts::insLisp::Types;
use List::Util qw/all/;
use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/ta topEnv topScope/;

my $parser = Scripts::insLisp::Parser->new;
my $topScope = Scripts::insLisp::Scope->new;
my $topEnv = $topScope;
our $matchVN = 'Match';
sub ta { $parser; }
sub il { $parser; }
sub topEnv { $topEnv; }
sub topScope { $topScope; }
sub sym { Scripts::insLisp::Symbol->new(shift); }
sub t { sym('t') }
sub throw
{
    my ($name, $detail) = @_;
    if (isSymbol($name)) {
        $name = $name->name;
    }
    die "Error: $name, $detail\n";
}
my %func;

sub quoteExpr
{
    my $func = shift;
    Scripts::insLisp::Func->new($func, 1);
}

$func{def} = quoteExpr sub {
    my ($env, $args) = @_;
    for (@$args) {
        isSymbol($_) or throw 'wrong-type-argument',
            'def: The arguments must all be symbols';
        throw 'redefine-error',
            'variable '.$_->name.' redefined'
            if $env->hasVarInScope($_->name);
        $env->makeVar($_->name);
        $env->var($_->name, []);
    }
    [];
};
$func{define} = quoteExpr sub {
    my ($env, $args) = @_;
    if (@$args > 2 or @$args < 1) {
        throw 'wrong-number-arguments',
            'define: The number of arguments must be 1 or 2';
    }
    my ($var, $val) = @$args;
    if (@$args == 1) {
        $val = [];
    } else {
        $val = getValue($val, $env);
    }
    my $name = $var->name;
    throw 'redefine-error',
        "variable $name redefined"
        if $env->hasVarInScope($name);
    $env->makeVar($name);
    $env->var($name, $val);
    $val;
};

$func{set} = sub {
    my ($env, $args) = @_;
    my @kv = @$args;
    if (@kv % 2 != 0) {
        throw 'wrong-number-arguments',
            'set: The number of arguments must be even, but got '
            . scalar @kv;
    }
    my $value;
    for (1..(@kv/2)) {
        my ($var, $val) = @kv[2*$_ - 2, 2*$_ - 1];
        isSymbol($var) or
            throw 'wrong-type-argument',
            'setq: The variable to be assigned to must be a symbol';
        $value = $val;
        $env->var($var->name, $val);
    }
    # return the last value
    $value;
};

$func{setq} = quoteExpr sub {
    my $env = shift;
    my $args = shift;
    my @kv = @{$args};
    if (@kv % 2 != 0) {
        throw 'wrong-number-arguments',
            'setq: The number of arguments must be even, but got '
            . scalar @kv;
    }
    my $value;
    for (1..(@kv/2)) {
        my ($var, $val) = @kv[2*$_ - 2, 2*$_ - 1];
        isSymbol($var) or
            throw 'wrong-type-argument',
            'setq: The variable to be assigned to must be a symbol';
        $value = getValue($val, $env);
        $env->var($var->name, $value);
    }
    # return the last value
    $value;
};

$func{print} = sub {
    my ($env, $args) = @_;
    print @$args;
};

$func{'say'} = sub {
    my ($env, $args) = @_;
    say @$args;
};

$func{'+'} = sub {
    my ($env, $args) = @_;
    my $sum;
    $sum += $_ for @$args;
    $sum;
};

$func{'-'} = sub {
    my ($env, $args) = @_;
    my @list = @$args;
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

$func{'**'} = sub {
    my ($env, $args) = @_;
    my $ret = 1;
    $ret = $_ ** $ret for reverse @$args;
    $ret;
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
$func{'concat'} = $func{'.'};

$func{'x'} = sub {
    my ($env, $args) = @_;
    my ($str, $times) = @$args;
    $str x $times;
};

$func{'int'} = sub {
    my ($env, $args) = @_;
    int($args->[0]);
};

$func{'lambda'} = quoteExpr sub {
    my ($env, $args) = @_;
    my @list = @$args;
    if (@list < 1) {
        throw 'wrong-number-arguments',
            'lambda: no arglist specified';
    }
    Scripts::insLisp::Lambda->new([@list], $env);
};

$func{'quote'} = quoteExpr sub {
    my ($env, $args) = @_;
    $args->[0];
};

$func{'#'} = quoteExpr sub {}; # do nothing
sub commentRemoval
{
    grep { not (isArray($_) and $_->[0] eq '#') } @_;
}
#list func
$func{'list'} = sub {
    my ($env, $args) = @_;
    $args;
};

$func{'join'} = sub {
    my ($env, $args) = @_;
    my ($c, @list) = @$args;
    join $c, @list;
};

$func{'pick'} = sub {
    my ($env, $args) = @_;
    my @list = @$args;
    $list[int rand @list];
};
$func{'nth'} = sub {
    my ($env, $args) = @_;
    my ($num, $list) = @$args;
    isArray($list) or throw 'wrong-type-argument',
        'nth: second argument must be list';
    $list->[$num];
};
$func{'xth'} = sub {
    my ($env, $args) = @_;
    my ($list, $num) = @$args;
    isArray($list) or throw 'wrong-type-argument',
        'xth: first argument must be list';
    $list->[$num];
};
$func{'list-at'} = $func{'xth'};

$func{'hash'} = sub {
    my ($env, $args) = @_;
    { @$args };
};

$func{'hash-at'} = sub {
    my ($env, $args) = @_;
    my ($hash, $k) = @$args;
    isHash($hash) or throw 'wrong-type-argument',
        'hash-at: first argument must be hash';
    $hash->{$k};
};
$func{'hash-keys'} = sub {
    my ($env, $args) = @_;
    my ($hash, $k) = @$args;
    isHash($hash) or throw 'wrong-type-argument',
        'hash-keys: first argument must be hash';
    keys %$hash;
};

$func{'hash-length'} = sub {
    my ($env, $args) = @_;
    my ($hash, $k) = @$args;
    isHash($hash) or throw 'wrong-type-argument',
        'hash-length: first argument must be hash';
    scalar keys %$hash;
};

$func{'push'} = sub {
    my ($env, $args) = @_;
    my ($list, @rest) = @$args;
    isArray($list) or throw 'wrong-type-argument',
        'push: first argument must be list';
    push @$list, @rest;
};

$func{'pop'} = sub {
    my ($env, $args) = @_;
    my ($list, @rest) = @$args;
    isArray($list) or throw 'wrong-type-argument',
        'pop: first argument must be list';
    pop @$list, @rest;
};
$func{'shift'} = sub {
    my ($env, $args) = @_;
    my ($list, @rest) = @$args;
    isArray($list) or throw 'wrong-type-argument',
        'shift: first argument must be list';
    shift @$list, @rest;
};
$func{'unshift'} = sub {
    my ($env, $args) = @_;
    my ($list, @rest) = @$args;
    isArray($list) or throw 'wrong-type-argument',
        'unshift: first argument must be list';
    unshift @$list, @rest;
};
$func{'check-add-to-list'} = quoteExpr sub {
    my ($env, $args) = @_;
    my ($list, @rest) = @$args;
    isArray($list) or throw 'wrong-type-argument',
        'check-add-to-list: first argument must be list';
    for my $item (@rest) {
        my $exists = eval { $item ~~ @$list };
        $exists = grep { $_ eq $item } @$list if $@;
        if (not $exists) {
            push @$list, $item;
        }
    }
};
$func{'map'} = sub {
    my ($env, $args) = @_;
    @$args == 2 or throw 'wrong-number-arguments',
        'map: must have 2 arguments';
    my ($func, $list) = @$args;
    isCallable($func) or throw 'wrong-type-argument',
        'map: first arg must be callable';
    isArray($list) or throw 'wrong-type-argument',
        'map: second arg must be list';
    [map { getValue([$func, $_], $env) } @$list];
};
$func{'maplast'} = sub {
    my ($env, $args) = @_;
    @$args == 2 or throw 'wrong-number-arguments',
        'maplast: must have 2 arguments';
    my ($func, $list) = @$args;
    isCallable($func) or throw 'wrong-type-argument',
        'maplast: first arg must be callable';
    isArray($list) or throw 'wrong-type-argument',
        'maplast: second arg must be list';
    (map { getValue([$func, $_], $env) } @$list)[-1];
};

#conditions
topScope->var('t', t);
topScope->var('nil', []);
$func{'progn'} = sub {
    my ($env, $args) = @_;
    $args->[-1];
};
$func{'if'} = quoteExpr sub {
    my ($env, $args) = @_;
    my ($cond, $true, @false) = @$args;
    if (my $c = valueTrue(getValue($cond, $env))) {
        getValue($true, $env);
    } else {
        (map { getValue($_, $env) } @false)[-1];
    }
};
$func{'and'} = quoteExpr sub {
    my ($env, $args) = @_;
    my $result;
    for (@$args) {
        if (not valueTrue($result = getValue($_, $env))) {
            last;
        }
    }
    $result;
};
$func{'or'} = quoteExpr sub {
    my ($env, $args) = @_;
    my $result;
    for (@$args) {
        if (valueTrue($result = getValue($_, $env))) {
            last;
        }
    }
    $result;
};
$func{'not'} = sub {
    my ($env, $args) = @_;
    @$args == 1 or throw 'wrong-number-arguments',
        'not: must have one argument';
    valueTrue($args->[0]) ? [] : t;
};
$func{'defined'} = sub {
    my ($env, $args) = @_;
    @$args == 1 or throw 'wrong-number-arguments',
        'defined: must have one argument';
    defined($args->[0]) ? t : [];
};
# comparisons
$func{'>'} = sub {
    my ($env, $args) = @_;
    my @nums = @$args;
    my $ret = t;
    for (0..$#nums-1) {
        if (not $nums[$_] > $nums[$_+1]) {
            $ret = [];
            last;
        }
    }
    $ret;
};
$func{'='} = sub {
    my ($env, $args) = @_;
    my @nums = @$args;
    my $ret = t;
    for (0..$#nums-1) {
        if (not $nums[$_] == $nums[$_+1]) {
            $ret = [];
            last;
        }
    }
    $ret;
};
$func{'<'} = sub {
    my ($env, $args) = @_;
    my @nums = @$args;
    my $ret = t;
    for (0..$#nums-1) {
        if (not $nums[$_] < $nums[$_+1]) {
            $ret = [];
            last;
        }
    }
    $ret;
};
$func{'>='} = sub {
    my ($env, $args) = @_;
    my @nums = @$args;
    my $ret = t;
    for (0..$#nums-1) {
        if (not $nums[$_] >= $nums[$_+1]) {
            $ret = [];
            last;
        }
    }
    $ret;
};
$func{'<='} = sub {
    my ($env, $args) = @_;
    my @nums = @$args;
    my $ret = t;
    for (0..$#nums-1) {
        if (not $nums[$_] <= $nums[$_+1]) {
            $ret = [];
            last;
        }
    }
    $ret;
};
$func{'!='} = sub {
    my ($env, $args) = @_;
    my @nums = @$args;
    my $ret = t;
    for (0..$#nums-1) {
        if (not $nums[$_] != $nums[$_+1]) {
            $ret = [];
            last;
        }
    }
    $ret;
};
$func{'gt'} = sub {
    my ($env, $args) = @_;
    my @nums = @$args;
    my $ret = t;
    for (0..$#nums-1) {
        if (not $nums[$_] gt $nums[$_+1]) {
            $ret = [];
            last;
        }
    }
    $ret;
};
$func{'lt'} = sub {
    my ($env, $args) = @_;
    my @nums = @$args;
    my $ret = t;
    for (0..$#nums-1) {
        if (not $nums[$_] lt $nums[$_+1]) {
            $ret = [];
            last;
        }
    }
    $ret;
};
$func{'eq'} = sub {
    my ($env, $args) = @_;
    my @nums = @$args;
    my $ret = t;
    for (0..$#nums-1) {
        if (not $nums[$_] eq $nums[$_+1]) {
            $ret = [];
            last;
        }
    }
    $ret;
};
$func{'ge'} = sub {
    my ($env, $args) = @_;
    my @nums = @$args;
    my $ret = t;
    for (0..$#nums-1) {
        if (not $nums[$_] ge $nums[$_+1]) {
            $ret = [];
            last;
        }
    }
    $ret;
};
$func{'le'} = sub {
    my ($env, $args) = @_;
    my @nums = @$args;
    my $ret = t;
    for (0..$#nums-1) {
        if (not $nums[$_] le $nums[$_+1]) {
            $ret = [];
            last;
        }
    }
    $ret;
};
$func{'ne'} = sub {
    my ($env, $args) = @_;
    my @nums = @$args;
    my $ret = t;
    for (0..$#nums-1) {
        if (not $nums[$_] ne $nums[$_+1]) {
            $ret = [];
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
$func{'OUTER'} = sub {
    my ($env, $args) = @_;
    @$args == 1 or throw 'wrong-number-arguments',
        'OUTER: must have one argument';
    my ($var) = @$args;
    isSymbol($var) or throw 'wrong-type-argument',
        'OUTER: first argument must be symbol';
    my $parent = $env->parent;
    $parent or throw 'runtime-error',
        'OUTER: should not be called from the toplevel';
    $parent->var($var->name);
};
$func{'eval'} = quoteExpr sub {
    my ($env, $args) = @_;
    @$args == 1 or throw 'wrong-number-arguments',
        'eval: must have one argument';
    my ($expr) = @$args;
    getValue($expr, $env);
};
# string
$func{'length'} = sub {
    my ($env, $args) = @_;
    length $args->[0];
};
# regexp func
$func{'rx'} = sub {
    my ($env, $args) = @_;
    @$args <= 2 or throw 'wrong-number-arguments',
        'rx: must have one or two arguments';
    my ($regex, $modifiers) = @$args;
    if ($modifiers and $modifiers =~ /^[msixpadlun]+$/) {
        qr/(^$modifiers:$regex)/;
    } else {
        qr/$regex/;
    }
};

$func{'m'} = sub {
    my ($env, $args) = @_;
    my ($regex, $string) = @$args;
    my @match = $string =~ /$regex/;
    if (@match) {
        $env->makeVar($matchVN);
        $env->var($matchVN, [@match]);
    }
    @match;
};
$func{'subst'} = sub {
    my ($env, $args) = @_;
    my ($regex, $replacement, $string) = @$args;
    $string =~ s/$regex/$replacement/r;
};
$func{'subst-g'} = sub {
    my ($env, $args) = @_;
    my ($regex, $replacement, $string) = @$args;
    $string =~ s/$regex/$replacement/gr;
};
$func{'replace-on-string'} = sub {
    my ($env, $args) = @_;
    @$args >= 3 and @$args <= 4 or throw 'wrong-number-arguments',
        'replace-on-string: must have 3 or 4 arguments';
    my ($str, $regex, $to, $global) = @$args;
    if (not isCallable($to)) {
        $to = Scripts::insLisp::Lambda->new([[sym($matchVN)], $to], $env);
    }
    if ($global) {
        $str =~ s/$regex/
            getValue([$to, @{^CAPTURE}], $env);
            /ge;
    } else {
        $str =~ s/$regex/
            getValue([$to, @{^CAPTURE}], $env);
            /e;
    }
    $str;
};
$func{'dd'} = sub {
    my ($env, $args) = @_;
    map { dd($_) } @$args;
};
for (keys %func) {
    my $f = isFunc($func{$_})
        ? $func{$_}
        : Scripts::insLisp::Func->new($func{$_});
    topScope->var($_, $f);
}
ta->addHandler('list', \&commentRemoval);
topScope->var('Args', []);
topScope->var('Running', []);
topScope->var($matchVN, []);
1;
