#!/usr/bin/env perl

use 5.012;
use Gtk2 '-init';
use Getopt::Long qw/:config gnu_getopt/;
use Scripts::scriptFunctions;
# usage: show-png.perl file [x y]
my $movable = 0;
my $conf = conf 'show-png.perl';
my ($x, $y);
GetOptions (
    'm|movable' => \$movable,
    'M|no-movable' => sub { $movable = 0 },
    'p|pos=s' => sub { ($x,$y) = split ',', $_[1]; },
);
my $file = $ARGV[0];
if (! defined $x or ! defined $y) {
    ($x, $y) = $conf->get('main', $file, 'last-pos');#恢复上次的位置
}
die "no pic" if ! -e $file;
my $window = Gtk2::Window->new;
$window->set_decorated(0);
$window->add_events("GDK_BUTTON_PRESS_MASK");
$window->stick;
$window->set_keep_below(1);
$window->set_resizable(0);
$window->set_skip_pager_hint(1);
$window->set_skip_taskbar_hint(1);
#$window->set_keep_above(1);
$window->signal_connect('expose_event', \&expose);
$window->signal_connect('button_press_event',\&mouse);
$window->signal_connect('destroy', \&saveAndQuit);
$SIG{INT} = \&saveAndQuit;
$SIG{TERM} = \&saveAndQuit;
$SIG{USR1} = \&expose;
$SIG{KILL} = \&saveAndQuit;

my $img = Cairo::ImageSurface->create_from_png ($file);
$window->set_size_request($img->get_width,$img->get_height);
$window->set_colormap($window->get_screen->get_rgba_colormap);
$window->show_all();
if (defined $x and defined $y) {
    $window->move($x, $y);
}
Gtk2->main;

sub saveAndQuit {
=comment
    my ($x, $y) = $window->get_geometry;
    open CONF, '<', $configDir.'show-png.perl';
    my @c = <CONF>;
    close CONF;
    my $changed;
    for (0..$#c) {
        if ($c[$_] eq '[main]:'.$file."\n") {
            $c[$_+1] = 'last-pos = '."${x},${y}\n";
            $changed = 1;
            last;
        }
    }
    if (! $changed) {
        push @c, '[main]:'.$file."\n", 'last-pos = '."${x},${y}\n";
    }
    open CONF, '>', $configDir.'show-png.perl';
    print CONF @c;
    close CONF;
=cut
    Gtk2::main_quit;
}
sub expose {
    my($widget, $event) = @_;
    my $cr = Gtk2::Gdk::Cairo::Context->create($widget->window);
    $cr->set_operator("source");
    $cr->set_source_surface($img,0,0);
    $cr->paint;
    print "";
}

sub mouse{
    my ($widget, $event) = @_;
    if ($movable and $event->button eq 1) {
        $window->begin_move_drag($event->button,$event->x_root,$event->y_root,$event->time);
    }
}

