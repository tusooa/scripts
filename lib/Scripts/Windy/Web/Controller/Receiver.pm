package Scripts::Windy::Web::Controller::Receiver;

use Scripts::Base;
use Mojo::Base 'Mojolicious::Controller';

use Scripts::Windy::Web::Model::Event;

sub index
{
    my $self = shift;
    my $json = $self->req->json;
    $self->render_later;
    # 获取消息内容
    my $event = Scripts::Windy::Web::Model::Event->new(%$json);
    # 发出信号
    $self->client->emit(
        recvEvent => $event,
        sub
        {
            my $json = shift;
            $self->render(json => $json);
        });
}

1;
