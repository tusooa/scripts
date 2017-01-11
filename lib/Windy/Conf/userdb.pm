package Scripts::Windy::Conf::userdb;

use 5.018;
use Scripts::scriptFunctions;
no warnings 'experimental';
use Scripts::Windy::Util;
use Scripts::Windy::Userdb;
use Scripts::Windy::Conf::smartmatch;
use Scripts::TextAlias::Parser;
use Scripts::TextAlias qw/isVar/;
use Scripts::TextAlias::Expr;
use Scripts::Windy::SmartMatch::TextAlias;
use Scripts::Windy::SmartMatch::MPQStyle;
use Exporter;
use Data::Dumper;
use utf8;
use Encode qw/_utf8_on _utf8_off/;
sub reloadDB;
sub loadCommands;
sub reloadConfig;
sub msgSenderIsAdmin;
our @ISA = qw/Exporter/;
our @EXPORT = qw/$database/;
our $database = Scripts::Windy::Userdb->new();
my $databaseFile = $configDir.'windy-conf/userdb.db';
our $commands = {};
my @baseDB;
my $cfg = $windyConf;
loadCommands;
#debugOn;

my @adminList;
if (open my $f, '<', $configDir.'windy-conf/admin') {
    while (<$f>) {
        chomp;
        push @adminList, $_ if $_;
    }
    close $f;
}

sub loadCommands
{
    my $c = $cfg;
    $commands = {};
    for my $cmd ($c->getGroups('command')) {
        $commands->{$cmd}{priv} = [split ',', $c->get('command', $cmd, 'priv')];
        for (qw/success failure error denied/) {
            $commands->{$cmd}{$_} = sr($c->get('command', $cmd, $_));
        }
    }
}

sub getPriv
{
    my $windy = shift;
    my $msg = shift;
    my $cmd = shift;
    my @priv = @{ $commands->{$cmd}{priv} };
    my $accepted = 0;
    for (@priv) {
        when ('admin') {
            if (msgSenderIsAdmin($windy, $msg)) {
                $accepted = 1;
                last;
            }
        }
        when ('groupAdmin') {
            if (msgSenderIsGroupAdmin($windy, $msg)) {
                $accepted = 1;
                last;
            }
        }
        when (/^sense=(\d+)$/) {
            my $value = $1;
            my $sense = $subs->{senseWithMood}(undef, $windy, $msg);
            if ($sense >= $value) {
                $accepted = 1;
                last;
            }
        }
        when (/^sense(\d+)$/) {
            my $level = $1 - 1;
            my $sense = $subs->{senseWithMood}(undef, $windy, $msg);
            if ($sense > $sl[$level]) {
                $accepted = 1;
                last;
            }
        }
        when ('anyone') {
            $accepted = 1;
            last;
        }
    }
    $accepted;
}

sub runCommand
{
    my $cmd = (caller 1)[3] =~ s/.+:://r;
    my $windy = shift;
    my $msg = shift;
    my $data = shift;
    my $status;
    my @ret;
    debug "command: $cmd";
    if (getPriv($windy, $msg, $cmd)) {
        @ret = $data->{run}->();
        if ($ret[0]) {
            $status = 'success';
        } elsif (not defined $ret[0]) {
            $status = 'failure';
        } else {
            $status = 'error';
        }
    } else {
        $status = 'denied';
    }
    debug "status=$status";
    my @args;
    if (ref $data->{$status} eq 'ARRAY') {
        @args = @{$data->{$status}};
    } elsif ($data->{$status} eq 'ret') {
        @args = @ret;
    } else {
        @args = @_;
    }
    msgTAEnv($windy, $msg)->scope->var($msgMatchVN, [@args]);
    $commands->{$cmd}{$status}->run($windy, $msg, @args);
}

sub isAdmin
{
    my $windy = shift;
    my $msg = shift;
    my $id = shift;
    my @a = (@adminList, @{$windy->{Admin}}); 
    $id ~~ @a;
}

