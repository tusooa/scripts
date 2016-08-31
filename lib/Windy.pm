package Scripts::Windy;

use Scripts::scriptFunctions;
use Scripts::Windy::Conf::userdb;
use 5.012;
no warnings 'experimental';
use POSIX qw/strftime/;
use IO::Handle;
use Data::Dumper;
# param: logToFile - default to false
sub new
{
    my $class = shift;
    my $c = conf 'windy';
    my $self = @_ % 2 ? (return undef) : {@_};
    $self->{_db} = $database;
    checkReopenLogFile($self) if $self->{logToFile};
    bless $self, $class;
}

sub parse
{
    my $self = shift;
    my $msg = shift;
    my $ret = $database->parse($self, $msg); # From Scripts::Conf::Windy::userdb
    $ret->{Text};
}

sub checkReopenLogFile
{
    my $self = shift;
    my $today = time2date;
    if ($self->{date} ne $today) {
        my $oldlog = $self->{log};
        $self->{date} = $today;
        open $self->{log}, '>>', $configDir.'windy-cache/logs'.$self->{date}.'.txt' or say "Cannot open logf: $!";
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
    my @a = (strftime("%Y,%m,%d (%w) %H,%M,%S", localtime), "[[$colorcode${func}${nocol}]]", @_);
    say term @a;
    #say "LOG is: ".$self->{log};
    $self->{log}->say(@a) if $self->{logToFile};
}

1;
