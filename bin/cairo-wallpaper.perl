#!/usr/bin/env perl
#● convert desktop.jpg -resize 1680x1260 desktop.png (now)
#● convert desktop.jpg -resize 1400x1050 desktop.png
use 5.012;
use Scripts::scriptFunctions;
use Cairo;
use warnings;

system "${scriptsDir}cal.perl", '-p';
system "${scriptsDir}cairo-weather.perl", '-f';

my $weather = Cairo::ImageSurface->create_from_png ("${cacheDir}weather.png");
my $calendar = Cairo::ImageSurface->create_from_png ("${cacheDir}cal.png");
my $surface = Cairo::ImageSurface->create_from_png ("$ENV{HOME}/.fvwm/desktop.png");
#print $surface->write_to_png ("${cacheDir}wallpaper/1.png");
#__END__
my $context = Cairo::Context->create ($surface);
$context->set_source_surface ($weather, 100, 400);
$context->paint;
#print $surface->write_to_png ("${cacheDir}wallpaper/1.png");
$context = Cairo::Context->create ($surface);
$context->set_source_surface ($calendar, 700, 30);
$context->paint;
$surface->write_to_png ("${cacheDir}wallpaper/1.png");
system 'habak', '-mp','0,0', "$ENV{HOME}/.fvwm/desktop.png", '-mp', '100,400', "${cacheDir}weather.png", '-mp', '700,30', "${cacheDir}cal.png";
