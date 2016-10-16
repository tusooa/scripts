#!/usr/bin/env perl

use 5.012;
use Scripts::scriptFunctions;
use POSIX qw/strftime/;
#use utf8;
use File::Temp qw/tempfile/;
use Getopt::Long qw/:config gnu_getopt/;

my $addAll = 0;
my $realGit = 0;
my @args;
GetOptions ('a|add-all' => \$addAll,
    'd|debug' => \$Scripts::scriptFunctions::debug,
    'o' => sub { $realGit = 1; @args = @ARGV; @ARGV = (); }
    );
@args or @args = @ARGV;
if ($^O eq 'MSWin32') {
    say term "你的确应当用```GitHub for Windows'''这个软件。";
}
my $conf = conf 'git.perl';
my $git = $conf->get('git-exec');
$git or $git = ($^O eq 'MSWin32' ? 'C:\\Home\\usr\\Git\\bin\\git.exe' : 'git');
if ($realGit) {
    system $git, @args;
    exit;
}
my @status;
{
    local %ENV = %ENV;
    $ENV{LC_ALL} = 'C';#git变成中文的了,倒不好作了
    @status = `$git status`;
}
#因为这个脚本 名字叫 git.perl，
#在闻到死底下，git 和 git.perl是等价的，而且，git.exe 不在 PATH里，就会出现死循环的问题。
#所以必须指定路径

if ($status[-1] =~ /nothing to commit/) {
    say term '本地无更新，自动获取远程更新。';
    system $git, 'pull';
    final;
    exit;
}
#@status = grep /:\s+(?!$)/, @status;

if ($addAll) {
    system $git, 'add', '-A';
    @status = `$git status`;
}
my ($fh, $fn) = tempfile;
my @diff = `$git diff --no-color`;
my @diffCached = `$git diff --cached --no-color`;
my $content = "文件:\n@status"."差异:\n @diff @diffCached";
$content =~ s/\e\[[0-9]*[A-Za-z]//g;
$content =~ s/^/#/gm;
chomp $content;
#print $content;
say $fh '';
print $fh term $content;
#print $fh "文件:\n@status";
#print $fh "差异:\n @diff";
say term "在提交之前。得先编辑一下提交的信息。";
#$ENV{EDITOR} = 'git-edit.perl ' . $fn;
if ((system $git, 'c', '-t', $fn) == 0) { # git c -> git commit -a
    #system 'git', 'pull';
    say term "正在把提交的内容发布到远程端。";
    system $git, 'p';#use git p instead of git push
    #git p -> git push origin HEAD
    final;
} else {
    say term "没法提交。估计是提交信息留空了。再试一次吧。";
}

