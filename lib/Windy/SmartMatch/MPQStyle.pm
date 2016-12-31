package Scripts::Windy::SmartMatch::MPQStyle;
use Scripts::Base;
use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/isMpqLike mpq2sm mpq2sr/;

my $mpqLikeP = qr/\[(?:name|nick|昵称|gname|群名|myname|QQ|时间段|next|r)\]|r\[\d+,\d+\]|\\(?:n|r|x0D)/;
sub isMpqLike
{
    my $text = shift;
    _utf8_on($text);
    $text =~ $mpqLikeP;
}
sub mpq2s
{
    my $text = shift;
    _utf8_on($text);
    for ($text) {
        s/\[next\]/<下讯>/g;
        s/\\n|\\r|\\x0D/<换行>/gi;
    }
    $text;
}

sub mpq2sm
{
    my $text = mpq2s shift;
    for ($text) {
        s/\[\@(\d+)\]/【艾特到$1】/g;
        s/\[时间段\]/<时间段>/g;
    }
    $text;
}
sub mpq2sr
{
    my $text = mpq2s shift;
    for ($text) {
        s/\[(?:name|nick|昵称|cknick)\]/【来讯者名】/g;
        s/\[myname\]/【我名】/g;
        s/\[(?:gname|群名)\]/【群名】/g;
        s/\[时间段\]/【时间段】/g;
        s/\[QQ\]/【来讯者id】/g;
        s/\[\@\[QQ\]\]/【来讯者名】/g;
        s{((?:\[r\])+)}<my $num = (100 ** ((length $1)/3));$num !~/[^\d]/ ? '【随机数：0,'.$num.'】' : ''>ge;
        s/r\[(\d+),(\d+)\]/【随机数：$1,$2】/g;
    }
    $text;
}
