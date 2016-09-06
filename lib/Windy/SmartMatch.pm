package Scripts::Windy::SmartMatch;

use 5.012;
use Exporter;
use Scripts::scriptFunctions;
use Scripts::Windy::Util;
use Scripts::Windy::Expr;
#$Scripts::scriptFunctions::debug = 1;
use List::Util qw/all/;
no warnings 'experimental';
use Data::Dumper;
use utf8;
use Encode qw/_utf8_on _utf8_off/;
use Regexp::Common qw/balanced/;
our @ISA = qw/Exporter/;
our @EXPORT = qw/sm sr/;
our @EXPORT_OK = qw//;

# d1 d2: command
# d3 d4: plain text
# d5 d6: regexp shortcut
#our ($d1, $d2, $d3, $d4, $d5, $d6);
#our $aliases = [];
#our $replacements = {};
=comment
if (open my $f, '<', $configDir."windy-conf/smartmatch.pm") {
    eval join '', <$f>;
    die $@ if $@;
} else {
    debug 'cannot open';
}
=cut
sub new
{
    my $class = shift;
    my $self = {@_};
    $self->{d1} //= '【';
    $self->{d2} //= '】';
    $self->{d3} //= '{';
    $self->{d4} //= '}';
    $self->{d5} //= '<';
    $self->{d6} //= '>';
    $self->{d7} //= '〔';
    $self->{d8} //= '〕';
    $self->{aliases} //= [];
    $self->{replacements} //= {};
    $self->{re_rep} = $RE{balanced}{-begin => $self->{d5}}{-end => $self->{d6}};
    $self->{re_arg} = $RE{balanced}{-begin => $self->{d7}}{-end => $self->{d8}};
    bless $self, $class;
}

sub replace
{
    my ($self, $symbol, @rest) = @_;
    #my ($keep, $symbol, $flags) = $symbol =~ /(=?)(.+?)([\*\?\+]*)/;
    my $this = $self->{replacements}{$symbol};
    my $ret;
    if (ref $this eq 'CODE') { # 生成器
        $ret = $this->(@rest);
    } elsif (ref $this eq 'ARRAY') { # array, 用或者连接。
        $ret = '(?:'. (join '|', @$this) . ')';
    } elsif ($this) { # scalar，带入。
        $ret = $this;
    } else {
        $ret = $symbol; # 为空返回其名
    }
    $ret;
}

#### aaa<bbbbbb〔cccccc<ffff>ddd,eeeggg,llllll<hhhhhh〔- - -〕>〕>
sub parseReplacements
{
    my ($self, $text) = @_;
    my $text = substr $text, 1, (length $text) - 2; # 去除头尾<>
    my @args;
    if ($text =~ s/$self->{re_arg}//) {
        @args = map { $self->parseText($_) } split ',', substr $1, 1, (length $1) - 2;
    }
    $self->parseText($self->replace($text, @args));
}

sub parseText
{
    my ($self, $text) = @_;
    ### 只能嵌两层。不知道为什么。不知道会有什么问题。
    $text =~ s/$self->{re_rep}/$self->parseReplacements($1)/ger;
}

sub parse
{
    my $self = shift;
    my $text = shift;
    #logger "词库添加 ".$text;
    _utf8_on($text);
    my @s = (); #/$d1(.*?)$d2(.*?)(?=$d2)/g;
    my $d1 = quotemeta $self->{d1};
    my $d2 = quotemeta $self->{d2};
    my $d5 = quotemeta $self->{d5};
    my $d6 = quotemeta $self->{d6};
    my $d7 = quotemeta $self->{d7};
    my $d8 = quotemeta $self->{d8};
    my $replacements = $self->{replacements};
    while ($text) {
        debug "text = `$text`";
        if ($text =~ s/^$d1(.*?)$d2//s) {
            debug "command `$1`";
            push @s, $self->parseExpr($1);
        } elsif ($text =~ s/^(?<!$d1)(.+?)(?=$d1|$)//s) {
            #($text =~ s///) {
            my $ret = $1;
            $ret =~ s/$self->{re_rep}/$self->parseReplacements($1)/ge;
            debug "match `$ret`";
            #$ret =~ s<$d5([^$d6$d7]+)(?:$d7([^$d8]+)$d8)?$d6>[$self->replace($1, $2)]eg;
            debug "the pattern is now: $ret";
            push @s, $ret;
        } else {
            die "not match";
        }
        #debug chomp ($_ = <>);
    }
    wantarray ? @s : [@s];
}

