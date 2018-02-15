package Scripts::Windy::Web;

use Scripts::Base;
use Mojo::Base 'Mojolicious';

use Scripts::Windy::Web::Controller::Receiver;
use Scripts::Windy::Web::Controller::Sender;

sub startup
{
    my $self = shift;
    my $renderer = $self->renderer;
    $renderer->paths([$dataDir."windy"]);
    my $route = $self->routes;
    $route->any('/' => sub
                {
                    my $c = shift;
                    $c->render(text => 'It works!');
                });
    $route->any('/recv')->to('receiver#index');
    $route->any('/api')->to('sender#index');
    #$self->helper(ua => sub { state $ua = Mojo::UserAgent->new; });
}

1;
