#!/usr/bin/env perl
use Scripts::Base;
use Scripts::insLisp::Lib;
use Scripts::insLisp::Eval;
use Scripts::insLisp::Types qw/dd/;

use Getopt::Long;
my $code;
GetOptions('e=s' => \$code);
my $running = '-e';
my $repl = 0;
if (not defined $code) {
    if (@ARGV) {
        my $file = shift @ARGV;
        open FILE, '<', $file or die "cannot open $file: $!\n";
        $code = join '', <FILE>;
        close FILE;
        $running = $file;
    } else {
        $repl = 1;
    }
}
topEnv->scope->var('Args', \@ARGV);
topEnv->scope->var('Running', $running);
if ($repl) {
    topScope->var('exit', Scripts::insLisp::Func->new(sub { exit }));
    use IO::Handle ();
    STDOUT->autoflush(1);
    while (print('>> '),
           chomp ($_ = <STDIN>)) {
        my @byte = eval { ta->parse($_) };
        if ($@) {
            say 'compile err = ' . $@;
            next;
        }
        my @ret = eval { map { getValue($_, topEnv) } @byte };
        if ($@) {
            say 'err = ' . $@;
        }
        say 'res = ' . dd($ret[-1]);
    }
} else {
    my @byte = ta->parse($code);
    map { getValue($_, topEnv) } @byte;
}
