package Scripts::Windy::SmartMatch::TextAlias;
use Scripts::Base;
use Scripts::TextAlias::Parser;
use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/isTALike $condVN $patternVN $msgMatchVN $wordVN
$senseAddedVN $moodAddedVN/;

our $condVN = 'cond';
our $patternVN = 'pattern';
our $msgMatchVN = 'msg-match';
our $wordVN = '-word-';
our $senseAddedVN = 'sense-added';
our $moodAddedVN = 'mood-added';

my $taLikeR = ta->{regex}{command}{start}.'.*'.ta->{regex}{command}{end};
$taLikeR = qr/$taLikeR/;

sub isTALike
{
    my $text = shift;
    $text =~ $taLikeR;
}

1;
