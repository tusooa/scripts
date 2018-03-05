package Scripts::Windy::Web::Client;

use Mojo::Base 'Mojo::EventEmitter';
use Scripts::Base;
use Scripts::Windy::Web::Model::User;
use Scripts::Windy::Web::Model::Friend;
use Scripts::Windy::Web::Model::Group;
use Scripts::Windy::Web::Model::GroupMember;
use Scripts::Windy::Web::Model::Discuss;
use Scripts::Windy::Web::Model::DiscussMember;
use Scripts::Windy::Web::Util;
use Mojo::JSON qw/decode_json/;
#use Mojo::Util qw/html_unescape/;

has [qw/app me isLoggedIn/];
has friends => sub { []; };
has groups => sub { []; };
has discusses => sub { []; };

# call arbitary API
sub AUTOLOAD
{
    my $self = shift;
    our $AUTOLOAD;
    my $method = $AUTOLOAD =~ s/.+:://r;
    if ($method =~ /^[A-Z]/) { # api names begin with capital letter
        $self->callApi($method, @_);
    } else {
        die "cannot find method $method";
    }
}

# turn crlf into lf, \uXXXX into its unicode
sub procApiResult
{
    my ($self, $text) = @_;
    $text =~ s/\r\n/\n/g;
    $text = convertUtf8CodePoints $text;
    $text;
}

# $client->callApi(FUNC, ARG, ..., [CALLBACK]);
# sub { my $result = shift; ... }
sub callApi
{
    my $self = shift;
    my $callback = ref $_[-1] eq 'CODE' ? pop : undef;
    my @args = map { convertUtf8ForMpq $_ } @_;
    if ($callback) {
        $self->app->apiCaller->callSeq
            (\@args,
             sub
             {
                 my ($ua, $tx) = @_;
                 if ($tx->success) {
                     my $json = $tx->res->json;
                     my $status = $self->procApiResult($json->{seq}[0]);
                     $callback->($status);
                 } else {
                     my $err = $tx->error;
                     say "$err->{code} response: $err->{message}"
                         if $err->{code};
                     $callback->();
                 }
             });
    } else {
        my $tx = $self->app->apiCaller->callSeq(\@args);
        if ($tx->success) {
            my $json = $tx->res->json;
            my $status = $self->procApiResult($json->{seq}[0]);
            return $status;
        } else {
            my $err = $tx->error;
            my $text = $tx->res->text;
            say "$err->{code} response: $err->{message}"
                if $err->{code};
            return $text;
        }
    }
}

sub findFriend
{
    my ($self, $attr, $val) = @_;
    findIn($self->friends, $attr, $val);
}

sub findGroup
{
    my ($self, $attr, $val) = @_;
    findIn($self->groups, $attr, $val);
}

sub findDiscuss
{
    my ($self, $attr, $val) = @_;
    findIn($self->discusses, $attr, $val);
}

sub procFriendList
{
    my $self = shift;
    my $text = utf8df shift;
    my $json = decode_json $text;
    return if $json->{ec} != 0; # which means it failed
    my @friends;
    my $res = $json->{result};
    for my $cat (values %$res) { # since we do not care about the cat num.
        # default group does not have a name, so add it
        my $catName = $cat->{gname} // '我的好友';
        exists $cat->{mems} or next;
        for (@{$cat->{mems}}) {
            # check if we need to construct a new instance
            my $friend = $self->findFriend(tencent => $_->{uin})
                // Scripts::Windy::Web::Model::Friend->new
                (tencent => $_->{uin},
                 client => $self);
            $friend->category($catName);
            $friend->markname(html_unescape $_->{name});
            push @friends, $friend;
        }
    }
    # replace old list, discarding deleted members
    $self->friends(\@friends);
    $self->friends;
}

sub procGroupList # GetGroupListB
{
    my $self = shift;
    my $text = utf8df shift;
    my $json = decode_json $text;
    # check status
    return if $json->{ec} != 0;
    delete $json->{ec};
    # add each group
    my @groups;
    for my $type (keys %$json) {
        for (@{$json->{$type}}) {
            my $group = $self->findGroup(number => $_->{gc})
                // Scripts::Windy::Web::Model::Group->new
                (number => $_->{gc},
                 client => $self);
            $group->name(html_unescape $_->{gn});
            $group->ownerTencent($_->{owner});
            $group->myRelationship($type);
            push @groups, $group;
        }
    }
    # replace old list
    $self->groups(\@groups);
    $self->groups;
}

sub procGroupName # GetGroupMemberB
{
    my ($self, $group, $text) = @_;
    $text =~ s/^_GroupMember_Callback\(//;
    $text =~ s/\);$//;
    $text = utf8df $text;
    my $json = decode_json $text;
    return if $json->{code} != 0;
    $group->name(html_unescape $json->{'group_name'});
}

my %groupRole = (0 => "owner", 1 => "admin", 2 => "member");
my %groupRoleNum = map {; $groupRole{$_} => $_ } keys %groupRole;

