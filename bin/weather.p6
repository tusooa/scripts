#!/usr/bin/env perl6

use v6;
use Scripts::scriptFunctions;
use LWP::Simple;
#use Encode;
#use Date::Parse;
use Getopt::Long;
#sub printFunc;
my $cfg = conf 'weather';
my Str $uri = $cfg.get('weather-uri');
my Bool $reload = False but 'DEFAULT';
my Bool $quiet = False;
my Bool $conky = $*OUT ~~ :t ?? False !! True;
my Bool $help = False;

#sub MAIN (:$conky, :term($conky but False), :$reload, :$quiet, :$noreload, :$uri, :$help, *@args)
#{
### TODO ###
my @options := ('c'|'conky'), $conky,
    ('t'|'term'), sub { $conky = 0 },
    ('u'|'uri'), $uri,
    ('f'|'force'|'reload'), $reload,
    ('F'|'noforce'|'noreload'), sub { $reload = 0; },
    ('q'|'quiet'), $quiet,
    'help', $help;
GetOptions @options;
if $help {
    say
q{Usage: weather.p6 [options]
Options:
    -c, --conky                       print conky format
    -t, --term                        print terminal format
    -u, --uri=''                      use <uri> instead of that in the config file
    -f, --force, --reload             Force reload
    -F, --noforce, --noreload         Use local record file
    -q, --quiet                       Do not print anything
    --help                            What you are reading now
Default:
    Print weather information with the format depending on the result of `-t STDOUT'.
};
    exit;
}
#print $reload;
my $oldUri;
my $logf = "{$cacheDir}weather";
my @log;
if (my $rec = open $logf) {
    @log = $rec.lines;
    #say ~@log;
    $oldUri = shift @log if @log;
}

my $fileday = time2date DateTime.new($logf.IO.modified);
my $today = time2date;

if ($reload ~~ 'DEFAULT') {
    $reload = !( ($oldUri eq $uri) and ($fileday eq $today) );
    #say "reload : $reload";
}

#my $termColorCmd = (!$conky) ?
#    sub { s/^>/\e[1;33m/;s/^ /\e[0m/;s/^-/\e[32m/; } :
#              sub { s/°C\t.*/°C/g; s/20..-//g; s/^>\t/\${color1}/; s/^\ \t/\${color}/; s/^-\t/\${color3}/; s/\t(?=\d)/\${alignr}/;s/C\t.+$/C/; };
#    sub { s/^>\s+/\${color3}/;s/^ \s+//;s/^-\s+/\${color2}/;
#          s/\}\d{4}-/}/;my @weather = split /\t/;$_ = $weather[0].'${tab 60 0}'.$weather[1].'${alignr}'.$weather[2]."\n"; } ;


if !$reload {
    #是今天取得的现成数据。直接输出。
    #say $quiet;
    $quiet and exit;
    for @log {
        next if m:P5/^\s*$/; #:
        printFunc $_;
    }
    exit;
}

$_ = LWP::Simple.get($uri);
if ($_) {
    #$_ = encode_utf8 $_;#print;
    s:P5:s/.*?(?=\d{4}-\d)//;s:P5:s/\n.*//; #去掉头尾无用信息。
    s:P5:g@<br/><br/><b>@\n@;s:P5:g@<br/><br/>@@; s:P5:g@<br/>@\t@; s:P5:g@</b>@@; s:P5:g/<b>//;
    s:P5:g/C/°C/;#s/℃/°C/g;
    s:P5:g/～/ - /; s:P5:g/\x0d/\n/;
    s:P5:g/ 星期(一|二|三|四|五|六|日)//;#::
    @log = .split("\n");
    @log = grep { !m:P5/^\s*$/ }, @log;#:
    #say ~@log;
} else {
    #say ~@log;
    @log or die "无网页,无log.退出.\n";
    warn "无网页,使用本地log.\n";
}

$rec = open $logf, :w or die "Cannot open $logf: $!\n";
$rec.say($uri);
for @log {
    s:P5/^.\t//;#重读入的情况时，去掉原始的标记。::
    next if m:P5/^\s*$/;#:
    if (m:P5/$today/) {#:
        $_ = ">\t$_";
    } else {
        my ($day) = .split("\t");
        my ($y,$m,$d) = $day.split: '-';
        if $m < 10 { $m = '0' ~ $m }
        if $d < 10 { $d = '0' ~ $d }
        my $date-str = "$y-$m-{$d}T00:00:00+0800";
        my $dt = DateTime.new($date-str);# 检查下星期
        if $dt.day-of-week == (6|7)  {
            $_="-\t$_";
        } else {
            $_=" \t$_";
        }
    }
    $rec.say($_);
    printFunc $_;

}
close $rec;
#}
sub printFunc ($line is rw)
{
    given $line {
        if ($conky) {
            s:P5:g/°C\t.*/°C/; s:P5:g/20..-//; s:P5/^>\t/\$\{color1\}/; s:P5/^\ \t/\$\{color\}/; s:P5/^-\t/\$\{color3\}/; s:P5/\t(?=\d)/\$\{alignr\}/;s:P5/C\t.+$/C/;
        } else {
            s:P5/^>/\e[1;33m/;s:P5/^ /\e[0m/;s:P5/^-/\e[32m/;
        }
        s:P5:g/(\d)-/$0,/;#s/ , / - /;
        .say;
    }
}
