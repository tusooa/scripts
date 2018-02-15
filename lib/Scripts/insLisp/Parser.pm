=encoding utf8
=cut
=head1 NAME
    Scripts::insLisp::Parser
=cut
package Scripts::insLisp::Parser;

use Scripts::Base;
use Scripts::insLisp::Scope;

sub new
{
    my $class = shift;
    my $self = {
        delim => {
            cmd => { q/``/ => q/''/ },
            str => { q/{/ => q/}/, q/"/ => q/"/ },
            prn => { q/(/ => q/)/, q/[/ => q/]/ },
        },
        special => {
            esc => q/\\/,
            quo => q/_/,
        },
        escape => {
            'n' => sub { "\n" },
            't' => sub { "\t" },
            'e' => sub { "\e" },
            # \033 or so
            '0\d{2}' => sub { chr oct shift },
            # \x1b or so
            '[xX][0-9A-Fa-f]{2}' => sub { chr hex shift },
        },
        regex => {},
    };
    bless $self, $class;
    $self->genRegex;
    $self;
}

sub genRegex
{
    my $self = shift;
    my $r = $self->{regex};
    # special charset
    my $spec = '';
    # delim regex
    for my $type (qw/cmd str prn/) {
        my %d = %{ $self->{delim}{$type} };
        # generate a list of all starting delimeters
        my $allStarting = join '|',
            map quotemeta $_,
            keys %d;
        # starting delim
        # we need to capture the delim to match the ending one
        $r->{"$type-s"} = qr<\G\s*($allStarting)>;
        # ending delim - needed for each starting delim
        for (keys %d) {
            $r->{"$type-e-$_"} = qr<\G\s*$d{$_}>;
            # and, at the same time, add both delim to special charset
            $spec .= $_ . $d{$_};
        }
    }
    # add special char to its set
    $spec .= $self->{special}{$_} for qw/esc quo/;
    # misc
    # "non-special" char
    $r->{'non-special'} = qr<[^\Q$spec\E]>;
}

sub parse
{
    my ($self, $text, $scope) = @_;
    my @exprs = parseCommand($text);
    # turn to Lambda
}

=head2 
=cut
sub parseCommand
{
    my ($text, $state, $depth, $delim) = @_;
    
}

1;
