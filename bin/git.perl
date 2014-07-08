#!/usr/bin/env perl

use 5.012;
use Scripts::scriptFunctions;
use POSIX qw/strftime/;

sub main;
sub edit;

use Getopt::Long qw/:config gnu_getopt/;
my $edit = $scriptName eq 'git-edit.perl';
GetOptions (
    'e|edit' => \$edit,
    'E|noedit' => sub { $edit = 0;},
    'd|debug' => \$Scripts::scriptFunctions::debug,);
$ENV{LC_ALL} = 'C';#git变成中文的了,倒不好作了
if ($^O eq 'MSWin32') {
    say term "你的确应当用```GitHub for Windows'''这个软件。";
}
my $git = $^O eq 'MSWin32' ? 'F:\\Programs\\Git\\bin\\git.exe' : 'git';
my @status = `$git status`;
#因为这个脚本 名字叫 git.perl，
#在闻到死底下，git 和 git.perl是等价的，而且，git.exe 不在 PATH里，就会出现死循环的问题。
#所以必须指定路径
debug "\$edit = $edit;";
$edit and edit or main;

sub main
{
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
        say term "在提交之前。得先编辑一下提交的信息。";
        local %ENV = %ENV;
        $ENV{EDITOR} = 'git-edit.perl';
        if ((system $git, 'c') == 0) { # git c -> git commit -a
            #system 'git', 'pull';
            say term "正在把提交的内容发布到远程端。";
            system $git, 'p';#use git p instead of git push
            #git p -> git push origin HEAD
            final;
        } else {
            say term "没法commit。估计是提交信息留空了。再试一次吧。";
        }
    }
}

sub edit
{
    my $file = shift @ARGV;
    $Scripts::scriptFunctions::debug =1;
    debug $file;
    open LOG, '>:unix', $file;
    say LOG '';
    @status = map { s/^/#/ } grep /:\s+(?!$)/, @status;
    print LOG "#文件:\n@status";
    my @diff = map { s/^/#/ } grep /\d+m[-+]/, `$git diff`;
    print LOG @diff;
    close LOG;
    exec 'emacsclient', $file;
}
