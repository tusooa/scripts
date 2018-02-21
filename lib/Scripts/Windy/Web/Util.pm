package Scripts::Windy::Web::Util;
use base 'Exporter';
use Scripts::Base;
use List::Util qw/first/;
use Mojo::Util ();
use Encode;
our @EXPORT = qw/findIn
    convertUtf8CodePoints html_unescape
    gbkWithU8Code/;

# findIn ARRAYREF, ATTR, VALUE
sub findIn
{
    my ($list, $attr, $val) = @_;
    wantarray ? grep { $_->{$attr} ~~ $val } @$list
        : first { $_->{$attr} ~~ $val } @$list;
}

# convertUtf8CodePoint POSSIBLE-CODE
sub convertUtf8CodePoint
{
    my $possibleCode = shift;
    my $first = lc substr $possibleCode, 0, 1;
    my $len;
    # look at first four bits
    # 0xxx => 1 Byte, 110x => 2B, 1110 => 3B, 1111 => 4B
    if ($first lt 'c') {
        $len = 1;
    } elsif ($first lt 'e') {
        $len = 2;
    } elsif ($first lt 'f') {
        $len = 3;
    } else {
        $len = 4;
    }
    # two Hex digits = 1 Byte
    my $code = substr $possibleCode, 0, 2 * $len;
    # turn to literal char
    # note pack expects a STRING, not NUMBER
    my $char = pack 'H*', $code;
    my $rest = substr $possibleCode, 2 * $len + 1;
    use Data::Dumper;
    print Dumper [$code, $char, $rest];
    decode_utf8($char.$rest);
}

sub convertUtf8CodePoints
{
    my $text = shift;
    _utf8_on $text;
    $text =~ s/\\u([0-9A-F]{2,8})/convertUtf8CodePoint($1)/ge;
    $text;
}

sub html_unescape
{
    my $text = shift;
    my $ret = Mojo::Util::html_unescape $text;
    $ret =~ s/\x{a0}/ /g;
    $ret;
}

sub gbkWithU8Code
{
    my $text = shift;
    encode 'GBK', $text, sub
    {
        # utf8 code
        my $char = encode_utf8 chr shift;
        '\u' . (uc unpack('H*', $char));
    };
}

1;
