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
    $self->{dest} = Scripts::Windy::Dest->new($tencent, $type, $subtype, $source, $subject);
    $self;
}

my @messageId = map $Events{$_}, 'friend-msg','group-msg','discuss-msg','sess-msg';
sub reply
{
    my $self = shift;
    $self->{dest} and $self->{dest}->send(@_);
}
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
1;

package Scripts::Windy::Dest;
use Scripts::scriptFunctions;
use 5.012;
use Scripts::Windy::Constants;
use Scripts::Windy::Util;
use Scripts::Windy::APICall;

sub new
{
    my ($class, $tencent, $type, $subtype, $source, $subject) = @_;
    my $self = {
        receiver => $tencent,
        type => $type,
        subtype => $subtype,
        source => $source,
        subject => $subject,
    };
    bless $self, $class;
    my @dest;
    for ($self->{type}) {
        @dest = ($_, 0, $self->{source}, $self->{subject}) when $Events{'friend-msg'} || $Events{'sess-msg'};
        @dest = ($_, 0, $self->{source}, '') when $Events{'group-msg'} || $Events{'discuss-msg'};
        @dest = ($Events{'friend-msg'}, 0, '', $self->{subject}) when $EventId{$_} ~~ /friend/;
        @dest = ($Events{'group-msg'}, 0, $self->{source}, '') when $EventId{$_} ~~ /group/;
    }
    $self->{sendArgs} = @dest ? [@dest] : undef;
    $self;
}

sub send
{
    my ($self, $text) = @_;
    return unless $self->{sendArgs};
    my $tencent = $self->{receiver};
    my @call;
    for (split $nextMessage, $text) {
        push @call, ['SendMsg', $tencent, @{$self->{sendArgs}}, term $_];
    }
    callApi(@call);
}

1;
