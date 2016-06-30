package Scripts::Windy::Userdb;
use 5.012;
no warnings 'experimental';
use Scripts::scriptFunctions;
use Scripts::Windy::Util;
use Data::Dumper;
$Scripts::scriptFunctions::debug = 0;

sub new
{
    my $class = shift;
    my $self = { words => [@_] };
    bless $self, $class;
}

sub add
{
    my $self = shift;
    for (@_) {
        push @{$self->{words}}, $_;
    }
}
#my $conf = conf 'windy-conf/startstop';
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
    my @ret = ();
    for (@{$self->{words}}) {
#        my $m = $words->[$_];
        debug 'word:'.Dumper ($_->[0]);
        if ((my @a = $_->[0]($windy, $msg))) {
            debug '@a:'. Dumper (@a);
            debug 'scalar @a:'. scalar @a;
            my $ret = ref $_->[1] eq 'CODE' ? $_->[1]($windy, $msg, @a) : $_->[1];
            debug 'matching, returning '.$ret;
            push @ret, $ret if $ret; # 若有返回值，则添加到回复列表。
            last if msgStopping($windy, $msg);
        }
    }
    @ret ? $ret[int rand @ret] : undef; # 若有多个选择，随机。
}

#if (open my $f, '<', $configDir."windy-conf/userdb.pm") {
#    eval join '', <$f>;
#    die $@ if $@;
#} else {
#    debug 'cannot open';
#}

1;
