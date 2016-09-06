package Scripts::Windy::Util;

use 5.012;
use Exporter;
use Scripts::scriptFunctions;
use utf8;
use Encode qw/_utf8_on _utf8_off/;
#use Data::Dumper;
our @ISA = qw/Exporter/;
our @EXPORT = qw/isGroupMsg msgText msgGroup msgGroupId msgGroupHas msgSenderIsGroupAdmin msgStopping msgSender uid uName isAt isAtId findUserInGroup isPrivateMsg group invite friend $nextMessage $atPrefix $atSuffix parseRichText/;
our @EXPORT_OK = qw//;

our $nextMessage = "\n\n";
our $atPrefix = "\tat";
our $atSuffix = "\t";
# check whether a msg is a group msg
sub isGroupMsg
{
    my $windy = shift;
    my $msg = shift;
    ref $msg eq 'Mojo::Webqq::Message::Recv::GroupMessage';
}

sub isPrivateMsg
{
    my ($windy, $msg) = @_;
    $msg->type =~ /^(?:sess_)?message$/;
}

sub parseRichText
{
    my ($windy, $msg) = @_;
    my @raw = @{ $msg->raw_content };
    my $text;
    while (@raw) {
        my $head = shift @raw;
        if ($head->{type} eq 'txt'
            and $head->{content} =~ /^\@/
            and $raw[0]->{type} eq 'txt'
            and $raw[0]->{content} eq '') {
            shift @raw;
            my $at = $head->{content};
            _utf8_on($at);
            $at = substr $at, 0, 8; # 只能有七个字。
            _utf8_off($at);
            $text .= $atPrefix.$at.$atSuffix;
        } else {
            $text .= $head->{content};
        }
    }
    my $name = $msg->receiver->displayname;
    isAt($windy, $msg) = $text =~ /\Q$atPrefix\E\@\Q$name$atSuffix\E/;
    msgText($windy, $msg) = $text;
}

sub msgText : lvalue
{
#    print Dumper(@_);
    my $windy = shift;
    my $msg = shift;
    $msg->{__rich_text};
}

sub msgGroup
{
    my ($windy, $msg) = @_;
    isGroupMsg(@_) and $msg->group;
}

sub msgGroupId
{
    my ($windy, $msg) = @_;
    isGroupMsg(@_) and $msg->group->gnumber;
}

sub friend
{
    my ($windy, $msg, $f) = @_;
    $msg->{_client}->search_friend(qq => $f);
}
sub group
{
    my ($windy, $msg, $g) = @_;
    $msg->{_client}->search_group(gnumber => $g);
}

sub invite
{
    my ($windy, $msg, $group, $person) = @_;
    return unless $group and $person;
    $group->invite_friend($person);
}

sub msgGroupHas
{
    my ($windy, $msg, $id) = @_;
    isGroupMsg(@_) and $msg->group->search_group_member(qq => $id); # 这条可能会。很。慢。嗯。
}
sub msgStopping : lvalue
{
    my ($windy, $msg) = @_;
    $msg->{__stopping__};
}

sub msgSender
{
    my ($windy, $msg) = @_;
    $msg->sender;
}

sub msgSenderIsGroupAdmin
{
    my ($windy, $msg) = @_;
    isGroupMsg($windy, $msg) and $msg->sender->role eq 'owner' or $msg->sender->role eq 'admin';
}

sub uid
{
    shift->qq;
}

sub uName
{
    shift->displayname;
}

sub isAt : lvalue
{
    my $windy = shift;
    my $msg = shift;
    $msg->{__is_at};
#    my $ret = msgText($windy, $msg) =~ $msg->{__at_regex};
#    $windy->logger("name is ". $msg->receiver->displayname);
#    $windy->logger("艾特了风儿。") if $ret;
#    $ret;
}

sub isAtId
{
    my ($windy, $msg, $id) = @_;
    my $user = msgGroupHas($windy, $msg, $id) or return;
    my $name = $user->displayname;
    msgText($windy, $msg) =~ /\Q$atPrefix\E\@\Q$name$atSuffix\E/;
}

sub findUserInGroup
{
    my $windy = shift;
    my $uid = shift;
    my $group = shift;
    $group->search_group_member(qq => $uid);
}
1;
