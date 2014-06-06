#!/usr/bin/env perl

use 5.012;

use Getopt::Long;
use Scripts::scriptFunctions;

my $num;
GetOptions(
    number => \$num,
);

my %en2cn = (
    "1" => "一", "2" => "二", "3" => "三", "4" => "四", "5" => "五",
    "6" => "六", "7" => "七", "8"=>"八", "9"=>"九", "10"=>"十",
    "11"=>"十一", "12"=>"十二", "13"=>"十三", "14"=>"十四", "15"=>"十五",
    "16"=>"十六", "17"=>"十七", "18"=>"十八", "19"=>"十九", "20"=>"二十",
    "21"=>"廿一", "22"=>"廿二", "23"=>"廿三", "24"=>"廿四", "25"=>"廿五",
    "26"=>"廿六", "27"=>"廿七", "28"=>"廿八", "29"=>"廿九", "30"=>"三十"
);

my @date;
if (@ARGV == 3)
{
    @date = @ARGV;
}
else
{
    @date = split '-', time2date;
}
open LUNAR, '-|', 'lunar', '--utf8', @date;

my ($year,$nyear,$leap,$month,$day);
while (<LUNAR>)
{
    if ($.==4)
    {
        /(\d+)年(闰)?\s*?(\d+)月\s*?(\d+)日/;
        ($nyear,$leap,$month,$day)=($1,($2 ? 1 : 0),$3,$4);
    }
    elsif ($.==5)
    {
        /^干支：　(.+?)年/;
        $year=$1;
    }
}

if ($num)
{
    say "${nyear} ".($leap ? 'r' : '')."${month} ${day}";
}
else
{
    say "${year}年".($leap ? '闰' : '')."$en2cn{$month}月$en2cn{$day}日";
}

