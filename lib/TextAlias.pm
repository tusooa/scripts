package Scripts::TextAlias;
use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw//;
use Scripts::Base;
use Data::Dumper;
use Scripts::TextAlias::Expr;
use Scripts::TextAlias::Scope;
use Scripts::TextAlias::Env;
use Scripts::TextAlias::Lambda;
debugOn;

my @delims = qw/command string escape paren/;  
sub new
{
    my $class = shift;
    my %args = @_;
    my $self = { delim =>
                 { command => [[qw/`` ''/]],
                   string => [[qw/{ }/]],
                   escape => '\\',
                   paren => [[qw/( )/]],
                   ws => qr/[\s\n]+/,
                   wsornot => qr/[\s\n]*/,
                   purenum => qr/-?(?:\d+(?:\.\d*)?|\.\d+)/,
                   notspecial => qr/[^\s\n(){}`'\\]+/,
                 },
                     esc => {t => "\t", n => "\n", "\\" => "\\",},
                     regex => {},
                     vars => {} };
    bless $self, $class;
    $self->setDelim($args{delim}) if ref $args{delim} eq 'HASH';
    $self->regenRegex;
    $self->addVars(@{$args{vars}}) if ref $args{vars} eq 'ARRAY';
    $self;
}

sub newExpr
{
    my $self = shift;
    Scripts::TextAlias::Expr->new(parser => $self, @_);
}

sub newEnv
{
    my $self = shift;
    Scripts::TextAlias::Env->new($self, @_);
}

sub newScope
{
    my $self = shift;
    Scripts::TextAlias::Scope->new($self, @_);
}

sub newLambda
{
    my $self = shift;
    Scripts::TextAlias::Lambda->new($self, @_);
}

sub regenRegex
{
    my $self = shift;
    my %r = ();
    for my $type (keys %{$self->{delim}}) {
        if (ref $self->{delim}{$type} ne 'ARRAY') {
            my $s = $self->{delim}{$type};
            $r{$type} = ref $s eq 'Regexp' ? $s : qr/\Q$s\E/;
        } else {
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
    } elsif (@_ == 1) {
        $self->{delim}{+shift};
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

sub isVar
{
    ref shift eq 'Scripts::TextAlias::Expr';
}

sub getValue
{
    my $self = shift;
    my $expr = shift;
    my $env = shift;
    if (isVar($expr)) {
        $expr->value($env);
    } else {
        $expr;
    }
}

sub error
{
    my $self = shift;
    if (@_) {
        $self->{error} = join '', @_;
        $self;
    } else {
        $self->{error};
    }
}

sub parse
{
    my $self = shift;
    my $r = $self->{regex};
    my $text = shift;
    my $state = 'literal';
    my $tree = [];
    my $literalR = qr/^(.*?)($r->{command}{start}|$)/s;

    while ($text) {
        if ($text =~ s/$literalR//) {
            my ($l, $delim) = ($1, $2);
            if (length $l) {
                debug "literal: $l";
                push @$tree, $l;
            }
            if ($delim) {
                my $new;
                ($text, $new) = $self->parseCommand($text, $delim);
                if (not $new) {
                    $self->error("Died at $text");
                    return;
                }
                push @$tree, @$new;
            } else {
                $text = '';
            }
        } else {
            debug "mewmewmew?";
            last;
            # 喵喵喵？？
        }
    }
    $self->newLambda(@$tree);
}

sub parseCommand
{
    my ($self, $text, $delim, $depth, $paren) = @_;
    my $r = $self->{regex};
    my $endDelim = $r->{'command'}{'pair'}{$delim};
    my $endParen = $r->{'paren'}{'pair'}{$paren};
    my $indent = '  ' x $depth;
    my $state = 'command';
    my $tree = [];
    my $literalR = qr/^$r->{wsornot}$endDelim/s;
    my $numR = qr/^$r->{wsornot}($r->{purenum})/s;
    my $symbolR = qr/^($r->{notspecial})/s;
    my $parenR = qr/^$r->{wsornot}($r->{paren}{start})/s;
    my $parenEndR = qr/^$r->{wsornot}$endParen/s;
    my $stringR = qr/^$r->{wsornot}($r->{string}{start})/s;
    debug $indent."entering level $depth";
    while ($text) {
        if ($text =~ s/$literalR//) {
            debug $indent."returning to literal";
            return ($text, $tree);
        } elsif ($text =~ s/$numR//) {
            my $number = $1;
            debug $indent."number: $number";
            push @$tree, $number;
        } elsif ($text =~ s/$stringR//) {
            my $startD = $1;
            my $str;
            ($text, $str) = $self->parseStr($text, $startD);
            debug $indent. "string: $str";
            push @$tree, $str;
        } elsif ($text =~ s/$symbolR//) {
            my $symName = $1;
            debug $indent."symbol: $symName";
            my $args = [];
            if ($text =~ s/$parenR//) {
                my $thisParen = $1;
                ($text, $args) = $self->parseCommand($text, $delim, $depth + 1, $thisParen);
                debug $indent."--with args.";
            }
            my $expr = $self->newExpr(varname => $symName, args => $args);
            push @$tree, $expr;
        } elsif ($text =~ s/$parenEndR//) {
            return ($text) if ($depth <= 0);
            $depth -= 1;
            return ($text, $tree);
        } else {
            last;
        }
    }
    ($text, $tree);
}

sub parseStr
{
    my ($self, $text, $startD) = @_;
    my $r = $self->{regex};
    my $endD = $self->delim('string', 'start', $startD);
    my $notEndD = qr/[^$endD]/;
    my $startDelim = qr/\Q$startD\E/;
    my $endDelim = $r->{'string'}{'pair'}{$startD};
    debug $endDelim;
    my $esc = quotemeta $self->delim('escape');
    my $normalCharR = qr/^([^$startD$endD$esc]+)/s;
    my $escapedR = qr/^$esc(.)/s;
    my $endR = qr/^($endDelim)/s;
    my $startR = qr/^($startDelim)/s;
    my $str = '';
    my $depth = 0;
    while ($text) {
        if ($text =~ s/$normalCharR//) {
            $str .= $1;
            debug "normal: $1";
        } elsif ($text =~ s/$escapedR//) {
            my $escaped = $1;
            debug "escaped char: ".$escaped;
            $str .= $self->{esc}{$escaped} // $escaped;
        } elsif ($text =~ s/$endR//) {
            my $s = $1;
            debug "end delim: $s";
            if ($depth <= 0) {
                debug "string end. remaining: ". $text;
                last;
            }
            $str .= $s;
            $depth -= 1;
        } elsif ($text =~ s/$startR//) {
            my $s = $1;
            debug "start delim: $s";
            $str .= $s;
            $depth += 1;
        }
    }
    ($text, $str);
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


---
``set(max-in-two scope(
arguments(num1 num2)
if(>(num1 num2) num1 num2)))''
``max-in-two(4 5)''
``set(max max-in-two) #(''get 0``)
set(max P(max-in-two)) #(''get a scope``)
``set(max-num max-in-two(4 5))''
max(4 5)''
