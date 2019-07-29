#!/usr/bin/env perl

use 5.014;
use Net::IRC;

my $cnick = 'tusoob';
my $cserver = 'chat.freenode.net';
my $cport = 8001;
my $cname = 'a bot written by Tusooa';
my $password = shift @ARGV;

my @rooms = qw/#tusooa/;
my $irc = Net::IRC->new();
my $connect = $irc->newconn(
    Nick => $cnick,
    Server => $cserver,
    Port => int ($cport),
    Username => $cnick,
    Ircname => $cname,
    );

my $oldDate = '';
my $logf;

sub time2date
{
    my @t = @_ ? @_ : localtime;
    my $year = $t[5] + 1900;
    my $month = $t[4] + 1;
    my $day = $t[3];
    "${year}-${month}-${day}";
}

sub checkReopenLogFile
{
    my $today = time2date;
    if ($oldDate ne $today) {
        my $oldlog = $logf;
        open $logf, '>>', 'irc-log-' . $today;
        binmode $logf, ':unix';
        close $oldlog if $oldlog;
    }
}

checkReopenLogFile;

sub isTusooa { shift eq 'tusooa' }
# Irc 设置
sub onConnect
{
    my $connect = shift;
    sleep 1;
    for (@rooms) {
        $connect->join($_);
    }
    say 'Ready.';
}

sub onCommand
{
    my ($connect, $word, $dest, $pre, $nick) = @_;
    my @words = @$word;
    #say "on command: $cmd\targs: @words";
    my $cmd = shift @words;
    if (isTusooa $nick)
    {
        given ($cmd)
        {
            when ('--restart') { exec $0 }
            when ('--quit') { exit }
            when ('--privmsg')
            {
                my $to = shift @words;
                $connect->privmsg ($to, (join ' ', @words));
            }
            when ('--join') {
                $connect->join ($words[0]);
            }
            when ('--leave') {
                $connect->part ($words[0]);
            }
        }
    }
}

sub onTalk
{
    #my ($word, $dest, $pre, $nick) = @_;
    #my @words = @$word;
    #my $arg = join ' ', @words;
}

sub onMsg
{
    my ($connect, $event) = @_;
    my @to = $event->to;
    my ($nick , $mynick) = ($event->nick, $connect->nick);
    my $host = $event->host;
    my ($arg) = ($event->args);
    my $room = $event->{to}[0];
    #say $arg;
    my @words = split /\s+/, $arg;
}

sub onPublic
{
    #say 'on-public';
    my ($connect, $event) = @_;
    my @to = $event->to;
    my ($nick , $mynick) = ($event->nick, $connect->nick);
    my $host = $event->host;
    my ($arg) = ($event->args);
    my $room = $event->{to}[0];
    my @words = split /\s+/, $arg;

    say $logf "$room: $nick: $arg";
}


$connect->add_global_handler(376, \&onConnect);
$connect->add_handler('public', \&onPublic);
$connect->add_handler('msg', \&onMsg);
$connect->privmsg ('NickServ', "IDENTIFY tusooa $password\n");

$irc->start;

