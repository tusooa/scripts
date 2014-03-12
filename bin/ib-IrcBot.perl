#!/usr/bin/env perl

use lib '/usr/lib/perl5/site_perl/current';
use 5.014;
use Net::IRC;
use LWP::UserAgent;
#use utf8;
#use encoding 'utf8';
#binmode STDOUT, 'utf-8';
use Encode qw/encode_utf8 decode_utf8/;
use HTML::Entities;
use Scripts::scriptFunctions;
use Scripts::IRC qw/$ircPassword/;
use String::CRC32;
#use URI::Title qw/title/;

my $cnick = 'ib-perl';
my $cserver = 'chat.freenode.net';
my $cport = 8001;
my $cname = 'a bot written by Tusooa';

my @rooms = qw/#tusooa/;
my @titleOn = qw/#tusooa/;#在这个array里,才显标题.
my @msgToChannel = qw/#tusooa/;
my $irc = new Net::IRC;
my $connect = $irc->newconn (
    Nick => $cnick,
    Server => $cserver,
    Port => int ($cport),
    Username => 'ib-perl',
    Ircname => $cname,
);

sub isTusooa { shift eq 'tusooa' }
# Irc 设置
sub onConnect
{
    my $connect = shift;
    say "登录...";
    $connect->privmsg ('ChanServ', 'op #tusooa');
    sleep 1;
    for (@rooms)
    {
        say "正在进入 $_...";
        $connect->join ($_);
        say "Done.";
    }
}

=none
@botFunc = (
    ['help', 'echo', $help],
    ['-h', 'echo', $help],
    ['-w', "${Scripts}wg-天气.perl"],
    ['-p', "${Scripts}pkgquery.bash"],
    ['-i', "${Scripts}ci-Ip查询.perl"],
    #['-t', "${Scripts}st-话题建议.bash"],
    #['-g', ''],
);
=cut
sub getHtmlTitle
{
    state $ua = LWP::UserAgent->new (max_size => 1024, agent => 'Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.2.9) Gecko/20100917 Gentoo Firefox/3.6.9');
    my $resp = $ua->get (shift);
    my $content = $resp->decoded_content;
    $content =~ m{<title[^>]*>(.*?)</title}is;
    decode_utf8 decode_entities $1;
}

