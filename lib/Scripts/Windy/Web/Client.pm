package Scripts::Windy::Web::Client;

use Mojo::Base 'Mojo::EventEmitter';
use Scripts::Base;
use Scripts::Windy::Web::Model::User;
use Scripts::Windy::Web::Model::Friend;
use Scripts::Windy::Web::Model::GroupMember;
use Scripts::Windy::Web::Util;
use Mojo::JSON qw/decode_json/;

has [qw/app me isLoggedIn/];
has friends => sub { []; };
has groups => sub { []; };

# call arbitary API
sub AUTOLOAD
{
    my $self = shift;
    our $AUTOLOAD;
    my $method = $AUTOLOAD =~ s/.+:://r;
    $self->callApi($method, @_);
}

# $client->callApi(FUNC, ARG, ..., [CALLBACK]);
# sub { my $result = shift; ... }
sub callApi
{
    my $self = shift;
    my $callback = ref $_[-1] eq 'CODE' ? pop : undef;
    my @args = @_;
    if ($callback) {
        $self->app->apiCaller->callSeq
            (\@args,
             sub
             {
                 my ($ua, $tx) = @_;
                 if ($tx->success) {
                     my $json = $tx->res->json;
                     my $status = $json->{seq}[0] =~ s/\r\n/\n/gr;
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
        my $json = $tx->res->json;
        my $status = $json->{seq}[0];
        return $status;
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

sub procFriendList
{
    my $self = shift;
    my $text = utf8df shift;
    use Data::Dumper;
    print term 'text='. Dumper $text;
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
                // Scripts::Windy::Web::Model::Friend->new(tencent => $_->{uin});
            $friend->category($catName);
            $friend->name($_->{name});
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
            my $group = $self->findGroup(number => $_->{gn})
                // Scripts::Windy::Web::Model::Group->new(number => $_->{gn});
            $group->name($_->{gc});
            $group->ownerTencent($_->{owner});
            $group->myRelationship($type);
            push @groups, $group;
        }
    }
    # replace old list
    $self->groups(\@groups);
    $self->groups;
}

my %groupRole = (0 => "founder", 1 => "admin", 2 => "member");
my %groupRoleNum = map {; $groupRole{$_} => $_ } keys %groupRole;

sub procGroupInfo # GetGroupMemberA
{
    my ($self, $group, $text) = @_;
    $text = utf8df $text;
    my $json = decode_json $text;
    return if $json->{ec} != 0;
    # count info
    $group->adminMax($json->{adm_max});
    $group->memberMax($json->{max_count});
    $group->levelName($json->{levelname});
    # add members
    my @members = ();
    for (@{$json->{mems}}) {
        my $member = $group->findMember(tencent => $_->{uin})
            // Scripts::Windy::Web::Model::GroupMember->new(tencent => $_->{uin});
        $member->card($_->{card});
        $member->role($groupRole{ $_->{role} });
        $member->name($_->{nick});
        $member->joinTime($_->{join_time});
        $member->lastSpeakTime($_->{last_speak_time});
        $member->level($_->{lv}{level});
        $member->point($_->{lv}{point});
        push @members, $member;
    }
    # replace
    $group->members(\@members);
    $group;
}

sub new
{
    my $class = shift;
    my $self = $class->Mojo::EventEmitter::new(@_);
    $self->on
        (loggedIn => sub
         {
             my $tencent = $self->GetQQlist;
             $self->me(Scripts::Windy::Web::Model::User->new(tencent => $tencent));
             say "logged in! getting friend list...";
             $self->isLoggedIn(1);
             my $r = $self->procFriendList($self->GetFriendList($tencent));
             if ($r) {
                 say "done!";
                 use Data::Dumper;
                 print term Dumper($self->friends);
                 for (@{$self->friends}) {
                     say term 'name: '.$_->name."\n"
                         .'uid: '.$_->tencent."\n"
                         .'cat: '.$_->category;
                 }
             } else {
                 say "error!";
             }
         });
    $self->on
        (loggedOut => sub
         {
             $self->isLoggedIn(0);
         });
    #say "getting friend list...";
    ##(sub { $self->procFriendList(@_); });
    #say "done!";
    #use Data::Dumper;
    #print Dumper($self->friends);
    $self;
}

1;
