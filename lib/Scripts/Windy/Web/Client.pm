package Scripts::Windy::Web::Client;

use Scripts::Base;
use Mojo::Base 'Mojo::EventEmitter';
use Scripts::Windy::Web::Model::User;
use Scripts::Windy::Web::Model::Friend;
use Mojo::JSON qw/decode_json/;

has [qw/app me isLoggedIn/];
has friends => sub { []; };

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

sub procFriendList
{
    my $self = shift;
    my $text = utf8df shift;
    use Data::Dumper;
    print term 'text='. Dumper $text;
    my $json = decode_json $text;
    return if $json->{ec} != 0; # which means it failed
    @{$self->friends} = ();
    my $res = $json->{result};
    for my $cat (values %$res) { # since we do not care about the cat num.
        my $catName = $cat->{gname} // '我的好友';
        exists $cat->{mems} or next;
        for (@{$cat->{mems}}) {
            my $friend = Scripts::Windy::Web::Model::Friend->new(
                category => $catName,
                tencent => $_->{uin},
                name => $_->{name},
                );
            push @{$self->friends}, $friend;
        }
    }
    $self->friends;
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
