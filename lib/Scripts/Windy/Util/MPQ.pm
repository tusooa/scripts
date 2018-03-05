package Scripts::Windy::Util::MPQ;

use 5.012;
use Exporter;
use Scripts::scriptFunctions;
use utf8;
use Encode qw/_utf8_on _utf8_off/;
#use Scripts::Windy::Constants;
no warnings 'experimental';
#use Data::Dumper;
our @ISA = qw/Exporter/;
#our @EXPORT = qw/isGroupMsg isDiscussMsg msgText msgGroup msgGroupId
#msgGroupHas msgSenderIsGroupAdmin msgStopping msgSender
#uid uName isAt isAtId findUserInGroup isPrivateMsg
#group invite friend $nextMessage $atPrefix $atSuffix
#parseRichText $mainConf msgPosStart msgPosEnd
#msgReceiver receiverName replyToMsg outputLog getAdminList isMsg
#    sendTo/;
our @EXPORT = qw/isGroupMsg msgText msgGroup msgGroupId msgGroupName
isDiscussMsg msgDiscuss msgDiscussName msgDiscussId
msgGroupHas msgSenderIsGroupAdmin msgStopping msgSender
uid uName isAt isAtId findUserInGroup isPrivateMsg
group invite friend $atPrefix $atSuffix
parseRichText msgPosStart msgPosEnd
msgReceiver receiverName outputLog isMsg sendTo
msgGroupMembers setGroupCard msgTextNoAt
msgSource/;

our @EXPORT_OK = qw//;
use Scripts::Windy::Util::Base;
our $atPrefix = "[";
our $atSuffix = "]";
my @privMsg = ('friend-message',
               'group-sess-message',
               'discuss-sess-message');
my @multMsg = ('group-message',
               'discuss-message');

sub isGroupMsg
{
    my ($windy, $msg) = @_;
    $msg->typeName eq 'group-message';
}

sub isDiscussMsg
{
    my ($windy, $msg) = @_;
    $msg->typeName eq 'discuss-message';
}

sub isPrivateMsg
{
    my ($windy, $msg) = @_;
    $msg->typeName ~~ @privMsg;
}

sub shortenDName
{
    my $name = shift;
    _utf8_off($name);
    $name;
}

sub parseRichText
{
    my ($windy, $msg) = @_;
    my $match = $windy->{_db}->{_match};
    my $text = $msg->msg;
    _utf8_on($text);
    my $id = uid(msgReceiver($windy, $msg));
    isAt($windy, $msg) = $text =~ /\Q$atPrefix\E\@$id\Q$atSuffix\E/;
    msgText($windy, $msg) = $text;
    my ($pre, $post) = ($match->{preMatch}, $match->{postMatch});
    $text =~ $pre; msgPosStart($windy, $msg) = length $&;
    $text =~ $post; msgPosEnd($windy, $msg) = length $&;
    msgTextNoAt($windy, $msg) =
        $text =~ s/\Q$atPrefix\E\@[0-9]+\Q$atSuffix\E//gr;
    msgText($windy, $msg);
}

sub replyToMsg
{
    my ($windy, $msg, $content) = @_;
    $msg or return;
    $msg->reply($content);
}

sub msgPosStart : lvalue
{
    my ($windy, $msg) = @_;
    $msg->{_pos_start};
}

sub msgPosEnd : lvalue
{
    my ($windy, $msg) = @_;
    $msg->{_pos_end};
}

sub msgTextNoAt : lvalue
{
    my ($windy, $msg) = @_;
    $msg->{__text_no_at};
}

sub msgText : lvalue
{
    my $windy = shift;
    my $msg = shift;
    $msg->{__rich_text};
}

sub msgGroup
{
    my ($windy, $msg) = @_;
    isGroupMsg(@_) and $msg->sourcePlace;
}

sub msgDiscuss
{
    my ($windy, $msg) = @_;
    isDiscussMsg(@_) and $msg->sourcePlace;
}

sub msgGroupId
{
    my ($windy, $msg) = @_;
    isGroupMsg(@_) and $msg->sourcePlace->number;
}

sub msgDiscussId
{
    my ($windy, $msg) = @_;
    isDiscussMsg(@_) and $msg->sourcePlace->id;
}

sub msgGroupName
{
    my ($windy, $msg) = @_;
    isGroupMsg(@_) or return;
    my $name = $msg->sourcePlace->name;
    # already utf8 on
}

sub msgDiscussName
{
    my ($windy, $msg) = @_;
    isDiscussMsg(@_) or return;
    my $name = $msg->sourcePlace->name;
}

sub friend
{
    my ($windy, $msg, $f) = @_;
    $msg->client->findFriend(tencent => $f);
}

sub group
{
    my ($windy, $msg, $g) = @_;
    $msg->client->findGroup(number => $g);
}

sub invite
{
    my ($windy, $msg, $group, $person) = @_;
    return unless $group and $person;
    #not MPQ::GroupInvitation(msgReceiver($windy, $msg), $person, $group);
}

sub msgGroupHas
{
    my ($windy, $msg, $id) = @_;
    isGroupMsg(@_) and msgGroup($windy, $msg)->findMember(tencent => $id);
}

sub msgStopping : lvalue
{
    my ($windy, $msg) = @_;
    $msg->{__stopping__};
}

sub msgSender
{
    my ($windy, $msg) = @_;
    $msg->subjectUser;
}

sub msgReceiver
{
    my ($windy, $msg) = @_;
    $msg->objectUser;
}

sub msgSenderIsGroupAdmin
{
    my ($windy, $msg) = @_;
    if (isGroupMsg($windy, $msg)) {
        msgSender($windy, $msg)->isAdminOrOwner;
    } elsif (isPrivateMsg($windy, $msg)) { # person is always their admin
        1;
    } else { # discuss message
        0;
    }
}

sub uid
{
    my $user = shift;
    $user->tencent;
}

sub uName
{
    my $user = shift;
    $user->displayname;
    #$atPrefix.shift.$atSuffix;
}

sub receiverName
{
    my $windy = shift;
    my $msg = shift;
    uName(msgReceiver($windy, $msg));
}

sub isAt : lvalue
{
    my $windy = shift;
    my $msg = shift;
    $msg->{__is_at};
}

sub isAtId
{
    my ($windy, $msg, $id) = @_;
    msgText($windy, $msg) =~ /\Q$atPrefix\E\@$id\Q$atSuffix\E/;
}

sub findUserInGroup
{
    my $windy = shift;
    my $uid = shift;
    my $group = shift;
    $group->findMember(tencent => $uid);
}

sub outputLog
{
    1;
}

sub isMsg
{
    my ($windy, $msg) = @_;
    $msg->isMessage;
}

sub sendTo
{
    my ($to, $content) = @_;
    $to or return;
    for (split $nextMessage, $content) {
        $to->send($_);
    }
}

sub msgGroupMembers
{
    my ($windy, $msg) = @_;
    isGroupMsg(@_) and $msg->sourcePlace->members;
}

sub setGroupCard
{
    my ($windy, $msg, $member, $card) = @_;
    $member or return;
    $member->setCard($card);
}

sub msgSource
{
    my ($windy, $msg) = @_;
    if (isGroupMsg($windy, $msg)) {
        msgGroupId($windy, $msg);
    } elsif (isDiscussMsg($windy, $msg)) {
        msgDiscussId($windy, $msg).'D';
    } elsif (isPrivateMsg($windy, $msg)) {
        uid(msgSender($windy, $msg)).'P';
    }
}

1;
