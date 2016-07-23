package Scripts::Windy;

use Scripts::scriptFunctions;
use Scripts::Windy::Conf::userdb;
use 5.012;
no warnings 'experimental';
use POSIX qw/strftime/;
use IO::Handle;
use Data::Dumper;
sub new
{
    my $class = shift;
    my $c = conf 'windy';
    my $self = {};
    #checkReopenLogFile($self);
    bless $self, $class;
}

sub parse
{
    my $self = shift;
    my $msg = shift;
    my $ret = $database->parse($self, $msg);
    $ret->{Text};
=comment
    for my $a (@{ $self->{Addons} }) {
        say 'addon:'. $a;
        no strict 'refs';
        my $prefix = "Scripts::Windy::Addons::$a";
        $ret = $prefix->parse($self, $msg);
        $text.=$ret->{Text};
        return $text if ! $ret->{Next};
    }
=cut
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
    my ($pack, $func) = (caller)[0,3];
    #$self->checkReopenLogFile;
    my @a = (strftime("%Y,%m,%d (%w) %H,%M,%S", localtime), "[[$colorcode$pack ${func}${nocol}]]", @_);
    say term @a;
    #say "LOG is: ".$self->{log};
    #$self->{log}->say(@a);
}

1;
