package Scripts::Windy::Web;

use Mojo::Base 'Mojolicious';
use Scripts::Base;
use Scripts::Windy::Startup;
use Time::HiRes qw/time/;

use Scripts::Windy::Web::Controller::Receiver;
use Scripts::Windy::Web::Controller::Sender;
use Scripts::Windy::Web::ApiCaller;
use Scripts::Windy::Web::Client;
use Scripts::Windy::Util;
use Mojo::Util qw/xml_escape/;

sub onReceive
{
    my ($self, $event, $callback) = @_;
    # self here is client
    my $retJson = { ret => 0, msg => '', };
    # login/logout/...
    if ($event->type == 11001) {
        $self->emit(loggedIn => $event->subject);
    } elsif ($event->type == 11002
             or $event->type == 11003
             or $event->type == 11004) {
        $self->emit(loggedOut => $event->subject, $event->type);
        # stop here
        $callback->($retJson) if ref $callback eq 'CODE';
        return;
    }
    #my $windy = $self->windy;
    my $text = parseRichText($windy, $event);
    my ($context) = $event->typeName =~ /^(group|discuss)-message$/;
    my $inGroup = ($context
                   ? " 在 "
                   .($context eq 'group'
                     ? msgGroupName($windy, $event)
                     .'('.msgGroupId($windy, $event).')'
                     : msgDiscussName($windy, $event))
                   : '');
    $windy->logger("收到 `$text` 从 "
                   .uName(msgSender($windy, $event))
                   .'('.uid(msgSender($windy, $event)).')'
                   .$inGroup);

    my $time = time;
    # 真正的处理
    my $r = $windy->parse($event);
    my $resp = $r->{Text};
    if (length $resp) {
        my $num = $r->{Num};
        $windy->logger("送出第 ${num} 条 `".$resp."`, 在 ".( time - $time )." 秒内");
        my $to = recordLast($event, $context);
        sendTo($to, $resp);
        $retJson->{ret} = 1;
    }
    #$self->emit(recvEvent => $event);
    # 处理完了调用 callback 传回去
    $callback->($retJson) if ref $callback eq 'CODE';   
}

# last channel
my $lastChannelFile = $configDir."windy-conf/last-channel";
my $lastChannel = [];
sub loadLast
{
    my $client = shift;
    if (open my $f, '<', $lastChannelFile) {
        chomp (my $line = <$f>);
        my ($context, $lastid) = $line =~ /^([DP]?)(\d+)$/;
        my $channel = undef;
        given ($context) {
            $channel = $client->findDiscuss(id => $lastid) when 'D';
            $channel = $client->findFriend(tencent => $lastid) when 'P';
            $channel = $client->findGroup(number => $lastid) when '';
        }
        close $f;
        $windy->logger("上一次的channel是: ".$line);
        $lastChannel = [$channel, $context];
        $channel;
    } else {
        undef;
    }
}

sub recordLast
{
    my ($last, $context) = @_;
    given ($context) {
        $lastChannel = [$last->sourcePlace, ''] when 'group';
        $lastChannel = [$last->sourcePlace, 'D'] when 'discuss';
        $lastChannel = [$last->subjectUser, 'P'] when undef;
        default { $windy->logger("不能记下现在的channel。"); }
    };
    $lastChannel->[0];
}

sub saveLast
{
    if ($lastChannel and open my $f, '>', $lastChannelFile) {
        binmode $f, ':unix';
        my $id;
        given ($lastChannel->[1]) {
            $id = $lastChannel->[0]->id when 'D';
            $id = $lastChannel->[0]->tencent when 'P';
            $id = $lastChannel->[0]->number when '';
        }
        $windy->logger("记下现在的channel是 ".$id."(".$lastChannel->[1].")");
        say $f $lastChannel->[1].$id;
        close $f;
    }
}

# admin correspond with main group
my $mainGroup = undef;
sub loadMainGroup
{
    my $t = shift;
    if ($mainGroupId) {
        $mainGroup = $t->findGroup(number => $mainGroupId)
            // $t->newGroup(number => $mainGroupId);
    }
    $windy->{mainGroup} = $mainGroup;
}
sub loadAdmins
{
    my $client = shift;
    $windy->{Admin} = [];
    if ($client->loadMainGroup) {
        $windy->{Admin} = $mainGroup->adminList;
        $windy->logger("管理列表: ".(join ',', @{$windy->{Admin}}));
    }
}
####
sub updateAdmin
{
    my (undef,$member,$property,$old,$new) = @_;
    return if $member->group->gnumber ne $mainGroupId or $property ne 'role';
    if ($new eq 'admin' or $new eq 'owner') { # 成为管理就添加
        $windy->logger("添加管理: ". $member->qq);
        push @{$windy->{Admin}}, $member->qq;
    } elsif (($old eq 'admin' or $old eq 'owner') and $new eq 'member') { # 撤销管理就删去
        $windy->logger("撤销管理: ". $member->qq);
        @{$windy->{Admin}} = grep { $member->qq ne $_ } @{$windy->{Admin}};
    }
}


sub startup
{
    my $self = shift;
    # for (TODO) web-based client
    my $renderer = $self->renderer;
    $renderer->paths([$dataDir.'windy']);
    $self->log->level('info');
    # routes
    my $route = $self->routes;
    $route->any
        ('/term' => sub
         {
             my $c = shift;
             my $val = $c->param('list') =~ s/\r\n/\n/gr;
             my @args = grep { length $_ } split /\n/, $val;
             my $text = <<EOF;
                        <form action="/term" method="post">
                        <p>Send API:</p>
                        <textarea name="list">$val</textarea>
                        <br />
                        <input type="submit" value="Call!" />
                        </form>
EOF
             if (@args) {
                 $c->render_later;
                 $c->app->client->callApi
                     (@args, sub
                      {
                          my $result = shift;
                          use Data::Dumper;
                          $c->render
                              (text => $text
                               . '<p>Result: <pre>' . (xml_escape $result) . '</pre></p>'
                               . '<p>Raw:<pre>' . (xml_escape Dumper $result) . '</pre></p>');
                      });
             } else {
                 $c->render(text => $text);
             }
         });
    $route->any('/' => sub
                {
                    my $c = shift;
                    $c->render(text => 'It works!');
                });
    $route->any('/recv')->to('receiver#index');
    $route->any('/api')->to('sender#index');
    $route->any('/confirm' => sub
                {
                    my $c = shift;
                    $self->client->emit('loggedIn');
                    $c->render(text => '');
                });
    $self->helper(apiCaller =>
                  sub
                  {
                      state $ac = Scripts::Windy::Web::ApiCaller->new(ua => $self->ua);
                  });
    
    $self->helper(client =>
                  sub
                  {
                      state $c = Scripts::Windy::Web::Client->new(app => $self);
                  });
    # process event
    $self->client->once
        (recvEvent => sub {
            if (not defined $self->me) {
                my $tencent = $self->GetQQlist;
                $self->me(Scripts::Windy::Web::Model::User->new
                          (tencent => $tencent,
                           client => $self));
            }
         });
    $self->client->once(recvEvent => \&loadAdmins);
    $self->client->on(recvEvent => \&onReceive);
    $self->helper(windy => sub { $windy; });
    #$self->helper(ua => sub { state $ua = Mojo::UserAgent->new; });
}

1;
