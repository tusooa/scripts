#!/usr/bin/perl

use 5.012;
use Gtk2 qw/-init/;
use Scripts::scriptFunctions;
use utf8;
use Encode;
my $conf = conf 'tray-volume.perl';
my $vol= $conf->get ('control') // 'Master';
my $left = $conf->get ('left') // 1;
my $right = $conf->get ('right') // 1;
#$left = 1 if $left > 1 or $left < 0;
#$right = 1 if $right >1 or $right < 0;

my $leftTop = 100*$left;
my $rightTop = 100*$right;
my $top = $left ? $leftTop : $rightTop;

my @pixbuf;
my $iconDir = decode_utf8 $pathConf->get ('iconDir');
for (0..4)
{
    $pixbuf[$_] = Gtk2::Gdk::Pixbuf->new_from_file ("${iconDir}sound/$_.png");
}

my $icon = Gtk2::StatusIcon->new;
#$icon->set_tooltip(decode("utf8","调整音量。滚轮调大小，点击切换静音。"));

my @volume;
sub getStat
{
    my $status = `amixer get $vol`;
    my $toggle = ($status =~ /\[on\]$/);
    @volume = (0,0,0),return if ! $toggle;
    my $lvolume = $status =~ /\[(\d+)%\]/ ? $1 : 0;
    my $rvolume = $status =~ /\[\d+%\].+\[(\d+)%\]/s ? $1 : 0 ;
    @volume = (1, $lvolume, $rvolume);
}

sub soundUp
{
#    my $leftNew = ($volume[1] + $left*10 > $leftTop) ? $leftTop : ($volume[1]+$left*10);
#    my $rightNew = ($volume[2]+$right*10 > $rightTop)? $rightTop : ($volume[2]+$right*10);
    system 'amixer', 'set', $vol, "10%+";
}

sub chooseIcon
{
    my ($stat, $lvolume, $rvolume) = @_ ? @_ : getStat;
    return 0 if ! $stat;
    #say "==>", $volume;
    my $volume = $left ? $lvolume : $rvolume;
    given ($volume)
    {
        return 4 when int $_ > 0.66*$top;
        return 3 when int $_ > 0.33*$top;
        return 2 when int $_ > 0;
        default { return 1; }
    }
}
sub setIcon
{
    getStat;
    #my @stat = getStat;
    #print chooseIcon;
    $icon->set_from_pixbuf ($pixbuf[chooseIcon @volume]);
    $icon->set_tooltip (decode_utf8 ($volume[0] ? (($left?$volume[1]:$volume[2])*$top/100).'%' : '靜音'));
}
sub click
{
    my ($check, $event) = @_;
    if ($event->button == 1)
    {
        system 'amixer', 'set', $vol, 'toggle';
    }
    setIcon;
}
sub scroll
{
    my ($check, $event) = @_;
    given ($event->direction)
    {
        system 'amixer', 'set', $vol, '10%-' when 'down';
        soundUp when 'up';
    }
    setIcon;
}

setIcon;
$icon->signal_connect ('button_release_event',\&click);
$icon->signal_connect ('scroll_event',\&scroll);
$icon->set_visible (1);
Gtk2->main;

