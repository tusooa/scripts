#!/usr/bin/env perl

use 5.018;
use CPAN;
CPAN::Shell->notest(
    qw/
    install
    Win32::Env
    Mojo::Webqq
    Regexp::Common
    Time::HiRes
    Digest::MD5
    MIME::Base64
    /
    );
