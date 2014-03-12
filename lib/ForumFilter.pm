package Scripts::ForumFilter;

use base 'Exporter';
use HTML::Entities;
use Encode qw/encode_utf8 decode_utf8/;
use 5.012;
#use Data::Dumper;
our @EXPORT = qw/parseTitleLink parseTimeAuthor parseNumber TopicNumFromLink
parseTopics filterTopic goToTopic markTopicAsRead/;
our @EXPORT_OK = ();

sub parseTitleLink
{
    my $src = shift;
    $src =~ m{<a title="发表于 :.+?" href="./(.+?)" class="topictitle">(.+?)</a>}s or return ();
    my $title = decode_entities $2;
    my $link = 'http://forum.ubuntu.org.cn/'.(decode_entities $1);
    if ($src =~ m{<b>(.+?)：</b>}s)
    {
        return () if $1 eq '置顶'; #自动忽略置顶帖
        $title = $1.":".$title;
    }
#    $title = $1.":".$title if $src =~ m{<b>(.+?)：</b>}s;
    ($title, $link);
}

sub parseTimeAuthor
{
    my $src = shift;
    $src =~ m{<p class="topicdetails" style=.+?>(.+?)</p>}s or return ();
    my $time = decode_entities $1;
    $src =~ m{<p class="topic(?:author|details)"><a href=.+?>(.+?)</a>}s or return ();
    my $author = decode_entities $1;
    ($time, $author);
}

sub parseNumber
{
    my $src = shift;
    $src =~ m{<p class="topicdetails">(\d+)</p>} or return undef;
    int $1;
}

sub forumTopicFromLink
{
    my $link = shift;
    $link =~ m{^http://forum\.ubuntu\.org\.cn/viewtopic\.php\?f=(\d+)\&t=(\d+)$} or return undef;
    ($1, $2);
}

sub parseTopics
{
    my $newTopic = {};
    my $num = 0;
    for (@_)
    {
        last if $num >= 15;
        my @tds = m{(<td class=.+?>.+?</td>)}gs;
        shift @tds; #去掉第一列的图片内容。
#        print Dumper @tds;
        my ($title, $link) = parseTitleLink $tds[0];
        my ($time, $author) = parseTimeAuthor $tds[1];
        my $replies = parseNumber $tds[2];
        my $readers = parseNumber $tds[3];
        my ($lastPostTime, $lastPostAuthor) = parseTimeAuthor $tds[4];
        my (undef, $topicNum) = forumTopicFromLink $link;
        $topicNum or next;
        my $thisTopic = {
            title => $title, link => $link,
            postTime => $time, author => $author,
            replies => $replies, readers => $readers,
            lastPostTime => $lastPostTime,
            lastPostAuthor => $lastPostAuthor,
            unread => 1,
        };
        $newTopic->{$topicNum} = $thisTopic;
        $num++;
    }
    $newTopic;
}

sub filterTopic
{
    my ($new, $old) = @_;
    if (!$old or $old->{unread} == 1
        or $new->{replies} > $old->{replies} # 有新回复
       )
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

sub goToTopic
{
    my $topic = $_[1];
#    use Data::Dumper;
#    print Dumper ($topic);
#    print $topic->{link};
    my $link = $topic->{link};
    $link =~ s/&/\\&/g;# url才不会被xdg-open转换
    system 'xdg-open', $link;
    $topic->{unread} = 0;
}

sub markTopicAsRead
{
    my $topic = shift;
    $topic->{unread} = 0;
}

1;

