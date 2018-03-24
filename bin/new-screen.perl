#!/usr/bin/env perl

use 5.012;
use Getopt::Long;
use Scripts::Base;
use IPC::Open2;

my $config = conf 'new-screen.perl';
my $terminal = $config->get ('terminal') // 'urxvt -e';
my %screen;
my $selected;
GetOptions ('t|terminal' => \$terminal,
            's|session' => \$selected);
my @termCmd = split /\s+/, $terminal;
my @runProgram = (@ARGV ? @ARGV : 'screen');
#print "@runProgram";
sub newScreen
{
    my $session = shift;
    #my @cmd = ('screen', '-x', $session, '-X', 'screen');
    die "沒有這個session" if ! $screen{$session};
    #@cmd = (@termCmd, @cmd) if $screen{$session} ne 'Attached';
    #say "@cmd";
    system 'screen', '-x', $session, '-X', @runProgram;
    system @termCmd, 'screen', '-x', $session if $screen{$session} ne 'Attached';
}

chomp (my $host = `/bin/hostname` // 'localhost');
system 'screen', '-wipe';
%screen = map { /^\t([^\t]+)\t\(([^\)]+)\)$/; $1 => $2 } grep /\.\Q$host\E/, split /\n/, `screen -list`;
#print %screen;
#my @attached = grep $screen{$_} eq 'Attached', keys %screen;
if (keys %screen == 1) {
    ($selected) = keys %screen;
} else {
    until ($selected) {
        my $pid = open2 (\*OUT, \*IN, 'zenity', '--list', '--text=選擇screen?', '--width=400', '--height=400', '--column=Screen', '--column=Status');
        for (keys %screen) {
            say IN $_;
            say IN $screen{$_};
        }
        waitpid $pid, 0;
        chomp ($selected = <OUT>);
        say $selected;
    }
}

newScreen $selected;

