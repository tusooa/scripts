package Scripts::Windy::Event;
use 5.012;
use Scripts::scriptFunctions;
#use List::Util qw/first/;
use Scripts::Windy::Constants;
no warnings 'experimental';
sub new
{
    my ($class, $tencent, $type, $subtype, $source, $subject, $object, $msg, $raw) = @_;
    my $self = {
        receiver => $tencent,
        type => $type,
        subtype => $subtype,
        source => $source,
        subject => $subject,
        object => $object,
        content => utf8($msg),
        raw => $raw,};
    bless $self, $class;
    
    $self;
}

my @messageId = map $Events{$_}, 'friend-msg','group-msg','discuss-msg','sess-msg';

sub isMessage
{
    my $self = shift;
    $self->{type} ~~ @messageId;
}

sub sender
{
    shift->{subject};
}

sub receiver
{
    shift->{receiver};
}

sub content
{
    shift->{content};
}
