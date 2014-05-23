#!/usr/bin/env perl

use 5.012;
use Scripts::scriptFunctions;
use WWW::Mechanize;
use utf8; #文件名才可以使用中文.
use Encode qw/encode_utf8 decode_utf8/;
use Gtk2 qw/-init/;
use Scripts::ForumFilter;

open FILE, '<', "${accountDir}ubuntu-forum" or die "不能打开密码文件: $!\n";
chomp (my ($username, $password) = <FILE>);
close FILE;

my $mech = WWW::Mechanize->new (agent => 'forum-filter.perl');
my $useProxy = $ENV{NO_PROXY} ? 0 : 1;
my $forumAddress = 'http://forum.ubuntu.org.cn/';
my $loginAddress = 'http://forum.ubuntu.org.cn/ucp.php?mode=login';
$mech->get ($loginAddress);
$mech->submit_form (
    form_number => 2,
    fields => { username => $username, password => $password },
    button => 'login',
);
unless ($mech->success)
{
    die "登录出错\n";
}
#print $mech->content;
my $builder = Gtk2::Builder->new;
$builder->add_from_file (decode_utf8 "${dataDir}forum-filter.glade");
my $window = $builder->get_object ('window1');
my $mainBox = $builder->get_object ('box1');
my $topBox = $builder->get_object ('box4');
#my $topBoxTopAlign = $builder->get_object ('alignment2');
my $secondBox = Gtk2::HBox->new;
for (qw/b i u quote code img url/)
{
    my $button = Gtk2::Button->new ($_);
    $button->signal_connect (clicked => \&insert, $_);
    $secondBox->add ($button);
}

$topBox->add ($secondBox);
$topBox->reorder_child ($secondBox, 0);
$topBox->set_child_packing ($secondBox, 0, 0, 0, 'GTK_PACK_START');

my $textview = $builder->get_object ('textview1');
my $buffer = $textview->get_buffer;
#my $buffer = Gtk2::TextBuffer->new;
#my $textview = Gtk2::TextView->new_with_buffer ($buffer);
#$mainBox->add ($textview);

my $forumEntry = $builder->get_object ('entry1');
my $pageEntry = $builder->get_object ('entry2');
my $showAllCheck = $builder->get_object ('checkbutton1');

my %forumTopic = (); # forum-number => {}
my $nowTopic = {};

sub filter
{
    my $newTopic = shift;
    my $forumNumber = shift;
    if (!$forumTopic{$forumNumber})
    {
        return $newTopic;
    }
    else
    {
        my $oldTopic = $forumTopic{$forumNumber};
        my $ret = {};
        for (keys %$newTopic)
        {
            if (filterTopic $newTopic->{$_}, $oldTopic->{$_})
            {
                $ret->{$_} = $newTopic->{$_};
            }
        }
        return $ret;
    }
}

sub createLine
{
    my $topic = shift;
    my $topicBox = Gtk2::HBox->new;
    my $title = decode_utf8 $topic->{title};
    $title =~ s/(.{50})/$1\n/g;
    chomp $title;
    my $text = (encode_utf8 $title)." | ".$topic->{postTime}." | ".$topic->{author}." | ".$topic->{lastPostTime}." | ".$topic->{lastPostAuthor};
    my $label = Gtk2::Label->new (decode_utf8 $text);
    my $goButton = Gtk2::Button->new ('G');
    $goButton->signal_connect (clicked => \&goToTopic, $topic);
    my $readButton = Gtk2::Button->new ('R');
    $readButton->signal_connect (clicked => \&markTopicAsRead, $topic);
    for ($label, $goButton, $readButton)
    {
        $topicBox->add ($_);
        #print ref $_;
        my $yesNo = ref $_ eq 'Gtk2::Label';
        $topicBox->set_child_packing ($_, $yesNo, $yesNo, $yesNo, 'GTK_PACK_START');
    }
    $topicBox;
}

