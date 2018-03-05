#!/usr/bin/env perl

BEGIN
{
    $ENV{WINDY_BACKEND} = 'mpq';
}
use Scripts::Base;
use Mojolicious::Commands;

if (!@ARGV) { # provide default args
    @ARGV = ('daemon', '-l', 'http://*:7457');
    say term '如果在 MPQ 登陆之后才开始运行，在浏览器中访问 http://127.0.0.1:7457/confirm';
    say term 'v看到 Server available 的字样就可以登陆了v';
}

Mojolicious::Commands->start_app('Scripts::Windy::Web');
__END__
use 5.012;
use Scripts::scriptFunctions;
use Scripts::Windy::Startup;
use Time::HiRes qw/time/;
use Scripts::Windy::Util;
no warnings 'experimental';
use Mojo::JSON qw/decode_json from_json/;
use Encode qw/encode decode _utf8_on _utf8_off/;
use utf8;
use MIME::Base64;
use Scripts::Windy::Constants;
use Scripts::Windy::Event;
use Mojolicious::Lite;

sub parseEvent
{
    my ($event) = @_;
    my $time = time;
    my $ret;
    parseRichText($windy, $event);
    $windy->logger("收到".msgText($windy, $event));
    my $resp = $windy->parse($event);
    if ($resp) {
        $windy->logger("送出 `$resp` 在 ". (time - $time)." 秒内");
        replyToMsg($windy, $event, $resp);
        if (not $event->isMessage) {
            my $r = $event->{retValue};
            if ($r eq int $r) {
                $ret = $r;
            } elsif (defined $EventRet{$r}) {
                $ret = $EventRet{$r};
            } else {
                $ret = $EventRet{pass};
            }
        } else {
            $ret = $EventRet{done};
        }
    } else {
        #$windy->logger("没送出什么。");
    }
    $ret;
}

get '/client' => sub {
    
};

post '/' => sub {
    my $c = shift;
    my $orig = utf8 $c->req->text;
    say $orig;
    #_utf8_off($orig);
    my $hash = from_json($orig); # it is not utf8
  use Data::Dumper;
    print term Dumper($hash);
    say term decode_base64($hash->{Content});
  #my $event = Scripts::Windy::Event->new(map $hash->{$_}, qw/tencent type subtype source subject object msg rawmsg/);
  my $ret = { Ret => 0, Msg => '', #- -parseEvent($event)
  };
  $c->render(json => $ret);
};

get '/' => sub {
  my $c = shift;
  $c->render(text => '');
};

app->start;