sub msgSenderIsAdmin
{
    my $windy = shift;
    my $msg = shift;
    isAdmin($windy, $msg, uid(msgSender($windy, $msg)));
}

sub start
{
    my $windy = shift;
    my $msg = shift;
    runCommand(
        $windy, $msg,
        { run => sub { $subs->{start}(undef, $windy, $msg, undef, @_) } },
        @_);
}

sub startG
{
    my $windy = shift;
    my $msg = shift;
    my ($group) = @_;
    runCommand(
        $windy, $msg,
        { run => sub { $subs->{start}(undef, undef, undef, $group, @_) } },
        @_);
}

sub stopG
{
    my $windy = shift;
    my $msg = shift;
    my ($group) = @_;
    runCommand(
        $windy, $msg,
        { run => sub { $subs->{stop}(undef, undef, undef, $group, @_) } },
        @_);
}

sub stop
{
    my $windy = shift;
    my $msg = shift;
    runCommand(
        $windy, $msg,
        { run => sub { $subs->{stop}(undef, $windy, $msg, undef, @_) } },
        @_);
}

sub callerName
{
    my $windy = shift;
    my $msg = shift;
    runCommand(
        $windy, $msg,
        { run => sub { my $name = $subs->{callerName}(undef, $windy, $msg, @_); },
          success => 'ret', },
        @_);
}

sub teach
{
    my $windy = shift;
    my $msg = shift;
    my ($ask, $ans, $style) = @_;
    runCommand(
        $windy, $msg,
        { run => sub {
            debug 'teaching:';
            debug 'ques:'.$ask;
            debug 'answ:'.$ans;
            return if !$ask or !$ans;
            my $teacher = uid(msgSender($windy, $msg));
            debug "adding";
            $windy->logger("添加「${ask}」 => 「${ans}」");
            my $q = sm({ style => $style, teacher => $teacher }, $ask);
            my $a = sr($ans)->selfParse;
            return (undef, $ask, $ans) unless $q and $a;
            $database->add([$q, $a]);
            if (open my $f, '>>', $configDir.'windy-conf/userdb.db') {
                binmode $f, ':unix';
                say $f "$style\tAsk$ask\n$teacher\tAns$ans";
            } else {
                return (0, $ask, $ans);
            }
            my (undef, $absNum) = realDBId(-1);
            my @ret = ($absNum, $ask, $ans);
            if (not msgSenderIsAdmin($windy, $msg)) {
                sendTo($windy->{mainGroup},
                       $reply{'teach-not-admin'}
                       ->run($windy, $msg,
                             $absNum, dbToString(-1)));
            }
            @ret;
          },
          success => 'ret', failure => 'ret', error => 'ret', },
        @_);
}
sub autoTeach
{
    my ($windy, $msg, $ask, $ans) = @_;
    $ask = mpq2sm($ask);
    $ans = mpq2sr($ans);
    my $tail = isTALike($ans) ? q/``reply({tail})''/ : '【$(tail)】';
    if ($ans !~ $match->{tailing}) {
        $ans = $ans.$tail;
    }
    teach($windy, $msg, $ask, $ans, 'S');
}
sub newNickname
{
    my $windy = shift;
    my $msg = shift;
    my ($nick) = @_;
    runCommand(
        $windy, $msg,
        { run => sub { $subs->{newNick}(undef, $windy, $msg, $nick) } },
        @_);
}

sub assignNickname
{
    my $windy = shift;
    my $msg = shift;
    my ($id, $nick, $sticky) = @_;
    runCommand(
        $windy, $msg,
        { run => sub { $subs->{assignNick}(undef, $windy, $msg, $id, $nick, $sticky) } },
        @_);
}

sub blackList
{
    my $windy = shift;
    my $msg = shift;
    my ($id, $status) = @_;
    runCommand(
        $windy, $msg,
        { run => sub { $subs->{blackList}(undef, $windy, $msg, $id, $status) } },
        @_);
}

