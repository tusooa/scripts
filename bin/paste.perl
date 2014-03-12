#!/usr/bin/env perl

use 5.012;
use Getopt::Long;
use WWW::Mechanize;
use MIME::Base64;
use Encode;

my $base64 = 0;
my $command = undef;
my $tinyurl = 0;
my $irc = 0;
GetOptions( 's|base64' => \$base64, 'c|command=s' => \$command, 't|tinyurl' => \$tinyurl, 'i|irc' => \$irc );

my $mech = WWW::Mechanize->new;
if ($tinyurl)
{
    chomp (my $url = `xsel -o`);
    $mech->get ('http://184.im/');
    $mech->submit_form (with_fields => { url => $url});
    if ($mech->success)
    {
        $_ = $mech->content;
        m{^(http://184.im/.+?)<a}m;
        say $1;
        system qq{echo -n "$1" | xsel -i};
        system 'notice-msg', 'Tinyurl Done.';
    }
    else
    { system 'notice-msg', "Tinyurl Error: $mech->status";}
}
else
{
    my $content;
    if ($command)
    {
        my $shPrompt = '● ';
        open (PIPE, "$command |") or die "Cannot open pipe: $!\n";
        $content = "$shPrompt$command\n" . join('', <PIPE>);
        close PIPE;
    }
    else
    {
#        my $file = $ARGV[0] // '/dev/stdin';
#        open (FILE, '<', $file) or die "Cannot open file `$file': $!\n";
#        $content = join('', <FILE>);
#        close FILE;
        $content = join '', <>;
    }
    $content or die "No content.\n";
    
    if ($base64)
    {
        $content = "Use base64 -d to decode following:\n" . (encode_base64 $content);
    }
    $content = decode 'utf-8', $content;
    $mech->get ('http://paste.pocoo.org/');
    $mech->submit_form (fields => { code => $content });
    if ($mech->success)
    {
        my $paste = $mech->uri;
        say $paste;
        system qq{echo -n "$paste" | xsel -i};
        system 'notice-msg', 'Paste Done.';
    }
    else
    {
        system 'notice-msg', "Paste Error: $mech->status";
        say "Paste Error: $mech->status";
    }
}