my $relative0 = qr/^不到 1 分钟前$/;
my $relative1 = qr/^(\d+) (分钟|小时)前$/;
my $relative2 = qr/^(今|昨)天 (\d{1,2}):(\d{2}) (am|pm)$/;
my $date = qr/^(\d{4})-(\d{1,2})-(\d{1,2}) (\d{1,2}):(\d{2}) (am|pm)$/;
sub byLastPost #乱排，谁知道原理
{
    my $first = decode_utf8 $nowTopic->{$a}->{lastPostTime};#encode_utf8 $a;
    my $second = decode_utf8 $nowTopic->{$b}->{lastPostTime};#encode_utf8 $b;
    #print "$first $second \n";
    #my $aTop = ($nowTopic->{$a}->{title} =~ /^置顶/);
    #my $bTop = ($nowTopic->{$b}->{title} =~ /^置顶/);
    #my $topCmp = $bTop <=> $aTop;
    #return $topCmp if $topCmp;
    
    if ($first =~ $relative0)
    {
        if ($second =~ $relative0)
        {
            return 0;
        }
        else
        {
            return -1;
        }
    }
    if ($first =~ $relative1)
    {
        my $aMinute = $1 * ($2 eq '小时' ? 60 : 1);
        if ($second =~ $relative0)
        {
            return 1;
        }
        elsif ($second =~ $relative1)
        {
            my $bMinute = $1 * ($2 eq '小时' ? 60 : 1);
            return $aMinute <=> $bMinute;
        }
        else
        {
            return -1;
        }
    }
    elsif ($first =~ $relative2)
    {
        my $aToday = $1 eq '今';
        my $aHour = $2+12*($4 eq 'pm');
        my $aMinute = $3;
        if ($second =~ $relative0 || $second =~ $relative1)
        {
            return 1;
        }
        elsif ($second =~ $relative2)
        {
            my $bToday = $1 eq '今';
            my $bHour = $2+12*($4 eq 'pm');
            my $bMinute = $3;
            return $aToday <=> $bToday || $aHour <=> $bHour
                || $aMinute <=> $bMinute;
        }
        else
        {
            return -1;
        }
    }
    elsif ($first =~ $date)
    {
        my @aDate = ($1, $2, $3, $4+12*($6 eq 'pm'), $5);
        if ($second =~ $date)
        {
            my @bDate = ($1, $2, $3, $4+12*($6 eq 'pm'), $5);
            for (0..4)
            {
                my $result = $aDate[$_] <=> $bDate[$_];
                return $result if $result;
            }
            return 0;
        }
        else
        {
            return 1;
        }
    }
    else
    {
        #return 0;
        die "未知的时间类型: $first\n";
    }
}

sub showUi
{
    my $topic = shift;
    
    for ($mainBox->get_children)
    {
        if (ref $_ eq 'Gtk2::VBox' and $_ != $topBox)
        {
            $mainBox->remove ($_);
            last;
        }
    }
    my $forumBox = Gtk2::VBox->new;
    for (sort byLastPost keys %$topic)
    {
        #my $topicBox = Gtk2::HBox->new;
        my $topicBox = createLine $topic->{$_};
        #$topicBox->add ($text);
        #$topicBox->add ($button);
        $forumBox->add ($topicBox);
    }
    $mainBox->add ($forumBox);
    $mainBox->reorder_child ($forumBox, 1);
    $mainBox->set_child_packing ($forumBox, 0, 0, 0, 'GTK_PACK_START');
    $forumBox->show_all;
}

sub showForum
{
    my $forum = int $forumEntry->get_text;
    my $start = int $pageEntry->get_text;
    $start = 1 if $start <= 0;
    $start -= 1;
    my $showAll = $showAllCheck->get_mode;
    $mech->get ($forumAddress.'viewforum.php?f='.$forum.
                ($start ? '&start='.$start : ''));
    my $content = $mech->content; #不encode才可以成功匹配
    #say $content;
    $content =~ s{^.+<td class="row3" colspan="6"><b class="gensmall">主题</b></td>.+?</tr>}{}s;
    $content =~ s{<tr align="center">.+$}{}s; #去掉头尾无用信息
    $content = encode_utf8 $content;
#    use Data::Dumper;
#    say $content;
    my @topics = ($content =~ m{<tr>(.+?)</tr>}gs);
#    say Dumper @topics;
    my $parsed = parseTopics @topics;
    #say Dumper $parsed;
    my $rest = $showAll ? $parsed : filter $parsed, $forum;
    $forumTopic{$forum} = $rest;
    $nowTopic = $forumTopic{$forum};
    showUi $rest;
}

sub insert
{
    my $tag = $_[1];
    my $header = "[$tag]";
    my $footer = "[/$tag]";
    #my ($header, $footer) = @{$_[1]};
    my ($start, $end) = $buffer->get_selection_bounds;
    my $currentText = '';
    if ($start != $end)
    {
        $currentText = $buffer->get_text ($start, $end, 0);
        $buffer->delete_selection (0, 1);
    }
    $buffer->insert_at_cursor ($header.$currentText.$footer);
}

sub quit
{
    Gtk2->main_quit;
}

$builder->connect_signals;

$window->show_all;

Gtk2->main;