sub sizeOfDB
{
    my $windy = shift;
    my $msg = shift;
    runCommand(
        $windy, $msg,
        { run => sub {
            my ($dbSize, $matchSize) = ($database->length, sizeOfMatch);
            ($dbSize - @baseDB, $matchSize, $dbSize - @baseDB + $matchSize); },
          success => 'ret',
        },
        @_);
}

sub addR
{
    my $windy = shift;
    my $msg = shift;
    my ($rep, $name) = @_;
    my $quotemeta = pop;
    runCommand(
        $windy, $msg,
        { run => sub {
            my $ret = addReplacement($name, $rep, $quotemeta); }, },
        @_);
}

sub getR
{
    my $windy = shift;
    my $msg = shift;
    my ($name) = @_;
    runCommand(
        $windy, $msg,
        { run => sub { my $rep = getReplacement($name, 'AS_IS'); ($rep, $name) },
          success => 'ret', error => 'ret', failure => 'ret' },
        @_);
}

sub reloadAll
{
    my $windy = shift;
    my $msg = shift;
    runCommand(
        $windy, $msg,
        { run => sub { reloadConfig($windy, 'ALL');
                       reloadReplacements;
                       reloadDB; }, },
        @_);
}

sub quit
{
    my $windy = shift;
    my $msg = shift;
    my $stat = pop;
    runCommand(
        $windy, $msg,
        { run => sub { if (BACKEND eq 'mojo') { $windy->{_client}->clean_qrcode;$windy->{_client}->clean_pid; exit $stat; } else { $stat; } }, },
        @_);
}
reloadDB;

sub inviteMG
{
    my $windy = shift;
    my $msg = shift;
    # 很难过。
    # 因为这个eval从来没成功过。
    runCommand(
        $windy, $msg,
        { run => sub { eval { invite($windy, $msg,
                                     group($windy, $msg, $windy->{MainGroup}),
                                     friend(msgSenderId($windy, $msg))) } },
          failure => [$windy->{MainGroup}] },
        @_);
}

### sandbook
use Scripts::Windy::Addons::Sandbook;
my $sandbook = Scripts::Windy::Addons::Sandbook->new;

sub getSandbook
{
    my $windy = shift;
    my $msg = shift;
    my ($db) = @_;
    runCommand(
        $windy, $msg,
        { run => sub {
            if ($db =~ m{^/(.+)/$}) {
                $sandbook->readByRegex($1);
            } else {
                $sandbook->read($db);
            }
          },
          success => 'ret' },
        @_);
}

sub addSandbook
{
    my $windy = shift;
    my $msg = shift;
    my ($db, $sentence) = @_;
    runCommand(
        $windy, $msg,
        { run => sub { $sandbook->addSave($db, $sentence) }, },
        @_);
}

sub repeat
{
    my $windy = shift;
    my $msg = shift;
    my ($content) = @_;
    runCommand(
        $windy, $msg,
        { run => sub { sr(mpq2sr($content))->run($windy, $msg, @_); },
          success => 'ret' },
        @_);
}

sub realDBId
{
    my $num = shift;
    my ($numNow, $realNum);
    if ($num < 0) {
        $realNum = @{$database->all} + $num;
        $numNow = $realNum - @baseDB + 1;
    } else {
        $realNum = $num + @baseDB - 1;
        $numNow = $num;
    }
    wantarray ? ($realNum, $numNow) : $realNum;
}

sub dbToString
{
    my $num = shift;
    my $realNum;
    ($realNum, $num) = realDBId $num;
    my $line = $database->all->[$realNum];
    return if ref $line ne 'ARRAY';
    my ($ask, $ans) = @{$line};
    return if ref $ans ne 'Scripts::Windy::SmartMatch::RetObject';
    my ($q, $a) = ($ask->{raw}, $ans->{raw});
    my $ret;
    given ($ask->{style}) {
        when ('S') {
            $ret = '风儿当问'.$q.'则答'.$a;
        }
        when ('s') {
            $ret = '风儿对问'.$q.'则答'.$a;
        }
        default {
            $ret = '风儿若问'.$q.'即答'.$a;
        }
    }
    nicknameById(undef, $line->[0]->{teacher})."第".$num."，".$ret;
}

