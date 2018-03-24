package Scripts::Windy;
use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/windy/;
our $windy;
use Scripts::Base;
use Scripts::Windy::Conf::userdb;
use 5.012;
no warnings 'experimental';
use POSIX qw/strftime/;
use IO::Handle;
use Data::Dumper;
use Scripts::Windy::Util;
use Encode qw/_utf8_on _utf8_off/;
use utf8;
#debugOn;
# param: logToFile - default to false
sub new
{
    my $class = shift;
    if ($windy) {
        my %args = (@_ % 2 ? undef : @_);
        for (keys %args) {
            $windy->{$_} = $args{$_};
        }
        $windy;
    } else {
        $windy = @_ % 2 ? (return undef) : {@_};
        $windy->{_db} = $database;
        bless $windy, $class;
        $windy->loadConf;
        $windy;
    }
}

sub windy
{
    $windy or __PACKAGE__->new(@_);
}

sub loadConf
{
    my $self = shift;
    $self->{logToFile} = $windyConf->get('log-to-file');
    if ($self->{logToFile}) {
        checkReopenLogFile($self);
    } else {
        close $self->{log} if $self->{log};
    }
    $self;
}

sub parse
{
    my $self = shift;
    my $msg = shift;
    debug "windy.parse";
    my $ret = $database->parse($self, $msg); # From Scripts::Conf::Windy::userdb
    $ret;
}

sub checkReopenLogFile
{
    my $self = shift;
    my $today = time2date;
    if ($self->{date} ne $today) {
        my $oldlog = $self->{log};
        $self->{date} = $today;
        open $self->{log}, '>>', term $configDir.'windy-cache/logs'.$self->{date}.'.txt' or say "Cannot open logf: $!";
        binmode $self->{log}, ':unix';
        close $oldlog if $oldlog;
    }
}

my $colorcode = "\e[1;36m";
my $nocol = "\e[0m";
sub logger
{
    my $self = shift;
    my ($pack, $func) = ((caller 0)[0],(caller 1)[3]); # 倒回 1 层。
    # FIXME: 为什么第一个是0，而第二个是1？？？
    $self->checkReopenLogFile if $self->{logToFile};
    my $s = join '', (formatTime(localtime), (-t STDOUT ? "[[$colorcode${func}${nocol}]]" : "[[${func}]]"), @_);
    say term $s;
    outputLog($s);
    #say "LOG is: ".$self->{log};
    _utf8_off($s);
    $self->{log}->say($s) if $self->{logToFile};
}

$windy = __PACKAGE__->new;
1;
