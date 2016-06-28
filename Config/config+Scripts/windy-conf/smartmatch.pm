use 5.012;
no warnings 'experimental';
use Scripts::Windy::Addons::Nickname;
loadNicknames;
$d1 = '【';
$d2 = '】';
$d3 = '{';
$d4 = '}';
$d5 = '<';
$d6 = '>';
my $myName = qr/(?:小|西)?风(?:妹(?:子|儿|砸|妹)?|儿|酱|姐{1,2})/;
my $If = qr/(?:(?:如)?若|如果)/;
my $Then = qr/(?:则|那么)/;
my $Else = qr/(?:不然|否则)(?:的话)?/;
my $subs = {
    AsIs => sub {
        my $windy = shift;
        my ($msg, $m1) = @_;
        my $m = expr $m1;
        $m->($windy, $msg)
    },
    IfThenElse => sub {
        my $windy = shift;
        my ($msg, $m1, $m2, $m3) = @_;
        if ((expr $m1)->($windy, $msg)) {
            (expr $m2)->($windy, $msg);
        } else {
            (expr $m3)->($windy, $msg);
        }
    },
    IfThen => sub {
        my $windy = shift;
        my ($msg, $m1, $m2) = @_;
        if ((expr $m1)->($windy, $msg)) {
            (expr $m2)->($windy, $msg);
        }
        undef
    },
    And => sub {
        my $windy = shift;
        my ($msg, $m1, $m2) = @_;
        (expr $m1)->($windy, $msg) and (expr $m2)->($windy, $msg);
    },
    Or => sub {
        my $windy = shift;
        my ($msg, $m1, $m2) = @_;
        (expr $m1)->($windy, $msg) or (expr $m2)->($windy, $msg);
    },
    Not => sub {
        my $windy = shift;
        my ($msg, $m1) = @_;
        debug 'not #52:'. Dumper ($m1);
        not ((expr $m1)->($windy, $msg));
    },
    Op => sub {
        my $windy = shift;
        my ($msg, $m1, $e, $m2) = @_;
        my $r1 = (expr $m1)->($windy, $msg);
        my $r2 = (expr $m2)->($windy, $msg);
        given ($e) {
            $r1 > $r2 when '大于';
            $r1 == $r2 when '等于';
            $r1 < $r2 when '小于';
            $r1 <= $r2 when '不大于';
            $r1 >= $r2 when '不小于';
            $r1 != $r2 when '不等于';
            $r1 eq $r2 when '为';
            #$r1 ~~ $r2 when '是';
        }
    },
};
$aliases = [
    # Remove spaces
    [qr/^\s+(.+)$/, $subs->{AsIs}],
    [qr/^(.+?)\s+$/, $subs->{AsIs}],
    [qr/^(?:回)?答(.+)$/, $subs->{AsIs}],
    # Plain
    [qr/^$d3(.+)?$d4$/, sub { my ($windy, $msg, $m1) = @_; $m1 }],
    # Control structures
    [qr/^$If(.+?)，$Then(.+?)，$Else(.+)$/, $subs->{IfThenElse}],
    [qr/^$If(.+?)，$Then(.+)$/, $subs->{IfThen}],
    # Logical expressions
    [qr/^(.+?)(?:并且|而且|且)(.+)$/, $subs->{And}],
    [qr/^(.+?)(?:或者|或是|或)(.+)$/, $subs->{Or}],
    [qr/^不是(.+)$/, $subs->{Not}],
    # Comparison expressions
    [qr/^(.+)((?:不)?(?:大|等|小)于|为)(.+)$/, $subs->{Op}],
    [qr/^(?:随机|任选)(.+)$/s, sub { my ($windy, $msg, $m1) = @_; my @arr = split /\n/, $m1; (expr $arr[int rand @arr])->($windy, $msg) } ],
    # Functions
    [qr/^群讯$/, sub { isGroupMsg(@_) }],
    [qr/^截止$/, sub { print "i am stopping parse this message"; msgStopping(@_) = 1; '' } ],
    [qr/^(?:来讯者(?:名|的名字))$/, \&senderNickname],
    [qr/^好感(?:度)?$/, sub { 0 }],
    [qr/^(?:对|艾特)(?:我|你)$/, sub { my $windy = shift; my $msg = shift; isAt($windy, $msg) or msgText($windy, $msg) =~ /^\s*$myName(?:\s+|，|。)?/ }],
    ];
$replacements = {
    '风妹' => qr/\s*$myName(?:\s+|，|。)?/,
    };
1;