sub findDB
{
    my $windy = shift;
    my $msg = shift;
    my ($where, $startFrom, $maxCount, $pattern) = @_;
    my $id = 0;
    if ($where eq '答') {
        $id = 1;
    } elsif ($where eq '问') {
        $id = 0;
    }
    my $rPattern;
    my $maxCount = $maxCount || 5;
    if ($pattern) {
        $rPattern = eval { qr/$pattern/ };
        $rPattern = qr/\Q$pattern\E/ if $@;
    }
    runCommand(
        $windy, $msg,
        { run => sub {
            return unless $pattern;
            my @found;
            my $count = -$startFrom;
            my $i = -@baseDB;
            for ($database->all) {
                $i += 1,next if $i < 0;
                if (#$pattern =~ $_->[0]->{pattern} or 
                    $_->[$id]->{raw} =~ $rPattern) {
                    $count += 1;
                    if ($count > 0) {
                        push @found, dbToString($i+1);
                    }
                }
                last if $count >= $maxCount;
                $i += 1;
            }
            ($count, join "\n", @found);
          },
          success => 'ret' },
        @_);
}

sub writeDB
{
    my $base = shift;
    my @db = $database->all;
    open my $f, '>', $databaseFile or return;
    binmode $f, ':unix';
    for ($base..$#db) {
        my ($ask, $ans) = ($db[$_]->[0], $db[$_]->[1]);
        say $f ($ask->{style}."\tAsk".$ask->{raw});
        say $f ($ask->{teacher}."\tAns".$ans->{raw});
    }
    close $f;
    1;
}

sub deleteDB
{
    my $windy = shift;
    my $msg = shift;
    my ($num) = @_;
    runCommand(
        $windy, $msg,
        { run => sub {
            my $realNum = realDBId $num;
            return unless ($database->all)[$realNum];
            my $teacher = ($database->all)[$realNum]->[0]->{teacher};
            if ((isAdmin($windy, $msg, $teacher) or not msgSenderIsAdmin($windy, $msg))
                and $teacher ne uid(msgSender($windy, $msg))) {
                return 0;
            }
            my $removed = dbToString($num);
            my $line = $num * 2 + 1;
            $database->remove($realNum);
            writeDB(scalar @baseDB);
            if (not msgSenderIsAdmin($windy, $msg)) {
                sendTo($windy->{mainGroup},
                       $reply{'delete-not-admin'}
                       ->run($windy, $msg, $removed));
            }
            ($removed);
          },
          success => 'ret', },
        @_);
}

sub queryDB
{
    my $windy = shift;
    my $msg = shift;
    my ($num) = @_;
    runCommand(
        $windy, $msg,
        { run => sub {
            dbToString($num);
          },
          success => 'ret', },
        @_);
}

sub moveDB
{
    my $windy = shift;
    my $msg = shift;
    my ($num, $to) = @_;
    runCommand(
        $windy, $msg,
        { run => sub {
            my $realNum = realDBId $num;
            my $realTo = realDBId $to;
            return (undef, $num, $to) unless ($database->all)[$realNum];
            my $moved = dbToString($num);
            $database->place($realNum, $realTo) or $moved = undef;
            writeDB(scalar @baseDB) or $moved = 0;
            ($moved, $num, $to);
          },
          success => 'ret', failure => 'ret', error => 'ret' },
        @_);
}
### Config

