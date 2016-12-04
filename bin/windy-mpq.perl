#!/usr/bin/env perl

BEGIN
{
    $ENV{WINDY_BACKEND} = 'mpq';
}
use 5.012;
use Scripts::scriptFunctions;
use Scripts::Windy::Startup;
use Time::HiRes qw/time/;
use Scripts::Windy::Util;
no warnings 'experimental';
use Mojo::JSON qw/decode_json from_json/;
use Encode qw/encode decode _utf8_on _utf8_off/;
use utf8;
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

post '/recv' => sub {
    my $c    = shift;
    my $orig = utf8 $c->req->text;
    say $orig;
    #_utf8_off($orig);
    my $hash = from_json($orig); # it is not utf8
  use Data::Dumper;
  print Dumper($hash);
  my $event = Scripts::Windy::Event->new(map $hash->{$_}, qw/tencent type subtype source subject object msg rawmsg/);
  my $ret = { ret => - -parseEvent($event)};
  $c->render(json => $ret);
};

get '/' => sub {
  my $c = shift;
  $c->render(text => '');
};

app->start;