sub onCommand
{
    my ($connect, $word, $dest, $pre, $nick) = @_;
    my @words = @$word;
    #say "on command: $cmd\targs: @words";
    my $cmd = shift @words;
    given ($cmd)
    {
        when ($_ eq '-h' or $_ eq '--help')
        {
            $connect->privmsg ($dest, "${pre}-h,--help 帮助  -r,--rp,--jrrp 测人品\n");
        }
        when ($_ eq '-r' or $_ eq '--rp' or $_ eq '--jrrp')
        {
            my $testNick = $words[0] ? $words[0] : $nick;
            say "testNick: ".$testNick;
            my @t = localtime time;
            my $str = ($t[5]+1900).($t[4]+1).$t[3].$testNick;
            my $crc32 = crc32 $str;
            my $rp = $crc32%256/256;
            my $rpPercent = ($rp*100).'%';
            my $rp20 = $rp*20;
            my $level = int $rp*20;
            my $progress = '['.('-' x (int $rp20-1)).($rp20-int $rp20 ? '.>' : '>').(' ' x (int 20-$rp20)).']';
            if ($testNick eq $nick)
            {
                $connect->privmsg ($dest, "${pre}你今天的人品: $progress $rpPercent (Lv $level/20)\n");
            }
            else
            {
                $connect->privmsg ($dest, "${pre}$testNick 今天的人品: $progress $rpPercent (Lv $level/20)\n");
            }
        }
    }
    if (isTusooa $nick)
    {
#        say 'tusooa';
#        say $cmd;
        given ($cmd)
        {
            when ('--restart') { exec $0 }
            when ('--quit') { exit }
            when ('--privmsg')
            {
#                say 'privmsg';
#                say "@words";
                my $to = shift @words;
#                say $to," @words";
                $connect->privmsg ($to, (join ' ', @words));
            }
            when ('--join')
            {
                $connect->join ($words[0]);
                #$connect->me ($words[0], '来凑凑热闹,大家欢迎不.');
            }
            when ('--leave')
            {
                $connect->part ($words[0]);
            }
            when ('--title-on')
            {
                push @titleOn, $words[0];
            }
            when ('--title-off')
            {
                @titleOn = grep $_ ne $words[0], @titleOn;
            }
            when ('--to-channel')
            {
                push @msgToChannel, $words[0];
            }
            when ('--not-to-channel')
            {
                @msgToChannel = grep $_ ne $words[0], @msgToChannel;
            }
            when ('--op')
            {
                use Data::Dumper;
                print Dumper $connect;
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

sub onAlways
{
    my ($connect, $word, $dest, $pre, $nick) = @_;
    my @words = @$word;
    my $arg = join ' ', @words;
    if ($words[0] eq 'ls')
    {
        $connect->privmsg ($dest, "${pre}ls: command not found");
    }
    given ($arg)
    {
        when (/(?:有(人|bot|机器人)(不|吗|么|没)|anybody\s+here)/i) { $connect->privmsg ($dest, "${pre}有\n");}
        when (/(bot|机器人).+(出来|干活)/i) { $connect->privmsg ($dest, "${pre}来了\n");}
        when (/知道(.+)(不|吗|么)/i)
        {
            $connect->privmsg ($dest, "${pre}搜索 $1\n");
        }
    }
    if ($arg =~ /(baidu|百度)/i)
    {
        $connect->privmsg ($dest, "${pre}No-Baidu\n");
    }
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
    my $toMe = 0;
    if ($words[0] =~ /^$mynick[:,]?/)
    {
        $toMe = 1;
        shift @words;
    }
    elsif (@words ~~ /(bot|机器人)/i)
    {
        $toMe = 1;
    }
    my $dest = $nick;
    my $pre = '';
    #say $cmd;
    if ($words[0] =~ /^-/)
    {
        onCommand ($connect, \@words, $dest, $pre, $nick);
    }
    elsif ($toMe)
    {
        onTalk ($connect, \@words, $dest, $pre, $nick);
    }
    onAlways ($connect, \@words, $dest, $pre, $nick);
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
    #say $arg;
    my @words = split /\s+/, $arg;
    my $toMe = 0;
    if ($words[0] =~ /^$mynick[:,]?/)
    {
        $toMe = 1;
        shift @words;
    }
    elsif (@words ~~ /(bot|机器人)/i)
    {
        $toMe = 1;
    }
    use Data::Dumper;
    print Dumper $event;
    my $dest = ($room ~~ @msgToChannel) ? $room : $nick;
    my $pre = ($dest eq $room) ? "$nick: " : '';
    if ($words[0] =~ /^-/)
    {
        onCommand ($connect, \@words, $dest, $pre, $nick);
    }
    elsif ($toMe)
    {
        onTalk ($connect, \@words, $dest, $pre, $nick);
    }
    onAlways ($connect, \@words, $dest, $pre, $nick);
    if ($room ~~ @titleOn)
    {
        for (@words)
        {
            if (m@^https??://[a-z0-9\./%\-_+&\?=;:,]+@i)
            {
                eval
                {
                    my $title = getHtmlTitle $_;
                    $title =~ s/\n//gs;
                    $connect->privmsg ($room, "● 标题：$title\n");
                };
                if ($@)
                {
                    $connect->privmsg ($room, "获取标题时出错.原提示: $@\n");
                }
            }
        }
    }    
}

$connect->add_global_handler(376, \&onConnect);
$connect->add_handler('public', \&onPublic);
$connect->add_handler('msg', \&onMsg);
$connect->privmsg ('NickServ', "IDENTIFY tusooa $ircPassword\n");

$irc->start;

