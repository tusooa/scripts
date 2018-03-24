#!/usr/bin/env perl

use 5.012;
use Scripts::Base;
no warnings 'experimental';
use POSIX qw/strftime/;
#use utf8;
use File::Temp qw/tempfile/;
use Getopt::Long qw/:config gnu_getopt/;

my $addAll = 0;
my $realGit = 0;
my @args;

my @gitCommands = qw/  add                 grep                relink
  add--interactive    gui                 remote
  am                  gui--askpass        remote-ext
  annotate            gui--askyesno       remote-fd
  apply               gui.tcl             remote-ftp
  archive             hash-object         remote-ftps
  bisect              help                remote-http
  bisect--helper      http-backend        remote-https
  blame               http-fetch          remote-testsvn
  branch              imap-send           repack
  bundle              index-pack          replace
  cat-file            init                repo-config
  check-attr          init-db             request-pull
  check-ignore        log                 rerere
  check-mailmap       ls-files            reset
  check-ref-format    ls-remote           rev-list
  checkout            ls-tree             rev-parse
  checkout-index      mailinfo            revert
  cherry              mailsplit           rm
  cherry-pick         merge               send-email
  citool              merge-base          send-pack
  clean               merge-file          sh-i18n--envsubst
  clone               merge-index         shortlog
  column              merge-octopus       show
  commit              merge-one-file      show-branch
  commit-tree         merge-ours          show-index
  config              merge-recursive     show-ref
  count-objects       merge-resolve       stage
  credential          merge-subtree       stash
  credential-store    merge-tree          status
  credential-wincred  mergetool           stripspace
  daemon              mktag               submodule
  describe            mktree              subtree
  diff                mv                  svn
  diff-files          name-rev            symbolic-ref
  diff-index          notes               tag
  diff-tree           p4                  tar-tree
  difftool            pack-objects        unpack-file
  difftool--helper    pack-redundant      unpack-objects
  fast-export         pack-refs           update-index
  fast-import         patch-id            update-ref
  fetch               peek-remote         update-server-info
  fetch-pack          prune               upload-archive
  filter-branch       prune-packed        upload-pack
  fmt-merge-msg       pull                var
  for-each-ref        push                verify-pack
  format-patch        quiltimport         verify-tag
  fsck                read-tree           web--browse
  fsck-objects        rebase              whatchanged
  gc                  receive-pack        write-tree
  get-tar-commit-id   reflog/;


my $conf = conf 'git.perl';

my $git = $conf->get('git-exec');

$git or $git = isWindows ? 'C:\\Home\\usr\\Git\\bin\\git.exe' : 'git';

for (split /\n/, `$git config -l`) {
    m/^alias\.([^=]++)=/ or next;
    push @gitCommands, $1;
}
sub setRealGit
{
    $realGit = 1;
    @args = @ARGV;
    @ARGV = ();
}

setRealGit if isWindows and $ARGV[0] ~~ @gitCommands;

GetOptions ('a|add-all' => \$addAll,
    'd|debug' => sub { debugOn; },
    'o' => \&setRealGit,
    );
@args or @args = @ARGV;

if ($realGit) {
    system $git, @args;
    exit;
}
my @status;
{
    local %ENV = %ENV;
    $ENV{LC_ALL} = 'C';#git变成中文的了,倒不好作了
    @status = utf8 `$git status`;
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
    @status = utf8 `$git status`;
}
my ($fh, $fn) = tempfile;
my @diff = utf8 `$git diff --no-color`;
my @diffCached = utf8 `$git diff --cached --no-color`;
my $content = "文件:\n@status"."差异:\n @diff @diffCached";
$content =~ s/\e\[[0-9]*[A-Za-z]//g;
$content =~ s/^/#/gm;
chomp $content;
#print $content;
say $fh '';
print $fh utf8df $content;
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

