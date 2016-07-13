#!/usr/bin/env perl

use 5.012;
use Scripts::scriptFunctions;
use Mojo::Webqq;
use Mojo::Util qw/md5_sum/;
use Scripts::Windy;
use Time::HiRes qw/time/;

my $file = $accountDir.'windy';
my $uid;
if (open my $w, '<', $file) {
    chomp ($uid = <$w>);
    close $w;
} else {
    die term "打不开文件 $file: $!\n";
}
my $mailAccount = {};
if (open my $f, '<', $accountDir.'windy-mail') {
    while (<$f>) {
        chomp;
        if (/^(.+?)=(.+)$/) {
            $mailAccount->{$1} = $2;
        }
    }
    close $f;
} else {
    warn term "打不开mail文件: $!\n";
}

my $windy = Scripts::Windy->new;
my $t = Mojo::Webqq->new(
    qq => $uid,
    login_type => 'qrlogin',
#    is_init_friend => 0,
#    is_init_group => 0,
#    is_init_discuss => 0,
#    is_init_recent => 0,
#    is_update_user => 0,
#    is_update_group => 0,
#    is_update_friend => 0,
#    is_update_discuss => 0,
    );
$t->login;
sub onReceive
{
    my ($c, $m) = @_;
    my $text = $m->content;
    say term "Receiving `".$text."`";
    my $time = time;
    my $resp = $windy->parse($m);
    if ($resp) {
        say term "Replying `".$resp."`, in ".( time - $time )."secs.";
        $m->reply($resp);
    }
}
#$t->load("PostQRcode",data => $mailAccount ) if %$mailAccount;
$t->on(receive_message => \&onReceive);
$t->run;
