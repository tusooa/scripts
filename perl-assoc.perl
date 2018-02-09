#!/usr/bin/env perl

use Win32::Env;

system 'assoc', '.perl=PerlScript';
system 'ftype PerlScript=' . $^X . ' "%1" %*';

InsertPathEnv(ENV_USER, PATHEXT => '.PERL');
BroadcastEnv;
