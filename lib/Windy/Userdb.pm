package Scripts::Windy::Userdb;
use 5.012;
no warnings 'experimental';
use Scripts::scriptFunctions;
use Scripts::Windy::Util;
use Data::Dumper;
use utf8;
#$Scripts::scriptFunctions::debug = 1;
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
    $self->{words} = [@{$self->{words}}[0 .. $num-1, $num+1 .. (@{$self->{words}} - 1)]];
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
    #$windy->logger("正在处理此行: ".msgText($windy, $msg));
    my @ret = ();
    for (@{$self->{words}}) {
        #        my $m = $words->[$_];
        #say term 'word: '. $_->[0]->{raw};
        #debug 'word:'.Dumper ($_->[0]);
        if ((my @a = #(ref $_->[0] eq 'CODE' ?
             #$_->[0]->($windy, $msg) :
             $_->[0]->run($windy, $msg))) {
            #debug '@a:'. Dumper (@a);
            #debug 'scalar @a:'. scalar @a;
            my $ret = ref $_->[1] eq 'CODE' ?
                $_->[1]->($windy, $msg, @a) :
                $_->[1]->run($windy, $msg, @a);
            #$windy->logger("一个可选的回复是: ".$ret);
            #debug 'matching, returning '.$ret;
            push @ret, $ret if $ret; # 若有返回值，则添加到回复列表。
            if (msgStopping($windy, $msg)) {
                @ret = $ret ? ($ret) : ();
                $windy->logger("这条信息到此为止了。");
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
