#!/usr/bin/env perl

use 5.018;
use LWP::Simple;
if (not -f 'cpanm.perl') {
say 'getting cpanm...';
my $cpanm = get('https://cpanmin.us/');
$cpanm or die "cannot get cpanm";
say 'done!';
open FILE, '>', 'cpanm.perl';
binmode FILE;
print FILE $cpanm;
close FILE;
}

system ($^X, 'cpanm.perl',
    qw/
    Win32::Env
    Mojolicious
    Mojo::Webqq
    Regexp::Common
    Time::HiRes
    Digest::MD5
    MIME::Base64
    /
    );

