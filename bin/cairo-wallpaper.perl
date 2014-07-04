#!/usr/bin/env perl
#● convert desktop.jpg -resize 1680x1260 desktop.png (now)
#● convert desktop.jpg -resize 1400x1050 desktop.png
use 5.012;
use Scripts::scriptFunctions;
use Cairo;
use warnings;
use Getopt::Long;
GetOptions ('d|debug' => \$Scripts::scriptFunctions::debug);
my $conf = conf 'wallpaper';
my $bg = $conf->get ('background') // "$home/.fvwm/desktop.png";
my %extra = %{ $conf->{extra} };
debug sub { use Data::Dumper; print Dumper %extra; };
my $surface = Cairo::ImageSurface->create_from_png ($bg);
my $output = $conf->get ('output') // "${cacheDir}wallpaper/1.png";
my @habak = (q/habak/, q/-mp/, q/0,0/, $bg);
for (keys %extra) {
    system $conf->get ('extra', $_, 'command');
    my $this = Cairo::ImageSurface->create_from_png ($_);
    my $context = Cairo::Context->create ($surface);
    my $pos = $conf->get ('extra', $_, 'position');
    $context->set_source_surface ($this, split /\s*,\s*/, $pos);
    $context->paint;
    push @habak, '-mp', $pos, $_;
}

$surface->write_to_png ($output);
debug join ' ', @habak;
system @habak;
final;
