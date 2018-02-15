package Scripts::Windy::Web::Controller::Receiver;

use Scripts::Base;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw/from_json/;

use Scripts::Windy::Web::Model::Event;

sub index {
    my $self = shift;
    my $json = $self->req->json;
    # 获取消息内容
    my $event = Scripts::Windy::Web::Model::Event->new($json);
    
    # 加入队列
    # 先 Dump 出来
    use Data::Dumper;
    print term Dumper($event);
    # 先都返回 0
    $self->render(json => { ret => 0, msg => '' });
}

1;
