#!/usr/bin/env perl
use 5.012;
use utf8;
use Gtk2 qw/-init/;
use Scripts::scriptFunctions;
use Encode qw/decode_utf8/;
sub popM
{
    my ($widget, $button, $time, $menu) = @_;
    if ($button == 3)
    {
        my ($x,$y,$push_in)=Gtk2::StatusIcon::position_menu($menu, $widget);
        $menu->show_all;
        $menu->popup (undef, undef, sub { return ($x, $y, 0) },
                      undef, 0, $time);
    }
}
my $config = conf;
sub loadmenu
{
    my $menu = Gtk2::Menu->new;
    my $item;
    my $defaultcmd;
    my %confhash = $config->hash;
    for (keys %confhash)
    {
        my $iconfile = $config->get ($_, 'iconfile');
        my $command = $config->get ($_, 'command') or next;
        $item = Gtk2::ImageMenuItem->new_with_label (decode_utf8 $_);
        $item->set_image (Gtk2::Image->new_from_file ($iconfile));
        $item->signal_connect ('activate', sub { system $_[1]; }, $command);
        $menu->append ($item);
    }
    my $statusIcon = Gtk2::StatusIcon->new_from_stock ('gtk-home');
    $statusIcon->set_tooltip ("托盘菜单：脚本集合");
    #$status_icon->signal_connect ('activate', sub{`$defaultcmd`;});
    $statusIcon->signal_connect ('popup-menu', \&popM, $menu);
    $statusIcon->set_visible (1);
    $item = Gtk2::ImageMenuItem->new_with_label ("Reload config");
    $item->signal_connect ('activate',
      sub { $statusIcon->set_visible(0); undef $statusIcon; &loadmenu; });
    $menu->append ($item);
    $item = Gtk2::ImageMenuItem->new_from_stock ('gtk-quit');
    $item->signal_connect ('activate', sub { Gtk2->main_quit }, $statusIcon);
    $menu->append ($item);
}
loadmenu;
Gtk2->main;
