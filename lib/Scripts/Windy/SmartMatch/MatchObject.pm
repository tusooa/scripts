package Scripts::Windy::SmartMatch::MatchObject;

use 5.012;
use Scripts::Windy::Util;
use Encode qw/_utf8_on _utf8_off/;
use Scripts::Base;
use List::Util qw/all/;
no warnings 'experimental';
use Scripts::TextAlias::Lambda;
use Scripts::TextAlias::Parser;
use Scripts::Windy::SmartMatch::TextAlias;
use Data::Dumper;
#debugOn;
sub new
{
    my $class = shift;
    my $match = shift;
    my $data = ref $_[0] eq 'HASH' ? shift : {};
    my $self = { match => $match, %$data };
    parseSM($self, @_);
    bless $self, $class;
}

sub pattern
{
    my ($self, $windy, $msg) = @_;
    if ($self->{type} eq 'sm') {
        $self->{pattern};
    } elsif ($self->{type} eq 'ta') {
        ta->getValue($self->{pattern}, msgTAEnv($windy, $msg));
    } else {
        ###
    }
}

sub parseSM
{
    my $self = shift;
    my $textMatch = join '', grep { not ref $_ } @_;
    $textMatch = eval { qr/$textMatch/ };
    return if $@;
    my @cond = grep { ref $_ } @_;
    $self->{cond} = [@cond];
    $self->{pattern} = $textMatch;
    $self->{parsed} = 1;
    $self;
}

sub parseTA
{
    my ($self, undef, $tree) = @_;
    debug "----> ta parsing";
    $tree or return;
    my @list = @$tree;
    if (@list == 1 and isLambda($list[0])) {
        # lambda( p({...}) c(=(sender-name {mewmewmew})) )
        my ($scope) = ta->getValue($list[0], topEnv);
        my $self->{pattern} = $scope->var($patternVN);
        my $self->{cond} = $scope->var($condVN);
    } else { # plain pattern
        my $scope = ta->newScope(topScope);
        my $env = ta->newEnv($scope);
        $scope->makeVar($condVN);
        $scope->var($condVN, []);
        debug Dumper([@list]);
        my @all = map { ta->getValue($_, $env);} @list;
        $self->{pattern} = join '', @all;
        $self->{cond} = $scope->var($condVN);
    }
    $self->{parsed} = 1;
    $self;
}

sub selfParse
{
    my $self = shift;
    if ($self->{type} eq 'sm') {
        $self->parseSM($self->{match}->parse($self->{raw}));
    } elsif ($self->{type} eq 'ta') {
        $self->parseTA(ta->parseCommand($self->{raw}));
    } else {
        ###
    }
}

sub fromString
{
    my $class = shift;
    my $match = shift;
    my $data = ref $_[0] eq 'HASH' ? shift : {};
    my $str = shift;
    my $self = { raw => $str, parsed => 0, match => $match, %$data, };
    unless ($self->{type}) {
        $self->{type} = isTALike($str) ? 'ta' : 'sm';
    }
    bless $self, $class;
}

sub match
{
    my $object = shift;
    my $windy = shift;
    my $msg = shift;
    my $t = msgText ($windy, $msg);
    my $textMatch = $object->pattern($windy, $msg);
    debug 'text match is '. $textMatch;
    _utf8_on($t);
    my @ret;
    given ($object->{style}) {
        when ('S') {
            my ($start, $end) = (msgPosStart($windy, $msg), msgPosEnd($windy, $msg));
            if (@ret = $t =~ $textMatch) {
                my $real_start = length $`;
                my $real_end = length $';
                if ($real_start > $start or $real_end > $end) {
                    @ret = ();
                }
            }
        }
        when ('s') {
            my ($start, $end) = (msgPosStart($windy, $msg), msgPosEnd($windy, $msg));
            $textMatch = qr/^.{0,$start}$textMatch.{0,$end}$/;
            @ret = $t =~ $textMatch;
        }
        default { @ret = $t =~ $textMatch; }
    }
    @ret;
}

sub run
{
    my $object = shift;
    my $self = $object->{match};
    if (not $object->{parsed}) {
        $object->selfParse;
    }
    my @pattern = @{$object->{cond}};
    my $windy = shift;
    my $msg = shift;
    my @ret = $object->match($windy, $msg);
    
    # 先执行regex，然后判定是否符合条件。
    if (@ret) {
        debug "the text matched";
        debug "ret is @ret";
        debug "conditions: ";
        debug Dumper(@pattern);
        my $r = 0;
        my $env = msgTAEnv($windy, $msg);
        $env->scope->makeVar($msgMatchVN);
        $env->scope->var($msgMatchVN, [@ret]);
        if ($object->{type} eq 'sm') {
            debug "type is sm";
            $r = @pattern ? (all { $self->runExpr($windy, $msg, $_, @ret); } @pattern) : 1;
            debug "\@pattern is ".scalar @pattern;
            debug "r is $r";
        } elsif ($object->{type} eq 'ta') {
            debug "type is ta";
            $r = @pattern ? (all { ta->valueTrue(ta->getValue($_, $env)) } @pattern) : 1;
        } else {
            debug "type is unknown";
        }
        $r ? @ret : ();
    } else {
        ();
    }
}
1;
