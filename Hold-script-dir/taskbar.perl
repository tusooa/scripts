#!/usr/bin/env perl

use 5.012;
use X11::Protocol;
use MIME::Base64 qw(encode_base64);

sub readClientList;
sub createTaskBar;

my @getpropconst = ('AnyPropertyType', 0, -1, 0);
my $x = X11::Protocol->new;
my $root = $x->root;
my @windows;
my $taskWin;
my $windowWidth = 15;
my $windowHeight = $x->{screens}[0]{height_in_pixels};
my $borderWidth = 0;

createTaskBar;
$x->next_event;

sub createTaskBar
{
    my $taskWin = $x->new_rsrc;
    $x->CreateWindow($taskWin, $root, 'InputOutput', $x->root_depth, 'CopyFromParent', (0, 0), $windowWidth, $windowHeight, $borderWidth);
}

sub readClientList
{
    my ($value) = $x->GetProperty($root, $x->atom ('_NET_CLIENT_LIST'), @getpropconst);
    my @ids = unpack('L*', $value);
#    my @windows;
    @windows = ();
    for (@ids) {
        my $window = {id => $_};
        $window->{title} = $x->GetProperty($_, $x->atom ('WM_NAME'), @getpropconst);
#        $window->{
        push @windows, $window;
    }
    wantarray ? @windows : undef;
}

