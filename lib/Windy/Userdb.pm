package Scripts::Windy::Userdb;
use 5.012;
no warnings 'experimental';
use Scripts::scriptFunctions;
use Scripts::Windy::Util;
use Scripts::TextAlias::Parser;
use Scripts::Windy::SmartMatch::TextAlias;
use Data::Dumper;
use utf8;
#debugOn;

sub new
{
    my $class = shift;
    my $self = { words => [@_] };
    bless $self, $class;
}

sub all
{
    my $self = shift;
    wantarray ? @{$self->{words}} : $self->{words};
}

sub set
{
    my $self = shift;
    $self->{words} = [@_];
}

sub add
{
    my $self = shift;
    for (@_) {
        push @{$self->{words}}, $_;
    }
}

sub remove
{
    my $self = shift;
    my $num = shift;
    return if $num > $#{$self->{words}};
    splice @{$self->{words}}, $num, 1;
    #$self->{words} = [@{$self->{words}}[0 .. $num-1, $num+1 .. (@{$self->{words}} - 1)]];
    $self;
}

sub place
{
    my ($self, $from, $to) = @_;
    return if $from > $#{$self->{words}};
    $to = $#{$self->{words}} if $to > $#{$self->{words}};
    my $this = $self->{words}->[$from];
    $self->remove($from);
    splice @{$self->{words}}, $to, 0, $this;
    #$self->{words} = [@{$self->{words}}[0 .. $to-1], $this, @{$self->{words}}[$to .. (@{$self->{words}} - 1)]];
    $self;
}

sub parse
{
    my $self = shift;
    my $windy = shift;
    my $msg = shift;
    my $reply = { Next => 0, Text => undef, Num => undef, };
    debug 'userdb parsing';
    my $r = $self->match($windy, $msg);
    ($reply->{Text}, $reply->{Num}) = @$r if $r;
    $reply;
}

# $words = [ [ pattern(sub), callback, (stopping = 0) ], ...];
sub match
{
    my $self = shift;
    my $windy = shift;
    my $msg = shift;
    debug 'running match';
    debug 'msg text is '.msgText($windy, $msg);
    my $msgScope = ta->newScope(topScope);
    $msgScope->makeVar('windy', 'msg');
    $msgScope->var('windy', $windy);
    $msgScope->var('msg', $msg);
    $msgScope->makeRO;
    my @ret = ();
    my $num = 0;
    for my $this (@{$self->{words}}) {
        $num++;
        my ($ask, $ans) = @$this;
        debug 'ask: '.$ask->{raw};
        debug 'ans: '.$ans->{raw};
        my $scope = ta->newScope($msgScope);
        $scope->makeVar($wordVN);
        $scope->var($wordVN, $this);
        my $env = ta->newEnv($scope);
        msgTAEnv($windy, $msg) = $env;
        debug $env->scope->var($wordVN);
        if ((my @a = $ask->run($windy, $msg))) {
            #$windy->logger("第 $num 条匹配通过了。");
            debug "cond passed-";
            $scope->makeVar($msgMatchVN);
            $scope->var($msgMatchVN, [@a]);
            my $ret = ref $ans eq 'CODE' ?
                $ans->($windy, $msg, @a) :
                $ans->run($windy, $msg, @a);
            if (length $ret) {
                #$windy->logger("然后返回了一个 $ret");
                push @ret, [$ret, $num]; # 若有返回值，则添加到回复列表。
            } else {
                #$windy->logger("然而并没有返回什么");
            }
            if (my $reason = msgStopping($windy, $msg)) {
                @ret = length $ret ? ([$ret, $num]) : ();
                $windy->logger("这条信息".($reason eq 1 ? '' : '因为'.$reason)."到此为止了。");
                last;
            }
        }
    }
    @ret ? $ret[int rand @ret] : undef; # 若有多个选择，随机。
}

sub length
{
    my $self = shift;
    scalar @{$self->{words}};
}
#if (open my $f, '<', $configDir."windy-conf/userdb.pm") {
#    eval join '', <$f>;
#    die $@ if $@;
#} else {
#    debug 'cannot open';
#}

1;
