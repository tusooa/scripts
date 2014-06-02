#!/usr/bin/env perl

use 5.012;
use WWW::Mechanize::Firefox;
use POSIX qw/strftime/;
#use utf8;
use Encode qw/_utf8_on _utf8_off/;
my $m;
eval { $m = WWW::Mechanize::Firefox->new };
if ($@) {
    say 'Firefox is not started, starting now...';
    system 'firefox -repl & sleep 2';
    $m = WWW::Mechanize::Firefox->new;
}

#system '';
$m->get ('http://baozou.com/login');
if ($m->uri eq 'http://baozou.com/login') {
    say "正在登录...";
    eval {
        my $button = $m->xpath ('//button', one => 1);
        $button->click;
    };
    say "完成!开始我们的战争(Date)吧---";
} else {
    say "已经登录过了";
}
