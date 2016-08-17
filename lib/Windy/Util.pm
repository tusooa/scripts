package Scripts::Windy::Util;

use 5.012;
use Exporter;
use Scripts::scriptFunctions;
use utf8;

#use Data::Dumper;
our @ISA = qw/Exporter/;
our @EXPORT = qw/isGroupMsg msgText msgGroup msgGroupId msgGroupHas msgSenderIsGroupAdmin msgStopping msgSender uid uName isAt findUserInGroup isPrivateMsg group invite friend $nextMessage/;
our @EXPORT_OK = qw//;

our $nextMessage = "\n\n";
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

sub msgText
{
#    print Dumper(@_);
    my $windy = shift;
    my $msg = shift;
    $msg->content;
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

sub isAt
{
    my $windy = shift;
    my $msg = shift;
    $msg->is_at(@_);
}

sub findUserInGroup
{
    my $windy = shift;
    my $uid = shift;
    my $group = shift;
    $group->search_group_member(qq => $uid);
}
1;
