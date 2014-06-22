#!/usr/bin/env perl

use 5.012;
use WWW::Mechanize::Firefox;
#use POSIX qw/strftime/;
#use utf8;
#use Encode qw/_utf8_on _utf8_off/;
use Scripts::scriptFunctions;
my $m;
eval { $m = WWW::Mechanize::Firefox->new };
if ($@) {
    say term 'Firefox is not started, starting now...';
    system 'firefox -repl & sleep 2';
    $m = WWW::Mechanize::Firefox->new;
}

#system '';
$m->get ('http://baozou.com/login');
if ($m->uri eq 'http://baozou.com/login') {
    say term "正在登录...";
    my $button = $m->xpath ('//button', one => 1);
    $m->click ($button);
    $m->content;
    final;
} else {
    say term "已经登录过了";
}
