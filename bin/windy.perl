#!/usr/bin/env perl

use 5.012;
use Scripts::scriptFunctions;
use Mojo::Webqq;
use Mojo::Util qw(md5_sum);
use Scripts::Windy;

my $file = $accountDir.'windy';
my %acc;
{
    open my $w, '<', $file or die term "无法获取账号信息$file: $!\n";
    chomp ($acc{uid} = <$w>);
    chomp ($acc{pass} = <$w>);
    $acc{pass} = md5_sum($acc{pass});
}
my $t = Mojo::Webqq->new(qq => $acc{uid}, pwd => $acc{pass}, login_type => 'qrlogin');
$t->login;
my $windy = Scripts::Windy->new;
sub onReceive
{
    my ($c, $m) = @_;
    my $text = $m->content;
    say term "Receiving `".$text."`";
    my $resp = $windy->parse($m);
    if ($resp) {
        say term "Replying `".$resp."`";
        $m->reply($resp);
    }
}
$t->on(receive_message => \&onReceive);
$t->run;
