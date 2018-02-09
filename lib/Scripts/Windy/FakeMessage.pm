package Scripts::Windy::FakeMessage;
use 5.012;
no warnings 'experimental';
my %types = qw/D discuss_message P friend_message/, '', 'group_message';
sub loginMsg
{
    my $class = shift;
    my $self = {@_};
    bless $self, $class;
    my $lastChannel = $self->{_context};
    given ($lastChannel->[1]) {
        $self->{discuss} = $lastChannel->[0] when 'D';
        $self->{sender} = $lastChannel->[0] when 'P';
        $self->{group} = $lastChannel->[0] when '';
    }
    $self->{type} = $types{$lastChannel->[1]};
    my $oldSender = $self->{sender};
    
    $self->{sender} = Scripts::Windy::FakeSender->null;
    if ($oldSender) {$self->{sender}->{qq} = $oldSender;}
    $self;
}

sub discuss : lvalue { shift->{discuss}; }
sub sender : lvalue { shift->{sender}; }
sub group : lvalue { shift->{group}; }
sub receiver : lvalue { shift->{receiver}; }
sub type : lvalue { shift->{type}; }
1;

package Scripts::Windy::FakeSender;
use 5.012;

sub null
{
    my $class = shift;
    my $self = { displayname => '', role => '', qq => '0' };
    bless $self, $class;
}

sub displayname : lvalue { shift->{displayname}; }
sub role : lvalue { shift->{role}; }
sub qq : lvalue { shift->{qq}; }

1;
