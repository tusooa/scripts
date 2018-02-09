package Scripts::Windy::Addons::Title;

use 5.018;
use URL::Search qw/$URL_SEARCH_RE/;
use Exporter;
use LWP::UserAgent;
use Mojo::DOM;
our @ISA = qw/Exporter/;
our @EXPORT = qw/$urlRegex getTitle/;
our $urlRegex = $URL_SEARCH_RE;
my $lwp = LWP::UserAgent->new;#(max_size => 1024, timeout => 10);
sub getTitle
{
    my ($windy, $msg, $url) = @_;
    $url or return;
    my $res = $lwp->get($url);
    if ($res->is_success) {
        print $res->decoded_content;
        Mojo::DOM->new($res->decoded_content)->at('title')->text;
    } else {
        print "failed". $res->status_line;
        undef;
    }
}


1;
