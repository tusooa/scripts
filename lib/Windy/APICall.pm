package Scripts::Windy::APICall;

use 5.012;
use Mojo::UserAgent;
use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/callApi/;

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
    use Data::Dumper;
    print Dumper($json);
=comment
    my $tx = $ua->post('https://metacpan.org/search' => json => $json);
    if (my $res = $tx->success) { say $res->body }
    else {
        my $err = $tx->error;
        die "$err->{code} response: $err->{message}" if $err->{code};
        die "Connection error: $err->{message}";
    }
=cut
}
1;
