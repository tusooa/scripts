package Scripts::Windy::Web::Util;
use base 'Exporter';
use Scripts::Base;
use List::Util qw/first/;
use Mojo::Util ();
use Encode;
our @EXPORT = qw/findIn
    convertUtf8CodePoints html_unescape
    gbkWithU8Code convertUtf8ForMpq/;

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
    my $ret = '';
    while (length $possibleCode) {
        my $first = lc substr $possibleCode, 0, 1;
        my $len;
        # look at first four bits
        # 0xxx => 1 Byte, 110x => 2B, 1110 => 3B, 1111 => 4B
        if (lc substr($possibleCode, 0, 2) eq '00') { # 00XX represented
            # ASCII char
            $len = 1; # special case; still uses 4 digits
        } elsif ($first lt 'e') {
            $len = 2;
        } elsif ($first lt 'f') {
            $len = 3;
        } else {
            $len = 4;
        }
        # two Hex digits = 1 Byte
        my $code = substr $possibleCode, 0, 2 * $len, '';
        if (hex $code == 0) { # we need to get the next code
            $code = substr $possibleCode, 0, 2 * $len, '';
        }
        if (length $code < 2 * $len) {
            $ret .= $code;
        } else {
            # turn to Unicode code points, or literal char
            # note pack expects a STRING, not NUMBER
            my $ord = ord decode_utf8 pack('H*', $code);
            my $char = $ord >= 0x10000
                # we'd better get it literally
                # since mojo-json does not support \u{xxxxx}
                ? chr $ord # here the char is utf8-on
                # turn to Unicode code points
                # in case of ctrl chars
                : sprintf '\u%04X', $ord;
            $ret .= $char;
        }
    }
    $ret . $possibleCode;
}

sub convertUtf8CodePoints
{
    my $text = shift;
    _utf8_on $text;
    $text =~ s/\\u([0-9A-F]{4,})/convertUtf8CodePoint($1)/ge;
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

sub convertUtf8ForMpq
{
    my $text = shift;
    utf8 gbkWithU8Code $text;
}

1;
