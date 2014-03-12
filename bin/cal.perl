#!/usr/bin/perl

use Scripts::scriptFunctions;
use POSIX qw/strftime/;
use 5.012;
use Getopt::Long;

my $png = 0;
GetOptions ('p' => \$png);

my $cfg = conf 'cal.perl';

my $regFont = $cfg->get ('Fonts', 'regular') // 'ZhunYuan';
my $monoFont = $cfg->get ('Fonts', 'monospace') // 'WenQuanYi Zen Hei Mono';
my $fontSize = $cfg->get ('Fonts', 'size') // '20';
my $regColor = $cfg->get ('Colors', 'regular') // '#7932a0';
my $weekendColor = $cfg->get ('Colors', 'weekend') // '#32a032';
my $holidayColor = $cfg->get ('Colors', 'holiday') // '#4746D8';
my $todayColor = $cfg->get ('Colors', 'today') // '#C82A2A';
my $calColor = $cfg->get ('Colors', 'calendar') // '#7932a0';
my $zh = $cfg->get ('Language', 'chinese') // 1;
my $record = $cacheDir . 'calendar';
$ENV{LANG} = 'zh_CN.UTF-8';
$ENV{LC_ALL} = '';

my $today = strftime "%Y-%m-%d", localtime time;
my $fileday = strftime "%Y-%m-%d", localtime ((stat $record)[9]);
#exit if $fileday eq $today;

my (undef, undef, undef, $day, $mon, $year, $wan) = localtime time;
$year += 1900;
$mon += 1;
my $wan1 = ($wan + 7 - ($day-1) % 7) % 7; # 1号是星期几
$wan %= 7;

my @monarr = qw/0 31 28 31 30 31 30 31 31 30 31 30 31/;
if (
    ( ($year % 4 == 0) && ($year % 100 != 0) )
    ||
    ($year % 400 == 0) )
{
    $monarr[2] = "29"; # 闰年的2月
}

#my $lunar=`calendar -A 0 -f ~/.calendar/calendar.2010.lunar`;
#$lunar=~/\t(.*)$/;$lunar=$1;

my @months = $zh ? (0, qw/1月 2月 3月 4月 5月 6月 7月 8月 9月 10月 11月 12月/) : (0, qw/Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec/);
my @weekdays = $zh ? qw/周日 周一 周二 周三 周四 周五 周六/ : qw/Sun Mon Tue Wed Thu Fri Sat/;
#print $mon;
chomp (my $calendar=`calendar -B 31 -A 31`);
my @d = ($calendar =~ /\b${mon}月 (\d+)/g);
#print "@d";

my $pango0 = '      ' x $wan1;

for my $i (1..$monarr[$mon])
{
    my $style = "";
    my $under = "";
    if ( $wan1 == 6 or $wan1 == 0)
    { #休息
        $under="_";
        $style="-";
    }
    if (grep $i==$_, @d)
    { #节日
        $style="~";
    }
    if ($i==$day)
    { #今天
        $style="+";
    }
    my $space = $i >= 10 ? '    ' : '     ';
    $pango0 .= $style.$i.$under.$space;
    $wan1 == 6 and $pango0 .= "\n";
    $wan1++;
    $wan1 %= 7;
}
map {
  s:-(.*?) :<span color='$weekendColor'>$1 </span>:g; #休息
  s:~(.*?) :<span color='$holidayColor'>$1 </span>:g; #节日
  s:\+(.*?) :<span color='$todayColor'><i>$1 </i></span>:g; #今天
  s:(\d+)_:<u>$1</u>:g;
} $pango0;
my $pango = "<span font='$monoFont'>";
if ($zh)
{
    $pango .= $_ . '  ' for @weekdays;
}
else
{
    $pango .= $_ . ' ' x (6 - length $_) for @weekdays;
}
$pango .= "\n" . $pango0 . '</span>';

#添加日期，日历，缺省颜色
my $d = $zh ?
    "${year}年$months[$mon]$day日$weekdays[$wan]" :
    "$weekdays[$wan] $months[$mon] $day, $year";
$pango="<span font='$regFont'>$d</span>\n".$pango;

#$calendar=~s:\d+月 \d+:<u>$&</u>:g;
#my $calendar = `calendar -A 30 -B 30`;
#my @d = 
#$calendar =~ s/($mon)月/$months[$1]/g;
@d = split /\n/, $calendar;
@d = grep /\b${mon}月 (\d+)/, @d;
my $calendar = join "\n", @d;
#$repeat = `calendar -A 0 -f ~/.calendar/calendar.repeat`;
$pango.="\n<span font='$regFont $fontSize' color='$calColor'>$calendar</span>";
$pango="<span color='$regColor'>".$pango."</span>";

#print $pango;
open REC, '>', $record or die "不能打开文件$record: $!\n";
print REC $pango;
close REC;

if ($png)
{
    system "${scriptsDir}pango2png.perl", '-f', 'cal', "${cacheDir}calendar", '-s', $fontSize;
}
