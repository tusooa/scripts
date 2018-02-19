package Scripts::Windy::Web::Util;
use base 'Exporter';
use Scripts::Base;
use List::Util qw/first/;
our @EXPORT = qw/findIn/;

sub findIn
{
    my ($list, $attr, $val) = @_;
    wantarray ? grep { $_->attr($attr) ~~ $val } @$list
        : first { $_->attr($attr) ~~ $val } @$list;
}

1;
