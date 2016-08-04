#!/usr/bin/env perl

use 5.012;
while (1) {
    system "windy.perl";
    say "restarting in 5s...";
    sleep 5;
}
__END__
use Gtk2 qw/-init/;
use Scripts::scriptFunctions;
use Scripts::Windy::Util;

sub windy;

my $builder = Gtk2::Builder->new;
$builder->add_from_file($dataDir.'windy-w.glade');
my $start = $builder->get_object('startBtn');
my $stop = $builder->get_object('stopBtn');
my $buf = $builder->get_object('textbuffer1');
my $window = $builder->get_object('window1');
$window->show_all;
Gtk2->main;
sub windy
{
    open my $w, 'windy.perl|' or die "Cannot run windy.perl: $!\n";

    close $w;
}
