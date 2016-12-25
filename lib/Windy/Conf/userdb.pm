package Scripts::Windy::Conf::userdb;

use 5.018;
use Scripts::scriptFunctions;
no warnings 'experimental';
use Scripts::Windy::Util;
use Scripts::Windy::Userdb;
use Scripts::Windy::Conf::smartmatch;
use Scripts::TextAlias::Parser;
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
#sub debug { print @_; }
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
    my @args;
    if (ref $data->{$status} eq 'ARRAY') {
        @args = @{$data->{$status}};
    } elsif ($data->{$status} eq 'ret') {
        @args = @ret;
    } else {
        @args = @_;
    }
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
        { run => sub { if (BACKEND eq 'mojo') { exit $stat; } else { $stat; } }, },
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
        { run => sub { sr($content)->run($windy, $msg, @_); },
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
    my ($uid, $style) = @_;
    runCommand($windy, $msg,
               { run => sub {
                   #$windy->logger("uID:", $uid);
                   #$windy->logger("style:".$style);
                   my @members = $uid ? msgGroupHas($windy, $msg, $uid) : msgGroupMembers($windy, $msg);
                   my ($regex, @r, @changeTo, $rFlag);
                   if ($style =~ s{^/(.+)/$}{$1}) {
                       $rFlag = 1;
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
                       @changeTo = ($style, undef, undef);
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

sub reloadDB
{
    @baseDB = (
        [sm('【不是讯息】'), sr('【截止:不是讯息】')],
        [smS(qr/【对我】出来/), \&start],
        [sm("【不是私讯而且不是群讯开启】"), sr("【截止:没开启】")],
        [smS(qr/【对我或者私讯】<不要>理睬?(\d+)/), sub { blackList(@_, 1); }],
        [smS(qr/【对我或者私讯】<不要>不理睬?(\d+)/), sub { blackList(@_, 0); }],
        [sm("【被屏蔽】"), sr("【截止:被屏蔽】")],
        [smS(qr/【对我】回去/), \&stop],
        [smS(qr/<_风妹_><中>当问(.+?)则答(.+)$/), sub { teach(@_, 'S'); }],
        [smS(qr/<_风妹_><中>被问到(.+?)时回答(.+)$/), sub { $_[3] = $_[3].'【$(tail)】'; teach(@_, 'S'); }],
        [smS(qr/<_风妹_><中>对问(.+?)则答(.+)$/), sub { teach(@_, 's'); }],
        [smS(qr/【对我】<怎么>出来/), \&callerName],
        [smS(qr/【对我或者私讯】<知道><多少>/), \&sizeOfDB],
        [smS(qr/<_我名_><中>若问(.+?)即答(.+)$/s), \&teach],
        [smS(qr/<_我名_><中>问(.+?)答(.+)$/s), sub { $_[2] = '^'.$_[2].'$'; teach(@_); }],
        [smS(qr/<_我名_><中>(?:<以后>)?<称呼><我>(?:作|为|叫)?(.+?)(?:<就好>)?$/), \&newNickname],
        [smS(qr/<_我名_><中>(?:<以后>)?<称呼>(\d+)(?:作|为|叫)?(.+?)(?:<就好>)?$/), \&assignNickname],
#        [smS(qr/<_风妹_><中>(?:<以后>)?一直都?<称呼>(\d+)(?:作|为|叫)?(.+?)(?:<就好>)?$/), sub { assignNickname @_, 1; }],
        [sm(qr/^喵 复述(.+)$/), \&repeat],
        [smS(qr/<_我名_><中>(?:<以后>)?<记得>(.+?)(也|亦)是(.+)$/),
         sub {
             my ($windy, $msg, $rep, $mode, $name) = @_;
             addR($windy, $msg, $rep, $name, $mode eq '也' ? 0 : 1);
         }],
#        [smS(qr/<_风妹_><中>(?:<以后>)?<记得>(.+?)亦是(.+)$/), sub { addR(@_, 1); }],
        [smS(qr/<_我名_><中><什么><是>(.+)$/), \&getR],
        [smS(qr/【对我或者私讯】重生/), \&reloadAll],
        [smS(qr/【对我或者私讯】天降于?(?:欢迎加入.+?，群号码：)?(\d+)/), \&startG],
        [smS(qr/【对我或者私讯】消失于?(?:欢迎加入.+?，群号码：)?(\d+)/), \&stopG],
        [smS(qr/【对我或者私讯】以神之名义命令<中>重生/), sub { quit(@_, 1); }],
        [smS(qr/【对我或者私讯】主群拉<一下>/), \&inviteMG],
        [sm(qr/^沙书\s*(.*?)\s*$/), \&getSandbook],
        [smS(qr/<_我名_><中>加一?句(.+?)「(.+)」$/s), \&addSandbook],
        [smS(qr/【对我或者私讯】来扫个码/), sub { quit(@_, 0); }],
        [smS(qr/<_我名_><中>(?:在(问|答)里)?(?:从(\d+))?找(?:一下|(\d+)个)(.+)$/), \&findDB],
        [smS(qr/【对我或者私讯】<删><中>第(\d+)/), \&deleteDB],
        [smS(qr/【对我或者私讯】第(-?\d+)条?<是><什么>/), \&queryDB],
        [smS(qr/【对我或者私讯】把第?(\d+)条?放[到在去]第?(\d+)/), \&moveDB],
        [sm(qr/^wconf\s+g\s+(.+)$/), \&queryConf],
        [sm(qr/^wconf\s+s\s+([^=]+=.*)$/), \&changeConf],
        [sm(qr/^wconf\s+l\s+(.*)$/), \&queryConfGroup],
        [smS(qr/<_我名_><中>把(?:(\d+)|<所有人>)改(?:成|作)(.+)$/), \&changeCard],
        #[sm(qr/^eval\s*(.+)$/s), \&evalTA],
        );
    $database->set(@baseDB);
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
1;
