package Scripts::Windy::Util;

use 5.012;
use Exporter;
use Scripts::scriptFunctions;
#use Data::Dumper;
our @ISA = qw/Exporter/;
our @EXPORT = qw/isGroupMsg msgText msgGroupId msgGroupHas msgSenderIsGroupAdmin msgStopping msgSender uid uName isAt/;
our @EXPORT_OK = qw//;

# check whether a msg is a group msg
sub isGroupMsg
{
    my $windy = shift;
    my $msg = shift;
    ref $msg eq 'Mojo::Webqq::Message::Recv::GroupMessage';
}

sub msgText
{
#    print Dumper(@_);
    my $windy = shift;
    my $msg = shift;
    $msg->content;
}

sub msgGroupId
{
    my ($windy, $msg) = @_;
    $msg->group->gnumber;
}

sub msgGroupHas
{
    my ($windy, $msg, $id) = @_;
    $msg->group->search_group_member(qq => $id); # 这条可能会。很。慢。嗯。
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


1;
