#use 5.012;
no warnings 'experimental';
use Scripts::Windy::Util;
#sub debug { print @_; }
sub start
{
    my $windy = shift;
    my $msg = shift;
    $windy->{startGroup} = [] if ref $windy->{startGroup} ne 'ARRAY';
    if (! grep $_ eq msgGroupId($windy, $msg), @{$windy->{startGroup}}) {
        push @{$windy->{startGroup}}, msgGroupId($windy, $msg);
        debug "starting on ".msgGroupId($windy, $msg);
        sr("【截止】咱在这里呢w")->($windy, $msg);
    } else {
        sr("【截止】嗯哼0 0?")->($windy, $msg);
    }
}
sub stop
{
    my $windy = shift;
    my $msg = shift;
    $windy->{startGroup} = [] if ref $windy->{startGroup} ne 'ARRAY';
    @{$windy->{startGroup}} = grep $_ ne msgGroupId($windy, $msg), @{$windy->{startGroup}};
    sr("【截止】那...咱走惹QAQ")->($windy, $msg);
}
sub teach
{
    my $windy = shift;
    my ($msg, $ask, $ans) = @_;
    debug 'teaching:';
    debug 'ques:'.$ask;
    debug 'answ:'.$ans;
    return if !$ask or !$ans;
    push @$words, [sm($ask), sr($ans)];
    if (open my $f, '>>', $configDir.'windy-conf/userdb.db') {
        say $f "\tAsk$ask\n\tAns$ans";
    } else {
        debug 'cannot open db for write'."$!";
    }
    sr("【截止】咱好像明白惹QAQ")->($windy, $msg);
}

push @$words, [sm("【不是群讯】"), sr("【截止】")];
push @$words, [sm(q/^<风妹>出来$/), \&start];
push @$words, [sm(q/^<风妹>回去$/), \&stop];
push @$words, [sm(q/^<风妹>若问(.+?)即答(.+)$/), \&teach];
push @$words, [sm(q/^<风妹>问(.+?)答(.+)$/), sub { $_[2] = '^'.$_[2].'$'; teach(@_); }];


if (open my $f, '<', $configDir.'windy-conf/userdb.db') {
    my ($ask, $ans);
    my $ref;
    while (<$f>) {
        if (s/^\tAsk//) {
            chomp ($ask, $ans);
            push @$words, [sm($ask), sr($ans)] if $ask and $ans;
            $ask = '';
            $ans = '';
            $ref = \$ask;
        } elsif (s/^\tAns//) {
            $ref = \$ans;
        }
        $$ref .= $_;
    }
    chomp ($ask, $ans);
    push @$words, [sm($ask), sr($ans)] if $ask and $ans;
} else {
    debug 'cannot open';
}

1;
