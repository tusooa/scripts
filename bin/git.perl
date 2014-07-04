#!/usr/bin/env perl

use 5.012;
use Scripts::scriptFunctions;
use POSIX qw/strftime/;
#my $config = conf 'gitpath';

#chdir $config->get ('gitDir');
$ENV{LC_ALL} = 'C';#git变成中文的了,倒不好作了
if ($^O eq 'MSWin32') {
    say term "你的确应当用```GitHub for Windows'''这个软件。";
}
my $git = $^O eq 'MSWin32' ? 'F:\\Programs\\Git\\bin\\git.exe' : 'git';
my @status = `$git status`;
#因为这个脚本 名字叫 git.perl，
#在闻到死底下，git 和 git.perl是等价的，而且，git.exe 不在 PATH里，就会出现死循环的问题。
#所以必须指定路径

if ($status[-1] =~ /nothing (added )?to commit/) {
    say '本地无更新，自动获取远程更新。';
    system $git, 'pull';
    final;
    exit;
}
@status = grep /:\s+(?!$)/, @status;
if (@status) {
    print term "文件:\n@status";
    my @diff = grep /\d+m[-+]/, `$git diff`;
    if ($^O eq 'MSWin32') {
        # 很操蛋的。闻到死底下，不支持 open ..., '|-', ...;这种形式。
        print term "差异:\n @diff";
    } else {
        my $rows = (split /\s/, `stty size`)[0];#再说了，闻到死下边也没有 `stty'.
        if (@diff < $rows) {
            print "差异:\n @diff";
        } else {
            open LESS, '|-', 'less';
            print LESS @diff;
            close LESS;
        }
    }
    say term "在提交之前。得先编辑一下提交的信息。";
    system $git, 'c'; # git c -> git commit -a
    #system 'git', 'pull';
    say term "正在把提交的内容发布到远程端。";
    system $git, 'p';#use git p instead of git push
    #git p -> git push origin HEAD
    final;
}
