=encoding utf8
=cut
=head1 NAME
    Scripts::Windy::Web::Model::Event

=cut
package Scripts::Windy::Web::Model::Event;

use Mojo::Base 'Scripts::Windy::Web::Model::Base';
use Scripts::Base;
use Scripts::Windy::Web::Model::Friend;
use Scripts::Windy::Web::Model::Group;
use Scripts::Windy::Web::Model::GroupMember;

has [qw/tencent
     type typeName
     subtype subtypeName
     source sourcePlace
     subject subjectUser
     object objectUser
     msg
     rawmsg
     client/];

my %Codes = (
    1 => 'friend-message',
    2 => 'group-message',
    3 => 'discuss-message',
    4 => 'group-sess-message',
    # MPQ documentation does not have this type,
    # this is from test results
    5 => 'discuss-sess-message',
    
    1000 => 'add-friend-oneway',
    1001 => 'add-friend',
    1002 => 'friend-state-change',
    1003 => 'del-friend',
    1004 => 'sign-change',
    1005 => 'friend-comment',
    1006 => 'friend-inputing',
    1007 => 'friend-open-dialog',
    1008 => 'friend-shake',
    
    2001 => 'join-group-request',
    2002 => 'join-group-invite',
    2003 => 'invited-group',
    2005 => 'joined-group',
    2006 => 'quit-group',
    2007 => 'kick-group',
    2008 => 'dismiss-group',
    2009 => 'become-admin',
    2010 => 'cancel-admin',
    2011 => 'group-card-change',
    2012 => 'group-name-change',
    2013 => 'group-notice-change',
    2014 => 'quiet-group',
    2015 => 'quiet-lifted',
    2016 => 'all-quiet',
    2017 => 'all-quiet-lifted',
    2018 => 'anon-enabled',
    2019 => 'anon-disabled',

    10000 => 'loaded',
    10001 => 'restarting',

    11000 => 'add-account',
    11001 => 'logged-in',
    11002 => 'manual-logoff',
    11003 => 'forced-logoff',
    11004 => 'idle-logoff',
);
=head1 METHODS
=cut
=head2 new
    $event = Scripts::Windy::Web::Model::Event->new(
        tencent => "", type => 0, subtype => 0, source => "",
        subject => "", object => "", msg => "", rawmsg => "",
    )

Creates an Event object from the hash.
=cut
sub new
{
    my $class = shift;
    my $self = $class->Scripts::Windy::Web::Model::Base::new(@_);
    $self->typeName($Codes{$self->type});
    if ($self->isAboutGroup) {
        my $group = $self->client->findGroup(number => $self->source)
            // $self->client->newGroup(number => $self->source);
        $self->sourcePlace($group);
        my $subject = length $self->subject
            ? ($group->findMember(tencent => $self->subject)
               // $group->newMember(tencent => $self->subject))
            : undef;
        my $object = length $self->object
            ? ($group->findMember(tencent => $self->object)
               // $group->newMember(tencent => $self->subject))
            : undef;
        $self->subjectUser($subject);
        $self->objectUser($object);
    } elsif ($self->isAboutFriend) {
        if ($self->typeName eq 'add-friend'
            or $self->typeName eq 'add-friend-oneway') {
            # we do not have the friend yet
        } else {
            my $subject = $self->client->findFriend
                (tencent => $self->subject)
                // $self->client->newFriend(tencent => $self->subject);
            $self->subjectUser($subject);
            $self->objectUser($self->client->me);
        }
    } elsif ($self->isAboutDiscuss) {
        # MPQ does not have the discuss name for us
        my $discuss = $self->client->findDiscuss(id => $self->source)
            // $self->client->newDiscuss(id => $self->source);
        $self->sourcePlace($discuss);
        my $subject = $discuss->findMember(tencent => $self->subject)
            // $discuss->newMember(tencent => $self->subject);
        my $object = $discuss->findMember(tencent => $self->object)
            // $discuss->newMember(tencent => $self->object);
        $self->subjectUser($subject);
        $self->objectUser($object);
    } else {
        $self->subjectUser(Scripts::Windy::Web::Model::User->new
                           (tencent => $self->subject));
        $self->objectUser(Scripts::Windy::Web::Model::User->new
                          (tencent => $self->object));
    }
    $self;
}

sub isMessage
{
    my $self = shift;
    $self->type >= 1 and $self->type <= 5;
}

sub isAboutFriend
{
    my $self = shift;
    $self->typeName eq 'friend-message'
        # 1k - 2k = friend-related
        or ($self->type >= 1000
            and $self->type < 2000);
}

sub isAboutGroup
{
    my $self = shift;
    $self->typeName eq 'group-message'
        or $self->typeName eq 'group-sess-message'
        # 2k to 3k = group-related
        or ($self->type >= 2000
            and $self->type < 3000);
}

sub isAboutDiscuss
{
    my $self = shift;
    $self->typeName eq 'discuss-message'
        or $self->typeName eq 'discuss-sess-message';
    # seems MPQ does not have events for discusses
}

sub reply
{
    my ($self, $text) = shift;
    $self->subject->send($text);
}


1;
