#!/usr/bin/env perl
use LWP::UserAgent;
use 5.012;
use Mojo::JSON qw(encode_json decode_json);
my $ua = LWP::UserAgent->new;
my $json = encode_json { func => 'Api_SendMsg', args => ['3529608488', 2, 0, '424214662', '0', '0 0 0']};
my $res = $ua->post('http://127.0.0.1:7456/api/call', Content=>$json);
if ($res->is_success) {
    print $res->decoded_content;
} else {
    print $res->status_line;
}
