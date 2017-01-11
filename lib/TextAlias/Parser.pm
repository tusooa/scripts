package Scripts::TextAlias::Parser;
use Scripts::Base;
use Scripts::TextAlias;
use Scripts::TextAlias::Scope qw/$argListVN/;
use Scripts::TextAlias::Expr;
use Scripts::TextAlias::SpecialVars;
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
            my $value = $ta->getValue($a[1], $env);
            $env->scope->makeVar($name);
            if (@arg) {
                $value = shift @arg;
            }
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
$func{say} = sub {
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
$func{'#'} = quoteExpr sub {}; # do nothing
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
$func{'list-at'} = sub {
    my ($env, $args) = @_;
    my ($list, $num) = @$args;
    UNIVERSAL::isa($list, 'ARRAY') or return;
    $list->[$num];    
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
$func{'|'} = sub { # flatten
    my ($env, $args) = @_;
    my ($list) = @$args;
    UNIVERSAL::isa($list, 'ARRAY') or return;
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
$func{'s'} = sub {
    my ($env, $args) = @_;
    my ($regex, $replacement, $string) = @$args;
    # 喵喵喵?要怎么替换?
};
$func{'dd'} = quoteExpr sub {
    my ($env, $args) = @_;
    map { $env->ta->dd($env->var($_)) } @$args;
};
for (keys %func) {
    $parser->var($_, $func{$_});
}
ta->addHandler('expr', \&rxLiteral);
ta->addHandler('expr', \&listLiteral);
ta->addHandler('expr', \&qwLiteral);
ta->addHandler('expr', \&flattenLiteral);

1;
