package Scripts::Windy::Conf::userdb;

use 5.012;
use Scripts::scriptFunctions;
no warnings 'experimental';
use Scripts::Windy::Util;
use Scripts::Windy::Userdb;
use Scripts::Windy::Conf::smartmatch;
use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/$database/;
our $database;
#sub debug { print @_; }

my $startRes1 = sr("【截止】咱在这里呢w");
#use Data::Dumper;
#use Mojo::Webqq::Message::Recv::GroupMessage;
#die Dumper (($startRes1)->({}, bless { content => '1234',}, 'Mojo::Webqq::Message::Recv::GroupMessage'));
my $startRes2 = sr("【截止】嗯哼0 0?");
sub start
{
    my $windy = shift;
    my $msg = shift;
    $windy->{startGroup} = [] if ref $windy->{startGroup} ne 'ARRAY';
    if (! grep $_ eq msgGroupId($windy, $msg), @{$windy->{startGroup}}) {
        push @{$windy->{startGroup}}, msgGroupId($windy, $msg);
        debug "starting on ".msgGroupId($windy, $msg);
        $startRes1->($windy, $msg);
    } else {
        $startRes2->($windy, $msg);
    }
}

my $stopRes = sr("【截止】那...咱走惹QAQ");
sub stop
{
    my $windy = shift;
    my $msg = shift;
    $windy->{startGroup} = [] if ref $windy->{startGroup} ne 'ARRAY';
    @{$windy->{startGroup}} = grep $_ ne msgGroupId($windy, $msg), @{$windy->{startGroup}};
    $stopRes->($windy, $msg);
}

my $teachRes = sr("【截止】咱好像明白惹QAQ");
sub teach
{
    my $windy = shift;
    my ($msg, $ask, $ans) = @_;
    debug 'teaching:';
    debug 'ques:'.$ask;
    debug 'answ:'.$ans;
    return if !$ask or !$ans;
    $database->add([sm($ask), sr($ans)]);
    if (open my $f, '>>', $configDir.'windy-conf/userdb.db') {
        say $f "\tAsk$ask\n\tAns$ans";
    } else {
        debug 'cannot open db for write'."$!";
    }
    $teachRes->($windy, $msg);
}

$database = Scripts::Windy::Userdb->new(
[sm(qr/^<风妹>出来$/), \&start],
[sm("【不是群讯】"), sr("【截止】")],
[sm(qr/^<风妹>回去$/), \&stop],
[sm(qr/^<风妹>若问(.+?)即答(.+)$/), \&teach],
[sm(qr/^<风妹>问(.+?)答(.+)$/), sub { $_[2] = '^'.$_[2].'$'; teach(@_); }]);


if (open my $f, '<', $configDir.'windy-conf/userdb.db') {
    my ($ask, $ans);
    my $ref;
    while (<$f>) {
        if (s/^\tAsk//) {
            chomp ($ask, $ans);
            $database->add([sm($ask), sr($ans)]) if $ask and $ans;
            $ask = '';
            $ans = '';
            $ref = \$ask;
        } elsif (s/^\tAns//) {
            $ref = \$ans;
        }
        $$ref .= $_;
    }
    chomp ($ask, $ans);
    $database->add([sm($ask), sr($ans)]) if $ask and $ans;
} else {
    debug 'cannot open';
}

1;
