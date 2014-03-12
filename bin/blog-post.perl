#!/usr/bin/env perl

use 5.012;

my $postDir = "$ENV{HOME}/共享/网站/tusooa.tk/sources/_posts/";
my $title = join '', @ARGV or die "没有指定标题\n";
my @time = localtime time;
my $year = $time[5] + 1900;
my $month = $time[4] + 1;
my $month0 = $month < 10 ? '0' . $month : $month;
my $mday = $time[3] < 10 ? '0' . $time[3] : $time[3];
my $date = "$year-$month0-$mday";
my $basename = $date . '-' . $title . '.mdown';
my $fullName = $postDir . $basename;

open FILE, '>', $fullName or die "不能打开文件`$fullName':$!\n";
say FILE qq{---
layout: post
title: "$title"
tags: []
---

};
close FILE;


