#!/usr/bin/env perl

use 5.012;
use utf8;
use Scripts::Base;
say term '正在开始...';
# this script is only meant to be run under windows
if ($^O ne 'MSWin32') {
    ...
}
my $openccDir = 'F:\\Downloads\\opencc-0.4.2-win32\\opencc-0.4.2\\';
my $opencc = $openccDir.'opencc.exe';
my $conf = $openccDir.'zht2zhs.ini';
my $input = 'F:\\Programs\\GarenaLoLTW\\GameData\\Apps\\LoLTW\\Game\\DATA\\Menu\\fontconfig_zh_TW.txt';
my $output = term 'C:\\Program Files\\TencentLoLCN\\英雄联盟\\Game\\DATA\\Menu\\fontconfig_zh_CN.txt';
my $tmp = 'F:\\Desktop\\fontconfig_zh_CN.txt';
say term "Converting $input to $tmp...";
system $opencc, '-c', $conf, '-i', $input, '-o', $tmp;
say term 'done';
say term 'Adding the headlines...';
open TMP, '<', $tmp or die "Cannot open $tmp: $!\n";
open OUT, '>', $output or die "Cannot open $output: $!\n";
say OUT '[FontConfig "English"]
fontlib "fonts_ch.swf"
map "$ButtonFont" = "FZLanTingHei-L-GBK"
map "$NormalFont" = "FZLanTingHei-L-GBK"
map "$TitleFont" = "FZLanTingHei-L-GBK"
map "$IMECandidateListFont" = "FZLanTingHei-L-GBK"';
<TMP> for 1..6;
print OUT $_ while <TMP>;
close OUT;
close TMP;
final;
