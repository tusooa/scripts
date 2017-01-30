package Scripts::TextAlias::Parser;
use Scripts::Base;
use Scripts::TextAlias;
use Scripts::TextAlias::Scope qw/$argListVN/;
use Scripts::TextAlias::Expr;
use Scripts::TextAlias::SpecialVars;
use Scripts::TextAlias::Symbol;
use List::Util qw/all/;
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

sub optionalP {
    my $var = shift;
    $var->{varname} eq '&opt';
}
sub restP { shift->{varname} eq '&rest' }
$func{arguments} = quoteExpr sub {
    my $env = shift;
    my $self = $env->{parser};
    my $ta = $env->ta;
    my @vars = @{$_[0]};
    #my @varname = map { $_->{varname} } @$vars;
    my @arg = @{ $env->scope->var($argListVN) };
    for (0..$#vars) {
        my $v = $vars[$_];
        if (not isVar($v)) {
            $self->error("arguments(): `$v' is not a variable.");
            return;
        } elsif (optionalP($v)) {
            my @rest = @vars[($_+1) .. $#vars];
            if (@rest and not all { optionalP $v; } @rest) {
                $self->error("arguments(): optional var followed by compulsary var.");
                return;
            }
            my @a = @{$v->{args}};
            if (not defined $a[0]) {
                $self->error("arguments(): what is the varname?");
                return;
            }
            my $name = $a[0]->{varname};
            $env->scope->makeVar($name);
            my $value = @arg ? shift @arg : $ta->getValue($a[1], $env);
            $env->scope->var($name, $value);
        } elsif (restP($v)) {
            my @rest = @vars[($_+1) .. $#vars];
            if (@rest) {
                $self->error("arguments(): &rest is not the last var");
                return;
            }
            my $var = $v->{args}->[0];
            if (not defined $var) {
                $self->error("arguments(): what is the varname?");
                return;
            }
            my $name = $var->{varname};
            $env->scope->makeVar($name);
            $env->scope->var($name, [@arg]);
        } else {
            my $name = $v->{varname};
            $env->scope->makeVar($name);
            $env->scope->var($name, shift @arg);
        }
    }
};
$func{def} = quoteExpr sub {
    my ($env, $args) = @_;
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
        $env->var($kv[2*$_-2]->{varname}, $value);
    }
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
    $args->[0] ** $args->[1];
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
    $env->ta->newLambda(defscope => $env->scope, list => [@list]);
};
$func{'q'} = quoteExpr sub { # quote
    my ($env, $args) = @_;
    my @list = @$args;
    my $var = $list[0]->{varname};
    my @a = @{$list[0]->{args}};
    my $func = $env->var($var);
    my $ret = sub {
        my ($env, $args) = @_;
        ta->newExpr(expr => $func, args => [@a, @$args])->value($env);
    };
    exprQuoted($func) ? quoteExpr($ret) : $ret ;
};
$func{'qs'} = quoteExpr sub {
    my ($env, $args) = @_;
    my $ta = $env->ta;
    my ($var) = @$args;
    $ta->newSymbol($var->{varname});
};
$func{'symbol-call'} = quoteExpr sub {
    my ($env, $args) = @_;
    my $ta = $env->ta;
    my ($sym, @list) = @$args;
    $sym = $ta->getValue($sym, $env);
    isSymbol($sym) or return;
    my $func = $env->var($sym->{name});
    my $expr = $ta->newExpr(expr => $func,
                            args => [@list]);
    my $ret = $expr->value($env);
    $ret;
};
$func{'#'} = quoteExpr sub {}; # do nothing
sub commentRemoval
{
    my @args;
    for (@_) {
        unless (isVar($_) and $_->{varname} eq '#') {
            push @args, $_;
        }
    }
    @args;
}
#list func
$func{'list'} = sub {
    my ($env, $args) = @_;
    $args;
};
sub listLiteral
{
    my @args = @_;
    for (@args) {
        if (isVar($_) and $_->{varname} eq 'list'
            and all { not isVar($_) } @{$_->{args}}) { # are all literals
            $_ = [@{$_->{args}}];
        }
    }
    @args;
}
$func{'qw'} = sub {
    my ($env, $args) = @_;
    [map s/\\ / /gr, map { split /(?<!\\) / } @$args];
};
sub qwLiteral
{
    my @args = @_;
    for (@args) {
        if (isVar($_) and $_->{varname} eq 'qw'
            and all { not isVar($_) } @{$_->{args}}) { # are all literals
            my @arr = map s/\\ / /gr, map { split /(?<!\\) / } @{$_->{args}};
            $_ = [@arr];
        }
    }
    @args;
}
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
$func{'xth'} = sub {
    my ($env, $args) = @_;
    my ($list, $num) = @$args;
    UNIVERSAL::isa($list, 'ARRAY') or return;
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
    UNIVERSAL::isa($hash, 'HASH') or return;
    $hash->{$k};
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
$func{'check-add-to-list'} = quoteExpr sub {
    my ($env, $args) = @_;
    my $ta = $env->ta;
    my ($list, @rest) = map { $ta->getValue($_, $env) } @$args;
    if (not UNIVERSAL::isa($list, 'ARRAY')) {
        defined $list and return;
        isVar($args->[0]) or return;
        my $vn = $args->[0]->{varname};
        $list = [];
        $env->var($vn, $list);
    }
    for my $item (@rest) {
        my $exists = eval { $item ~~ @$list };
        $exists = grep { $_ eq $item } @$list if $@;
        if (not $exists) {
            push @$list, $item;
        }
    }
};
$func{'|'} = sub { # flatten
    my ($env, $args) = @_;
    my ($list) = @$args;
    UNIVERSAL::isa($list, 'ARRAY') or return $list;
    @$list;
};
sub flattenLiteral
{
    my @args = ();
    for (@_) {
        if (isVar($_) and $_->{varname} eq '|'
            and all { not isVar($_) } @{$_->{args}}) { # are all literals
            my @arr = map { @$_ } @{$_->{args}};
            push @args, @arr;
        } else {
            push @args, $_;
        }
    }
    @args;
}
$func{'map'} = sub {
    my ($env, $args) = @_;
    my ($func, $list) = @$args;
    [map { $env->ta->newExpr(expr => $func, args => [$_])->value($env) } @$list];
};
$func{'maplast'} = sub {
    my ($env, $args) = @_;
    my ($func, $list) = @$args;
    (map { $env->ta->newExpr(expr => $func, args => [$_])->value($env) } @$list)[-1];
};
# s for symbol.
$func{'maps'} = ta->parse(<<'EOF');
``arguments(func array)
map(lambda(arguments(item) symbol-call(func item)) array)
EOF
$func{'mapslast'} = ta->parse(<<'EOF');
``arguments(func array)
maplast(lambda(arguments(item)symbol-call(func item)) array)
EOF

#conditions
$func{'nil'} = sub { () };
$func{'progn'} = sub {
    my ($env, $args) = @_;
    $args->[-1];
};
$func{'if'} = quoteExpr sub {
    my ($env, $args) = @_;
    my $ta = $env->ta;
    my ($cond, $true, @false) = @$args;
    if (my $c = $ta->valueTrue($ta->getValue($cond, $env))) {
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
$func{'andthen'} = quoteExpr sub {
    my ($env, $args) = @_;
    my $ta = $env->ta;
    my $result;
    for (@$args) {
        if (not defined($result = $ta->getValue($_, $env))) {
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
$func{'orelse'} = quoteExpr sub {
    my ($env, $args) = @_;
    my $ta = $env->ta;
    my $result;
    for (@$args) {
        if (defined($result = $ta->getValue($_, $env))) {
            last;
        }
    }
    $result;
};
$func{'not'} = sub {
    my ($env, $args) = @_;
    not $env->valueTrue($args->[0]);
};
$func{'defined'} = sub {
    my ($env, $args) = @_;
    defined($args->[0]);
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
sub rxLiteral
{
    my @args = @_;
    for (@args) {
        if (isVar($_) and $_->{varname} eq 'rx'
            and all { not isVar($_) } @{$_->{args}}) { # are all literals
            my $regex = join '', @{$_->{args}};
            $_ = qr/$regex/;
        }
    }
    @args;
}
$func{'m'} = sub {
    my ($env, $args) = @_;
    my ($regex, $string) = @$args;
    my @match = $string =~ /$regex/;
    if (@match) {
        $env->scope->makeVar($matchVN);
        $env->scope->var($matchVN, [@match]);
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
    my ($str, $regex, $to, $global) = @$args;
    if (ref $regex ne 'Regexp') {
        $regex = qr/$regex/;
    }
    while ($str =~ /$regex/g) {
        my $start = $-[0];
        my $end = $+[0];
        my $regexLength = $end - $start;
        #say "START = $start END = $end RLEN = $regexLength";
        my $replacement = ta->getValue(ta->newExpr(expr => $to, args => [map { substr $str, $-[$_], $+[$_]-$-[$_] } 0..$#-]), $env);
        my $length = length $replacement;
        substr $str, $start, $regexLength, $replacement;
        my $newPos = $start + $length + ($regexLength ? 0 : 1);
        $newPos > length $str and last;
        pos($str) = $newPos;
        #say "LENGTH = $length POS = ". pos($str). "NEWPOS = $newPos";
        #print "STR = $str ";<STDIN>;
        $global or last;
    }
    $str;
};
$func{'dd'} = quoteExpr sub {
    my ($env, $args) = @_;
    map { $env->ta->dd($env->var($_)) } @$args;
};
for (keys %func) {
    $parser->var($_, $func{$_});
}
ta->addHandler('expr', \&commentRemoval);
ta->addHandler('expr', \&rxLiteral);
ta->addHandler('expr', \&listLiteral);
ta->addHandler('expr', \&qwLiteral);
ta->addHandler('expr', \&flattenLiteral);


1;
