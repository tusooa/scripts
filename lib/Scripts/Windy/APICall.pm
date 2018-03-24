package Scripts::Windy::APICall;

use 5.012;
use Mojo::UserAgent;
use Exporter;
use Scripts::Base;
use Encode qw/encode decode _utf8_on _utf8_off/;
use utf8;
use Mojo::JSON qw/encode_json decode_json from_json to_json/;
our @ISA = qw/Exporter/;
our @EXPORT = qw/callApi/;
my $callAddr = "http://127.0.0.1:7456/api/call";
my $ua = Mojo::UserAgent->new;
sub callApi
{
    my $json = { seq => [] };
    for (@_) {
        my $this = {};
        my @line = @$_;
        $this->{func} = shift @line;
        $this->{args} = [@line];
        push @{$json->{seq}}, $this;
    }
    my $send = term to_json($json);
    say $send;
    my $tx = $ua->post($callAddr => $send);
    if (my $res = $tx->success) {
        my $orig = utf8 $res->body;
        #_utf8_off $orig;
        my $json = from_json $orig;
        use Data::Dumper;
        say Dumper($json);
        wantarray ? @{$json->{seq}} : $json->{seq};
    }
    else {
        my $err = $tx->error;
        say "$err->{code} response: $err->{message}" if $err->{code};
        say "Connection error: $err->{message}";
        undef;
    }
}
1;
