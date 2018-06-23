#!/usr/bin/env perl

use Scripts::Base;
use Getopt::Long;

isWindows or die "This script is meant to be used only under Windows. On Linux use notice-msg instead.";
my $argsAreUtf8 = 0;

GetOptions('u|args-utf8' => \$argsAreUtf8);

sub autoConv
{
    $argsAreUtf8 ? @_ : map utf8($_), @_;
}

my $cfg = conf;

my $title = '子有新讯';
my $notifu = $cfg->get('notifu') // 'C:/Home/Programs/notifu/notifu.exe';
my ($msg, $icon, $sound);

given (scalar @ARGV) {
    when (1) {
        ($msg) = autoConv @ARGV;
    }
    when (2) {
        ($title, $msg) = autoConv @ARGV;
    }
    when (3) {
        ($icon, $title, $msg) = autoConv @ARGV;
    }
    when (4) {
        ($sound, $icon, $title, $msg) = autoConv @ARGV;
    }
    default {
        $title = '格式错误';
        $msg = '参数应介于 1-4 个。依次为：sound icon title text。';
    }
}


my @command = ($notifu, '/m', gbk($msg), '/p', gbk($title),
               (defined $icon ? ('/i', $icon) : ()),);


system(1, @command);
