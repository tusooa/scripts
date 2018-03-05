#!/usr/bin/env perl

use lib 'lib';
use Scripts::WindowsSupport;

system 'assoc', '.perl=PerlScript';
system 'ftype PerlScript=' . $^X . ' "%1" %*';

addPathEnv PATHEXT => '.PERL';


