package Scripts::Windy::Web;

use Scripts::Base;
use Mojo::Base 'Mojolicious';
#use Scripts::Windy;
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
    my $retJson = { ret => 0, msg => '', };
    # Dump it
    use Data::Dumper;
    print Dumper($event);
    # login/logout/...
    if ($event->type == 11001) {
        #$self->emit(loggedIn => $event->subject);
    } elsif ($event->type == 11002
             or $event->type == 11003
             or $event->type == 11004) {
        $self->emit(loggedOut => $event->subject, $event->type);
        # stop here
        $callback->($retJson) if ref $callback eq 'CODE';
        return;
    }
    #my $windy = $self->windy;
    #my $text = parseRichText($windy, $event);
    #my ($context) = $event->type =~ /^(group|discuss)_message$/;
    #$windy->logger("收到 `$text` 从".msgSender($windy, $event));

    my $time = time;
    # 真正的处理
    #my $r = $windy->parse($event);
    #my $resp = $r->{Text};
    #if (length $resp) {
    #    my $num = $r->{Num};
    #    $windy->logger("送出第 ${num} 条 `".$resp."`, 在 ".( time - $time )." 秒内");
        #my $to = recordLast($event, $context);
        #sendTo($to, $resp);
    #    $retJson->{ret} = 1;
    #}
    #$self->emit(recvEvent => $event);
    # 处理完了调用 callback 传回去
    $callback->($retJson) if ref $callback eq 'CODE';   
}

sub startup
{
    my $self = shift;
    # for (TODO) web-based client
    my $renderer = $self->renderer;
    $renderer->paths([$dataDir.'windy']);
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
    $self->client->on(recvEvent => \&onReceive);
    #$self->helper(windy => sub { state $windy = Scripts::Windy->new; });
    #$self->helper(ua => sub { state $ua = Mojo::UserAgent->new; });
}

1;
