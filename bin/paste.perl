#!/usr/bin/env perl

use 5.012;
use Getopt::Long qw/:config gnu_getopt/;
use WWW::Mechanize;
use MIME::Base64;
use Encode;
use Scripts::scriptFunctions;

my $base64 = 0;
my @command;
my $tinyurl = 0;
my $irc = 0;
GetOptions( 's|base64' => \$base64, 'c|command' => sub { @command = multiArgs }, 't|tinyurl' => \$tinyurl, 'i|irc' => \$irc, 'end' => sub {} );

my $mech = WWW::Mechanize->new;
if ($tinyurl) {
    my $url = shift;
    chomp ($url = `xsel -o`) if ! $url;
    $mech->get ('http://tinyurl.com/');
    $mech->submit_form (with_fields => { url => $url });
    if ($mech->success) {
        $_ = $mech->content;#say;
        m{<b>(http://tinyurl.com/.+?)</b><div id=}m;
        say $1;
        open XSEL, '|-', 'xsel', '-i';
        #system qq{echo -n "$1" | xsel -i};
        print XSEL $1;
        close XSEL;
        system 'notice-msg', 'paste.perl', "Tinyurl: $1";
    } else {
        system 'notice-msg', 'paste.perl', "Tinyurl Error: $mech->status";
    }
} else { #不知道现在这还能用不
    my $content;
    if (@command) {
        my $shPrompt = '● ';
        open (PIPE, '-|', @command) or die "Cannot open pipe: $!\n";
        $content = "$shPrompt@command\n" . join('', <PIPE>);
        close PIPE;
    } else {
#        my $file = $ARGV[0] // '/dev/stdin';
#        open (FILE, '<', $file) or die "Cannot open file `$file': $!\n";
#        $content = join('', <FILE>);
#        close FILE;
        $content = join '', <>;
    }
    $content or die "No content.\n";
    
    if ($base64) {
        $content = "Use base64 -d to decode following:\n" . (encode_base64 $content);
    }
    $content = decode 'utf-8', $content;
    $mech->get ('http://paste.ubuntu.org.cn/');
    $mech->submit_form (with_fields => { poster => $ENV{USER}, code2 => $content, }, button => 'paste');
    if ($mech->success) {
        my $paste = $mech->uri;
        say $paste;
        #system qq{echo -n "$paste" | xsel -i};
        open XSEL, '|-', 'xsel', '-i';
        #system qq{echo -n "$1" | xsel -i};
        print XSEL $paste;
        close XSEL;
        system 'notice-msg', 'paste.perl', "Paste URL: $paste";
    } else {
        system 'notice-msg', 'paste.perl', "Paste Error: $mech->status";
        say "Paste Error: $mech->status";
    }
}

