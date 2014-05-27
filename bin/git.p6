#!/usr/bin/env perl6

use v6;
use Scripts::scriptFunctions;
use DateTime::Format;
#my $config = conf 'gitpath';

#chdir $config->get ('gitDir');
%*ENV<LC_ALL> = 'C';#git变成中文的了,倒不好作了
# bug of Rakudo
# see http://planeteria.org/perl6/
## just as I was writing this, rurban started fixing a nasty regression that made changes to %*ENV not propagate to qx (execute shell commands and return the output as a string) on Rakudo for Parrot.
my @status = qqx<git status>;say @status;
if (@status[*-1] ~~ m:P5/nothing (added )?to commit/) #fix highlight:
{
    say '本地无更新，自动获取远程更新。';
    run 'git', 'pull';
    exit;
}
@status = grep rx:P5/:\s+(?!$)/, @status; # fix highlight++
if (@status)
{
    say "文件:\n"~(join "\n",@status);
    my $rows = (split rx:P5/\s/, qqx<stty size>)[0]; # fix highlight:
    my @diff = grep rx:P5/\d+m[-+]/, qqx<git diff>; # fix highlight:
    if (@diff < $rows) {
        say "差异:\n "~(join "\n",@diff);
    } else {
        my $less = open '|less';
        $less.print(@diff);
    }
    if (!($_ = join ' ', @*ARGS))
    {
        say "本地需要提交。请输入提交的注释并回车(空注释将被日期代替):";
        $_ = $*IN.get;
    }
    if (! $_)
    {
        $_ = strftime '%Y,%-m,%-d (%u) %H,%M,%S', DateTime.now;
    }
    say "提交注释为 $_ 的更新。";
    run 'git', 'c', '-m', $_; # git c -> git commit -a
    #system 'git', 'pull';
    run 'git', 'p';#use git p instead of git push
    #git p -> git push origin master
}
