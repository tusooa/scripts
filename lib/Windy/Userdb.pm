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
    my $reply = { Next => 0, Text => undef };
    debug 'userdb parsing';
    $reply->{Text} = $self->match($windy, $msg);
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
    for (@{$self->{words}}) {
        debug 'ask: '.$_->[0];
        debug 'ans: '.$_->[1];
        my $scope = ta->newScope($msgScope);
        my $env = ta->newEnv($scope);
        msgTAEnv($windy, $msg) = $env;
        if ((my @a = $_->[0]->run($windy, $msg))) {
            debug "cond passed-";
            $scope->makeVar($msgMatchVN);
            $scope->var($msgMatchVN, [@a]);
            my $ret = ref $_->[1] eq 'CODE' ?
                $_->[1]->($windy, $msg, @a) :
                $_->[1]->run($windy, $msg, @a);
            push @ret, $ret if $ret; # 若有返回值，则添加到回复列表。
            if (my $reason = msgStopping($windy, $msg)) {
                @ret = $ret ? ($ret) : ();
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