sub queryConf
{
    my $windy = shift;
    my $msg = shift;
    my ($text) = @_;
    my @entry = split /(?:\s+|::)/, $text;
    runCommand(
        $windy, $msg,
        { run => sub {
            my $orig = $cfg->getOrigValue(@entry);_utf8_on($orig);
            my $parsed = $cfg->get(@entry);_utf8_on($parsed);
            ($parsed, $orig, join '::', @entry);
          },
          success => 'ret', error => 'ret', failure => 'ret', },
        @_);
}
sub changeConf
{
    my $windy = shift;
    my $msg = shift;
    my ($text) = @_;
    my ($key, $val) = split /=/, $text, 2;
    my @entry = split /(?:\s+|::)/, $key;
    runCommand(
        $windy, $msg,
        { run => sub {
            my $orig = $cfg->getOrigValue(@entry);_utf8_on($orig);
            my $ro = $cfg->get('_readonly');
            if ($ro) {
                my $path = join '::', @entry;
                $val = undef if $path =~ /$ro/;
            }
            if (defined $val) {
                _utf8_off($val);
                my $success = $cfg->modify(@entry, $val);_utf8_on($val);
                if ($success) {
                    if (open my $f, '>', $configDir.$mainConf) {
                        binmode $f, ':unix';
                        print $f $cfg->outputFile;
                        close $f;
                    } else {
                        $val = undef;
                    }
                    reloadConfig($windy, @entry == 1 ? $Scripts::Configure::defg : $entry[0]); # main type
                } else {
                    $val = undef;
                }
            }
            ($val, $orig, join '::', @entry);
          },
          success => 'ret', error => 'ret', failure => 'ret', },
        @_);
}
sub queryConfGroup
{
    my $windy = shift;
    my $msg = shift;
    my ($text) = @_;
    my @entry = split /(?:\s+|::)/, $text;
    runCommand(
        $windy, $msg,
        { run => sub {
            my $tree = join ', ',
            map { $_ . ($cfg->getGroup(@entry, $_) ? '[G]' : '') } $cfg->childList(@entry);
            ($tree, join '::', @entry);
          },
          success => 'ret', error => 'ret', failure => 'ret', },
        @_);
}

## text-alias config
ta->{maxdepth} = 100;
#my $taPrint = ta->newScope();
#$taPrint->makeVar('PRINT-RESULT');
#topScope->var('print', sub {
#    my ($env, $args) = @_;
#    $taPrint->var('PRINT-RESULT', join '', $taPrint->var('PRINT-RESULT'), @$args);
#});
=comment

sub evalTA
{
    my $windy = shift;
    my $msg = shift;
    my ($text) = @_;
    runCommand($windy, $msg,
               { run => sub {
                   $taPrint->makeVar('PRINT-RESULT');
                   my $byte = ta->parse($text);
                   $byte or return (0, ta->error);
                   my ($scope, $result) = $byte->valueWithScope(topEnv);
                   (1, $taPrint->var('PRINT-RESULT'));
                 },
                 success => 'ret', error => 'ret', failure => 'ret',
               }, @_);
}

=cut

