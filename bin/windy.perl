#!/usr/bin/env perl

use 5.012;
use Scripts::scriptFunctions;
use Mojo::Webqq;
use Mojo::Util qw(md5_sum);
use Scripts::Windy;

my $file = $accountDir.'windy';
my %acc;
{
    open my $w, '<', $file or die term "打不开文件 $file: $!\n";
    chomp ($acc{uid} = <$w>);
}
my $windy = Scripts::Windy->new;
my $t = Mojo::Webqq->new(qq => $acc{uid}, login_type => 'qrlogin');
$t->login;
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
