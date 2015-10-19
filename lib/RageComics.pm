#!/usr/bin/env perl

package Scripts::RageComics;
use 5.012;
use Scripts::scriptFunctions;
use WWW::Mechanize::Firefox;
our @ISA = qw/WWW::Mechanize::Firefox/;

sub new {
    my $class = shift;
    my $m;
    eval { $m = WWW::Mechanize::Firefox->new };
    if ($@) {
        say term 'Firefox is not started, starting now...';
        if ($^O eq 'Win32') { system 'firefox -repl &'; }
        else { system 'firefox -repl'; }
        sleep 2;
        $m = WWW::Mechanize::Firefox->new;
    }
    bless $m, $class;
}

sub login {
    my $m = shift;
    $m->get ('http://baozou.com/login');
    $m->success or return undef;
    if ($m->uri eq 'http://baozou.com/login') {
        open my $acc, '<', "${accountDir}rage-comics";
        my ($username, $password);
        chomp (($username, $password) = <$acc>);

        $m->field (login => $username) if $username;
        $m->field (password => $password) if $password;
        my $button = $m->xpath ('//button', one => 1);
        $m->click ($button);
        $m->content;
        1;
    } else {
        2;
    }
}

sub comment {
    my $m = shift;
    my %args = @_;
    if ($args{id}) {
        $m->get ('http://baozou.com/articles/'.$args{id});
        $m->success or return undef;
        my $button = $m->by_id('c-'.$args{id});
        print $button;
        $m->click ($button);
        print $m->selector('form.login');#$m->field ();
    }
}
1;
