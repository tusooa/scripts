#!/usr/bin/env perl

use Scripts::scriptFunctions;
use 5.012;
use LWP::Simple qw/get/;
use Encode qw/encode_utf8 _utf8_on _utf8_off/;
use Date::Parse qw/str2time/;
use Getopt::Long qw/:config gnu_getopt/;

sub printFunc;

my $cfg = conf 'weather';
my $uri = $cfg->get ('weather-uri');
my $reload = 'DEFAULT';
my $quiet = 0;
my $conky = -t STDOUT ? 0 : 1;
my $help = 0;
my $showCity = 0;
GetOptions (
    'c|conky' => \$conky,
    't|term' => sub { $conky = 0 },
    'u|uri=s' => \$uri,
    'f|force|reload' => \$reload,
    'F|noforce|noreload' => sub { $reload = 0; },
    'q|quiet' => \$quiet,
    'help' => \$help,
    'C|city' => \$showCity,
);
if ($help) {
    say term
q{Usage: weather.perl [options]
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
my $city;
my $logf = "${cacheDir}weather";
if (open REC, '<', term $logf) {
    @_ = <REC>;
    chomp ($oldUri = shift @_);
    chomp ($city = shift @_);
    close REC;
}

my $fileday = time2date localtime ((stat $logf)[9]);
my $today = time2date;

if ($reload eq 'DEFAULT') {
    $reload = !( ($oldUri eq $uri) and ($fileday eq $today) );
}

#my $termColorCmd = (!$conky) ?
#    sub { s/^>/\e[1;33m/;s/^ /\e[0m/;s/^-/\e[32m/; } :
#              sub { s/°C\t.*/°C/g; s/20..-//g; s/^>\t/\${color1}/; s/^\ \t/\${color}/; s/^-\t/\${color3}/; s/\t(?=\d)/\${alignr}/;s/C\t.+$/C/; };
#    sub { s/^>\s+/\${color3}/;s/^ \s+//;s/^-\s+/\${color2}/;
#          s/\}\d{4}-/}/;my @weather = split /\t/;$_ = $weather[0].'${tab 60 0}'.$weather[1].'${alignr}'.$weather[2]."\n"; } ;
if ($showCity) {
    say term $city;
}

if (!$reload) {
    #是今天取得的现成数据。直接输出。
    $quiet and exit;
    for (@_) {
        next if /^\s*$/;
        printFunc;
    }
    exit;
}

$_ = get $uri;
if ($_) {
    $_ = encode_utf8 $_;#print;
    #_utf8_on $_;
    #print term $_;
    /"(.+)天气预报"/ and $city = $1;#die term $city;
    s/.*?(?=\d{4}-\d)//s;s/\n.*//s; #去掉头尾无用信息。
    s{<br/><br/><b>}/\n/g;s{<br/><br/>}{}g; s{<br/>}/\t/g; s{</b>}//g; s/<b>//g;
    s/C/°C/g;#s/℃/°C/g;
    s/～/ - /g; s/\x0d/\n/g;
    s/ 星期(一|二|三|四|五|六|日)//g;
    @_ = split "\n", $_;
    @_ = grep { !/^\s*$/ } @_;
} else {
    @_ or die term "无网页,无log.退出.\n";
    warn term "无网页,使用本地log.\n";
}

open REC, '>', term $logf or die term "Cannot open $logf: $!\n";
say REC $uri;
say REC $city;
for (@_) {
    s/^.\t//;#重读入的情况时，去掉原始的标记。
    next if /^\s*$/;
    if (/$today/) {
        $_ = ">\t$_";
    } else {
        my ($day) = split "\t";
        my @t = localtime str2time($day);# 检查下星期
        if( $t[6]==0 || $t[6]==6 ) {
            $_="-\t$_";
        } else {
            $_=" \t$_";
        }
    }
    $_.="\n";
    print REC;
    printFunc;

}
close REC;

sub printFunc
{
    if (!$quiet) {
        if ($conky) {
            s/°C\t.*/°C/g; s/20..-//g; s/^>\t/\${color1}/; s/^\ \t/\${color}/; s/^-\t/\${color3}/; s/\t(?=\d)/\${alignr}/;s/C\t.+$/C/;
        } else {
            s/^>/\e[1;33m/;s/^ /\e[0m/;s/^-/\e[0;32m/;
        }
        s/(\d)-/$1,/g;#s/ , / - /;
        print term $_;

=comment
        my ($start, $date, $weather, $temp, $wind) = split /\t/;
        print $start;
        #say STDERR $date;
        my ($y, $m, $d) = split /-/, $date;
        format STDOUT = 
@>>>,@>,@>@>>>>>>>>@<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<<<<<<
$y, $m, $d,"\t", $weather, $temp, $wind
.
        write;
=cut

    }
}