sub parseExpr
{
    my $self = shift;
    my $t = shift;
    $t =~ s/^\s+//;
    $t =~ s/\s+$//;
    my $found = 0;
    my $expr;
    debug "text is ".$t;
    my $d3 = quotemeta $self->{d3};
    my $d4 = quotemeta $self->{d4};
    return $1 if $t =~ /^$d3([^$d4]+)$d4$/; # Plain Text
    for my $a (@{$self->{aliases}}) {
        debug "sm #45:" .Dumper $a;
        if (my @matches = $t =~ $a->[0]) {
            debug "sm #47:".Dumper @matches;
            $expr = Scripts::Windy::Expr->new ($a->[1], map { $_ = $self->parseExpr($_) } @matches);
            $found = 1;
            last;
        }
    }
    $expr = $t if not $found; # Bareword
    $expr;
}

sub runExpr
{
    my $self = shift;
    my $windy = shift;
    my $msg = shift;
    my $expr = shift;
    debug "running expr:" . Dumper($expr);
    ref $expr eq 'Scripts::Windy::Expr' or return $expr;
    my @args = @{$expr->{args}};
    if (not $expr->quoted) {
        for (@args) {
            debug "Arg: ". Dumper($_);
            $_ = $self->runExpr($windy, $msg, $_, @_);
            debug "Changed into:".Dumper($_);
        }
    }
    ($expr->{run})->($self, $windy, $msg, @args, @_);
}

sub smartmatch
{
    my $self = shift;
    my $text = shift;
    my @pattern = $self->parse($text);
    #say "pattern:",Dumper(@pattern);
    my $textMatch = join '', grep { not ref $_ } @pattern;
    $textMatch = qr/$textMatch/; ### 加上这句之后反应速率提高数百倍
    my @pattern = grep { ref $_ } @pattern;
    sub { # $m->smartmatch("")->($windy, $msg);
        my $windy = shift;
        my $msg = shift;
        my $t = msgText ($windy, $msg);
        #say term  "text: `", $t,"`";
        #say term "textmatch: `", $textMatch,"`";
        _utf8_on($t);
        #say 'cond:'. Dumper @pattern;
        debug 'match pattern:'.$textMatch;
        my @ret = $t =~ $textMatch; ###这实在是太奇怪了。
        #@ret and say term "Matched this: ". $textMatch or say term "Didnt match.";
        # 先执行regex，然后判定是否符合条件。
        if (@ret and (@pattern ? all { $self->runExpr($windy, $msg, $_, @_); } @pattern : 1)) {
            @ret;
        } else {
            ();
        }
    }
}

sub smartret
{
    my $self = shift;
    my $text = shift;
    my @pattern = $self->parse($text);
    sub {
        my $windy = shift;
        my $msg = shift;
        #my $t = msgText ($windy, $msg);
        debug Dumper @pattern;
        # Evaluate if code
        # Plain text leave it as-is
        my $ret = join '', map { $self->runExpr($windy, $msg, $_, @_) } @pattern;
        _utf8_off($ret);
        $ret;
    }
}


1;
=comment
package Scripts::Windy::MatchObject;

use 5.012;
use Scripts::Windy::Expr;

sub new
{
    my $class = shift;
    my $self = [@_];
    bless $self, $class;
}

sub newFromString
{

}
=cut
1;
