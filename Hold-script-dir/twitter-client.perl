#!/usr/bin/env perl

use 5.012;
use Net::Twitter;
use Scripts::scriptFunctions;
#use Data::Dumper;
use Scalar::Util qw/blessed/;
use Gtk2 qw/-init/;
use Gtk2::WebKit;
use encoding 'utf8';
binmode STDOUT, ":utf8";
use threads ('yield',
             'stack_size' => 64*4096,
             'exit' => 'threads_only',
             'stringify');

my $accountFile = "${accountDir}twitter";
my $debug = 0;

my @data;
open (AF, '<', $accountFile) or die "Cannot open file `$accountFile': $!\n";
while (<AF>)
{
    chomp;
    (/^#/ or /^\s*$/) and next;
    push @data, $_;
}
close AF;
my ($key, $secret, $token, $tokenSecret) = @data;

my $twitter = Net::Twitter->new (
    traits => [qw/OAuth API::REST InflateObjects/],
    consumer_key => $key,
    consumer_secret => $secret,
);

$twitter->ua->proxy ([qw/http https/] => 'socks://127.0.0.1:7070/');

if ($token && $tokenSecret)
{
    $twitter->access_token ($token);
    $twitter->access_token_secret ($tokenSecret);
}

unless ( $twitter->authorized )
{
    say "Authorize this app at ", $twitter->get_authorization_url, " and enter the PIN#"; say "43th line";
    chomp (my $pin = <STDIN>);
    ($token, $tokenSecret) = $twitter->request_access_token (verifier => $pin);
    $twitter->access_token ($token);
    $twitter->access_token_secret ($tokenSecret);
    # save tokens
    open (AF, '>>', $accountFile) or die "Cannot open account file: $!\n";
    say AF $token;
    say AF $tokenSecret;
    close AF;
}
undef $token, $tokenSecret;
sub getNewTweets
{
    eval
    {
        my $statuses = $twitter->friends_timeline({ count => 20 });
        for my $status ( @$statuses )
        {
            say $status->relative_created_at . " \e[1;32m\@$status->{user}{screen_name} said:\e[0m $status->{text}";
        }
    };
    if ( my $err = $@ )
    {
        die $@ unless blessed $err && $err->isa('Net::Twitter::Error');

        warn "HTTP Response Code: ", $err->code, "\n",
        "HTTP Message......: ", $err->message, "\n",
        "Twitter error.....: ", $err->error, "\n";
    }
}
my $htmlFile = "${cacheDir}twitter.html";
my $threadGetTweets = threads->create(sub { while (1) { getNewTweets;sleep 600; } });
$threadGetTweets->join;
my $window = Gtk2::Window->new;
my $webkit = Gtk2::WebKit::WebView->new;
$window->add ($webkit);
$webkit->set_custom_encoding ('utf-8');
$webkit->open ($htmlFile);
$window->resize (200, 400);
$window->signal_connect (destroy => sub { Gtk2->main_quit });

$window->show_all;

Gtk2->main;