sub changeCard
{
    my $windy = shift;
    my $msg = shift;
    my ($uid, $mark, $old, $style) = @_;
    runCommand($windy, $msg,
               { run => sub {
                   #$windy->logger("uID:", $uid);
                   #$windy->logger("style:".$style);
                   my @members = $uid ? msgGroupHas($windy, $msg, $uid) : msgGroupMembers($windy, $msg);
                   my ($regex, @r, @changeTo, $rFlag);
                   if ($mark) {
                       if ($old =~ s{^/(.+)/$}{$1}) {
                           $regex = eval { qr/$old/; };
                           return (0) if $@;
                       } else {
                           $old = quotemeta $old;
                           $regex = qr/$old/;
                       }
                       my $count = 0;
                       for (@members) {
                           my $oldName = uName($_);
                           _utf8_on($oldName);
                           my $newName = $oldName =~ s/$regex/$style/r;
                           if ($oldName ne $newName) {
                               length $newName or undef $newName;
                               setGroupCard($windy, $msg, $_, $newName);
                               $count += 1;
                           }
                       }
                       return (1, $count);
                   }

                   if ((@changeTo = split /<([^>]*)>/, $style, -1) != 1) {
                       @r = @changeTo;
                       for (0..$#r) {
                           if ($_ % 2 != 0) {
                               $r[$_] = '.*';
                           } else {
                               $r[$_] = quotemeta $r[$_] unless $rFlag;
                           }
                       }
                   } else {
                       @r = ($rFlag ? quotemata $style : $style, '.*');
                       @changeTo = ($style, '*', undef);
                   }
                   $regex = join '', @r;
                   if ($rFlag) {
                       eval { $regex = qr/$regex/ };
                       return 0 if $@;
                   } else {
                       eval { $regex = qr/^$regex$/ };
                       return 0 if $@;
                   }
                   #$windy->logger("REGEX:". $regex);
                   #$windy->logger("CHANGETO:", @changeTo);
                   my $count = 0;
                   for (@members) {
                       my $oldName = uName($_);
                       #$windy->logger("OLDNAME:" . $oldName);
                       _utf8_on($oldName);
                       next if $oldName =~ $regex;
                       my $nick = Scripts::Windy::Addons::Nickname->userNickname($_);
                       my @c = @changeTo;
                       for (1..((@c-1)/2)) {
                           my $num = 2 * $_ - 1;
                           $c[$num] = $c[$num] eq '*' ? $nick : $c[$num];
                       }
                       my $newName = join '', @c;
                       setGroupCard($windy, $msg, $_, $newName);
                       #$windy->logger(uid($_).'('.$oldName.')->'.$newName);
                       $count++;
                   }
                   (1, $count);
                 },
                 success => 'ret', error => 'ret', failure => 'ret',
               }, @_);
}
sub reloadConfig
{
    my ($windy, $type) = @_;
    if ($type eq 'ALL') {
        loadCommands;
        loadConfGroup($windy, 'ALL');
    } elsif ($type eq 'command') {
        loadCommands;
    } else {
        loadConfGroup($windy, $type);
    }
}
my %cmds;
{
    no strict 'refs';
    for (qw/autoTeach start stop startG stopG blackList teach callerName sizeOfDB newNickname assignNickname repeat addR getR reloadAll quit inviteMG getSandbook addSandbook findDB deleteDB queryDB moveDB queryConf changeConf queryConfGroup evalTA changeCard/) {
        $cmds{$_} = \&{"$_"};
    }
}
topScope->var('cmd', quoteExpr sub {
    debug "执行了cmd.";
    my ($env) = @_;
    my ($windy, $msg, $command, @args) = windyMsgArgs(@_);
    #use Data::Dumper;
    debug "windy: $windy";
    debug "msg: $msg";
    debug "args: @args";
    my $word = $env->scope->var($wordVN);
    if ($word) {
        my $teacher = $word->[0]->{teacher};
        if (not isAdmin($windy, $msg, $teacher)) {
            $windy->logger("不是管理不给用cmd哦");
            return;
        }
    }
    if (isVar($command)) {
        $command = $command->{varname};
    }
    if (not $command) {
        $windy->logger("没指明是啥命令啊0 0");
        return;
    }
    my $func = $cmds{$command};
    if (not $func) {
        $windy->logger("触发了没有的命令: `${command}'。停止。");
        return;
    }
    my $match = $env->scope->var($msgMatchVN);
    @args = map { ta->getValue($_, $env); } @args;
    debug "command: $command";
    debug "match: ",@$match;
    debug "args: ",@args;
    $func->($windy, $msg, @$match, @args);
});

sub reloadDB
{
    $database->set;#(@baseDB);
    $database->{_match} = $match;
    if (open my $f, '<', $databaseFile) {
        my ($ask, $ans, $style, $id);
        my $ref;
        while (<$f>) {
            chomp;
            if (s/^(.?)\tAsk//) {
                $style = $1;
                $ask = $_;
                _utf8_on($ask);
            } elsif (s/^(\d*)\tAns//) {
                $id = $1;
                $ans = $_;
                _utf8_on($ans);
                $database->add([sm({ style => $style, teacher => $id }, $ask), sr($ans)]) if $ask and $ans;
            }
        }
        close $f;
        1;
    } else {
        debug 'cannot open';
    }
}
loadConfGroup(undef, 'ALL');
loadNicknames;
loadSense;
loadSign;
loadBlackList;
loadMood;
loadGroups;
1;
