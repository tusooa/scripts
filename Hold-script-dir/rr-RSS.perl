#!/usr/bin/env perl

use 5.012;
use XML::Feed;
use Scripts::Base;
use LWP::UserAgent;
use Encode qw/_utf8_on _utf8_off encode_utf8 decode_utf8/;
#use encoding 'utf8';
#use utf8;
use Getopt::Long qw/:config gnu_getopt/;

sub help
{
    say qq{用法:
rr-RSS.perl [options] 网站名 # 或
rr-RSS.perl [options] <--custom|-u> 标题 uri

选项:长选项需要的参数，短选项当然也要。
-c, --conky             显示为conky格式
-t, --ansi-term         显示为终端格式
-m, --max=NUM           获取的feed数量
-p, --proxy=STR         指定代理。可用http,socks5等。前提是要有对应的perl模块。
-a, --user-agent=STR    指定使用的User-Agent(UA)。
-r, --rss               强制使用RSS格式(通常不必)
-o, --atom              强制使用Atom格式(通常不必)
--help                  就是你现在看到的东西。};
}

my $conky = -t STDOUT ? 0 : 1;
my $custom = 0;
my $maxNum;
my $defaultMaxNum = 2;
my $proxy;
my $agent = 'rr-RSS.perl';
my $format = undef;
GetOptions (
    'conky|c' => \$conky,
    'ansi-term|t' => sub { $conky = 0 },
    'custom|u' => \$custom,
    'max|m=i' => \$maxNum,
    'proxy|p=s' => \$proxy,
    'user-agent|a=s' => \$agent,
    'rss|r' => sub { $format = 'RSS' },
    'atom|o' => sub { $format = 'Atom' },
    'help' => sub { help ; exit 0; },
);

my $webCfg = conf 'global-web';

my $config = conf 'rr-RSS.perl';
my %colors = (
    title => $conky ? $config->get ('Colors', 'conky-title') : $config->get ('Colors', 'term-title'),
    feeds => $conky ? $config->get ('Colors', 'conky-feeds') : $config->get ('Colors', 'term-feeds'),
);
my ($uri, $fullName, $maxNum);
if (! $custom) #if !易读。
{
    my $webName = shift @ARGV;
    #_utf8_off $webName;
    help,die "没有指定网站名\n" if ! $webName;
    $uri = $config->get ('Feeds', $webName, 'uri')
        or die "从配置中找不到所谓的 $webName Feed。\n";
    $fullName = $config->get ('Feeds', $webName, 'full-name') // $webName;
    $proxy = $proxy // $config->get ('Feeds', $webName, 'proxy');
    $maxNum = $maxNum // $config->get ('Feeds', $webName, 'num') // 2;
    $format = $format // $config->get ('Feeds', $webName, 'format');
}
elsif (@ARGV >= 1) #这里往下的else/elsif都是自定rss。
{
    ($uri, $fullName) = @ARGV;
    if (! $fullName)
    {
        $fullName = $uri;
        $fullName =~ s[^.+?://][];
        $fullName =~ s[/.*$][];
    }
}
else
{
    help;
    die "没有指定uri。\n";
}

$maxNum = $maxNum // $defaultMaxNum;
my $lwp = LWP::UserAgent->new (agent => $agent);
$proxy = $proxy // $webCfg->get ('proxy');
$lwp->proxy ([qw/http https/], $proxy) if $proxy;
my $response = $lwp->get ($uri) or die "Couldn't get it!\n";
my $text;
if ($response->is_success)
{
    $text = $response->decoded_content;
}
else
{
    die "$fullName error: ".$response->status_line."\n";
}
my $rss = XML::Feed->parse (\$text, $format);
say "$colors{title}$fullName:$colors{feeds}";
my $num = 0;
for my $item ($rss->entries)
{
    $num < $maxNum or last;
    $num++;
    say $item->title;
}