sub procGroupInfo # GetGroupMemberA
{
    my ($self, $group, $text) = @_;
    $text = utf8df $text;
    my $json = eval { decode_json $text };
    if ($@ or not $json) { # fall back, only getting the admins
        #$self->GetAdminList($self->me->tencent,
        #                    $group->number);
        return;
    }
    return if $json->{ec} != 0;
    # count info
    $group->adminMax($json->{adm_max});
    $group->memberMax($json->{max_count});
    $group->levelName($json->{levelname});
    # add members
    my @members = ();
    for (@{$json->{mems}}) {
        my $member = $group->findMember(tencent => $_->{uin})
            // Scripts::Windy::Web::Model::GroupMember->new
            (tencent => $_->{uin},
             group => $group,
             client => $self);
        $member->card(html_unescape $_->{card});
        $member->role($groupRole{ $_->{role} });
        $member->name(html_unescape $_->{nick});
        $member->joinTime($_->{join_time});
        $member->lastSpeakTime($_->{last_speak_time});
        $member->level($_->{lv}{level});
        $member->point($_->{lv}{point});
        push @members, $member;
    }
    # replace
    $group->members(\@members);
    $group->adminList([map { $_->tencent }
                       $group->findMember(role => 'admin'),
                       $group->findMember(role => 'owner')]);
    $group;
}

sub newFriend
{
    my $self = shift;
    my @args = @_;
    if (@args == 1 and ref $args[0] eq 'HASH') {
        @args = %{$args[0]};
    }
    my $friend = Scripts::Windy::Web::Model::Friend->new
        (@args, client => $self);
    push @{$self->friends}, $friend;
    $friend;
}

sub newGroup
{
    my $self = shift;
    my @args = @_;
    if (@args == 1 and ref $args[0] eq 'HASH') {
        @args = %{$args[0]};
    }
    my $group = Scripts::Windy::Web::Model::Group->new
        (@args, client => $self);
    #$self->procGroupName
    #    ($group,
    #     $self->GetGroupMemberB($self->me->tencent, $group->number));
    #$self->procGroupInfo
    #    ($group,
    #     $self->GetGroupMemberA($self->me->tencent, $group->number));
    push @{$self->groups}, $group;
    $group;
}

sub newDiscuss
{
    my $self = shift;
    my @args = @_;
    if (@args == 1 and ref $args[0] eq 'HASH') {
        @args = %{$args[0]};
    }
    my $discuss = Scripts::Windy::Web::Model::Discuss->new
        (@args, client => $self);
    push @{$self->discusses}, $discuss;
    $discuss;
}

#debugOn;
sub new
{
    my $class = shift;
    my $self = $class->Mojo::EventEmitter::new(@_);
=comment
    $self->on
        (loggedIn => sub
         {
             my $tencent = $self->GetQQlist;
             $self->me(Scripts::Windy::Web::Model::User->new
                       (tencent => $tencent,
                        client => $self));
             debug "logged in! getting friend list...";
             $self->isLoggedIn(1);
             my $r = $self->procFriendList
                 ($self->GetFriendList($tencent));
             if ($r) {
                 debug "done!";
                 debug sub
                 {
                     for (@{$self->friends}) {
                         say term 'name: '.$_->name."\n"
                             .'uid: '.$_->tencent."\n"
                             .'cat: '.$_->category;
                     }
                 };
             } else {
                 debug "error!";
             }
             debug "getting group list";
             $r = $self->procGroupList
                 ($self->GetGroupListB($tencent));
             if ($r) {
                 debug "done!";
                 debug sub {
                     for (@{$self->groups}) {
                         say term 'name: ' . $_->name
                             . 'number: ' . $_->number
                             . 'owner: ' . $_->ownerTencent;
                     }
                 };
             }
             debug "getting group info...";
             for my $g (@{$self->groups}) {
                 #debug "Sleeping 2s...";
                 #sleep 2;
                 debug "Group: ". $g->number . $g->name;
                 my $res = $self->GetGroupMemberA($tencent, $g->number);
                 $self->procGroupInfo($g, $res);
                 if ($@) {
                     debug "error: $@";
                 }
                 debug sub {
                     for (@{$g->members}) {
                         say term 'name: ' . $_->name
                             . 'card: ' . $_->card
                             . 'tencent: ' . $_->tencent
                             . 'role: ' . $_->role;
                     }
                 };
             }
         });
    $self->on
        (loggedOut => sub
         {
             $self->isLoggedIn(0);
         });
=cut
    $self;
}

my %SendMessageType = (
    'friend-message' => 1,
    'group-message' => 2,
    'discuss-message' => 3,
    'group-sess-message' => 4,
    'discuss-sess-message' => 5,
    );

sub sendMessage
{
    my ($self, $typeName, $source, $receiver, $content) = @_;
    $self->SendMsg($self->me->tencent,
                   $SendMessageType{$typeName},
                   0, # Fixed
                   $source,
                   $receiver,
                   $content,
        );
}

1;
