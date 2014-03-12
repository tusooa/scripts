#!/usr/bin/perl

use Term::Screen;

$scr = new Term::Screen;
unless ($scr) { die "无法产生屏幕。\n"; }
$black="\e[30m"; $red="\e[31m"; $green="\e[32m"; $yellow="\e[33m";
$blue="\e[34m"; $pink="\e[35m"; $cyan="\e[36m"; $white="\e[37m";
$normal="\e[0m"; $bold="\e[1m"; $reverse="\e[7m";

$scr->clrscr();$scr->noecho();
$scr->resize(80,30);
print "\t\t${reverse} easy-account 终端版本${normal}";
use POSIX qw(strftime);
use Switch;
use Date::Parse;
#use utf8;

$path="$ENV{HOME}/.easy-account/";
#$path="$ENV{HOME}/project/easy-account/";
$f1="${path}items";
open(ITEMS,$f1) or die("不能打开items文件。\n");
@items=<ITEMS>;
close(ITEMS);

$f1="${path}record";
if(-f $f1){
open(REC,$f1) or die("不能打开record文件。\n");
while(<REC>){
        next if ! /^===/;
        s/^=*//g;
        $lday=s2t($_);
}
close(REC);
}
else {$lday=0;}

$day=time; $opday=$day;
#$lday=$day;
$scr->at(1,0)->clreol()->puts("${red} 今天：    ${blue}".t2s($day)."${normal}\n\r");
$scr->at(3,0)->clreol()->puts("${red} 最后记录：${blue}".t2s($lday)." ${yellow}<".diffd($lday).">${normal}");
dispdate();

# ---------------------------------------------------------------
MAIN:   while(1){
$in="";$item="";$def="";$price="";@Aitem[0..10];@Adef[0..10];$s=0;
# 0 无输入。1 输入了缩写，可输入数字选择。 2 选择了项目，只能输入数据。
disp();

while(1){
$ch=$scr->getch();
switch($ch){
case [a..z]     {if($s>1){last};$s=1;$in.=$ch;}
case [0..9]     {if($s==0){last};
#case /\d/      {if($s==0){last};
                if($s==1){      # 选择
                if($ch eq "0"){$ch="10";}
                if($ch<=$n){
                $item=$Aitem[$ch];$def=$Adef[$ch];$s=2;
                $scr->at(4,18)->clreol()->puts("选择了 $item");
                }}
                else{   # 输入数据 s=2
                $price.=$ch;
                }}
case "."        {if($s<2){last;}
                if($price eq ""||$price=~/\./){last;}
                $price.=".";}
case "\x0d"     {if($s<2){last;}
                if($price eq "" && $def){$price=$def;}  # 无价格，有默认
                if($price eq ""){last;} # 无价格
                $f1=">>${path}record";
                open(REC,$f1) or die("不能打开record文件。\n");
                if(t2s($opday) ne t2s($lday)){
                $lday=$opday;
                # 输出记录到文件
$scr->at(20,4)->clreol()->puts("记录时间：======".t2s($opday));
$scr->at(3,0)->clreol()->puts("${red} 最后记录：${blue}".t2s($lday)." ${yellow}<".diffd($lday).">${normal}");
                print REC "========".t2s($opday)."\n";
                }
        $scr->at(21,4)->clreol()->puts("输入记录：-$item- 金额：-$price-");
                print REC "$item,$price\n";
                close(REC);
                sleep 1;
                next MAIN;}
case "\x7f"     {if($s==0){last;}       #backspace
                if($s==1){chop($in);}
                if($s==2){if($price){chop($price);}
                else{$s=1;chop($in);$item="";$def="";}
                }
                if($in eq ""){next MAIN;}
                }
case "ku"       {$opday=$opday-86400*7;dispdate();}
case "kd"       {$opday=$opday+86400*7;dispdate();}
case "kl"       {$opday=$opday-86400;dispdate();}
case "kr"       {$opday=$opday+86400;dispdate();}
case "\x1b"     {$scr->clrscr();last MAIN;}
else            {       # 显示无效按键
                $scr->at(6,0)->clreol();
                print "输入按键：=$ch=";
                $ch=~s/(.)/"%".unpack('H2',$1)/seg;
                print $ch;
                }
}
disp();
}}
# ---------------------------------------------------------------
sub dispdate {
$scr->at(2,0)->clreol()->puts("${red}操作日期：${blue}".t2s($opday)." ${yellow}<".diffd($opday).">${normal} <-使用光标键修改，增减日／周。\n\r");
}
# ---------------------------------------------------------------
sub disp {
        $scr->at(4,0)->clreol()->puts("操作状态：$s");
        $scr->at(10,0)->clreos();
        switch($s){
        case 2  {
                print "${blue}已选定项目：${red}$item${blue} ";
                if($def){print "默认：${red}$def ${normal} <-可不输入数据，直接回车确定。";}
        $scr->at(8,0)->clreol()->puts("${blue}输入金额：${red}${price}${normal}");
                }
        case 1  {
                print "${green}可选项目：${normal}";
                $n=0;
                foreach(@items){
                chomp;
                ($w,$i,$d)=split(",");
                if($w=~/$in/){
                        $n++;
                        if($n<11){print "${green}$n${normal}:";
                        $Aitem[$n]=$i;$Adef[$n]=$d;}
                        else {print "$n:";}
                        print "$i";
                        if($d){print "(默认:$d)";}
                        print "  ";
                        }
                }
                if($n==1){$scr->stuff_input("1");}
        $scr->at(8,0)->clreol()->puts("${blue}输入名称缩写：${normal}$in");
                }
        case 0  {
        $scr->at(8,0)->clreol()->puts("${blue}输入名称缩写：${normal}");
                }

        }
}
# ---------------------------------------------------------------
sub t2s {
        my $t=shift;
        return strftime("%Y-%m-%d %A",localtime($t));
}
# ---------------------------------------------------------------
sub s2t {
        my $t=shift;
        ($t,undef)=split(" ",$t);
        return str2time($t);
}
# ---------------------------------------------------------------
sub diffd {
        my $d=int(($day-shift)/86400);
        if($d==0){return "今天";}
        if($d==1){return "昨天";}
        if($d==2){return "前天";}
        if($d>2){return "$d 天前";}
        if($d==-1){return "明天";}
        if($d==-2){return "后天";}
        $d=~s/^-//;
        return "$d 天后";
}
# ---------------------------------------------------------------
