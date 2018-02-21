=encoding utf8
=cut
=head1 NAME
    Scripts::insLisp::Parser
=cut
package Scripts::insLisp::Parser;

use Scripts::Base;
use Scripts::insLisp::Scope;
use Scripts::insLisp::Symbol;
use Scripts::insLisp::Quote;
#debugOn;

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
            'r' => sub { "\r" },
            'n' => sub { "\n" },
            't' => sub { "\t" },
            'e' => sub { "\e" },
            # \033 or so
            '(0\d{2})' => sub { chr oct shift },
            # \x1b or so
            'x([0-9A-Fa-f]{2})' => sub { chr hex shift },
            # \x{2661} or so
            'x\{([0-9A-Fa-f]{2,8})\}' => sub { chr hex shift },
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
        $r->{"$type-s"} = $type eq 'cmd'
            # need to capture the literal before command
            ? qr<\G(.*?)($allStarting)>s
            : qr<\G\s*($allStarting)>;
        # ending delim - needed for each starting delim
        for (keys %d) {
            if ($type ne 'str') {
                $r->{"$type-e-$_"} = qr<\G\s*\Q$d{$_}\E>;
            } else { # str need both starting and ending delim
                $r->{"$type-e-$_"} = qr<\G\Q$d{$_}\E>;
                $r->{"$type-s-$_"} = qr<\G\Q$_\E>;
            }
            # and, at the same time, add both delim to special charset
            $spec .= $_ . $d{$_};
        }
    }
    # special
    # add special char to its set
    $spec .= $self->{special}{$_} for qw/esc quo/;
    # quote match
    $r->{'quote'} = qr{\G\s*\Q$self->{special}{quo}\E};
    # in identifier name
    $r->{'esc-name'} = qr{\G\Q$self->{special}{esc}\E};
    # in string, deal with esc
    $r->{'esc-str'} = qr{\G\Q$self->{special}{esc}\E};
    # escape sequences
    $r->{'esc-seq'} = {};
    for (keys %{$self->{escape}}) {
        $r->{'esc-seq'}{$_} = qr/\G$_/;
    }
    # "non-special" char
    # of course, spaces are special
    $r->{'non-special'} = qr<[^\Q$spec\E\s]>;
    # num/identifier can follow such things:
    my @endings = ((values %{$self->{delim}{cmd}}), # ending of command
                   (keys %{$self->{delim}{str}}), # starting of string
                   (%{$self->{delim}{prn}}), # starting/ending of paren
                   ($self->{special}{quo}), # quote chars
        );
    my $ending = join '|', map quotemeta $_, @endings;
    # numbers
    $r->{'number'} = qr<
        \G\s*
        ( [+-]? # sign
          (?:
            [0-9,]+ # int part
            (?: [.]
              [0-9,]* )? # maybe Num
           | # or
           [.] [0-9,]+
          )
        )
        # look ahead
        (?=\s|$ending|$)
        >x;
    # identifier names
    $r->{'identifier'} = qr{
        \G\s*
        ( (?: $r->{'non-special'}
            # escaped special or non-special char
            | \Q$self->{special}{esc}\E . )+ )
        # look ahead
        (?=\s|$ending|$)
    }x;
    # nothing
    $r->{'nothing'} = qr{\G\s*$};
    $self;
}

sub parse
{
    my ($self, $text, $scope) = @_;
    my @exprs = parseText($text);
    # turn to Lambda
}

=head2 
=cut
sub parseText
{
    my ($self, $text, $pos, $state,
        $cmdDelim, $prnDelim, $depth) = @_;
    $state //= 'literal';
    $depth //= 0;
    pos($text) = $pos //= 0;
    my @list;
    my $quoteLevel = 0;
    while (1) {
        if ($state eq 'literal') {
            if ($text =~ /$self->{regex}{'cmd-s'}/gc) {
                $pos = pos($text);
                # extract the literal and go into command mode
                my $literal = $1;
                $cmdDelim = $2;
                push @list, $literal if length $literal;
                debug((' ' x $depth) . 
                    "Literal: `$literal`, entering command mode");
                $state = 'command';
            } else { # no command available
                # extract the literal and end the loop
                my $literal = substr $text, pos($text);
                push @list, $literal if length $literal;
                debug((' ' x $depth) .
                      "Literal: `$literal`, ending");
                die "Unclosed quote in the code\n" if $quoteLevel;
                die "Unclosed paren in the code\n" if $depth;
                last;
            }
        } elsif ($state eq 'command') {
            if ($text =~ /$self->{regex}{'cmd-e-'.$cmdDelim}/gc) {
                debug((' ' x $depth) .
                      'Entering literal mode');
                $state = 'literal';
            } elsif ($text =~ /$self->{regex}{'quote'}/gc) {
                $quoteLevel += 1;
                debug((' ' x $depth) .
                      'Quote: ' . $quoteLevel);
            } elsif ($text =~ /$self->{regex}{'prn-s'}/gc) {
                my $delim = $1;
                debug((' ' x $depth) .
                      "Paren: $delim");
                my $ret = $self->parseText
                    ($text, pos($text), $state, $cmdDelim,
                     $delim, $depth + 1);
                pos($text) = $ret->{'pos'};
                my $quoted = $self->parseQuote
                    ($ret->{'list'}, $quoteLevel);
                $quoteLevel = 0;
                push @list, $ret->{'list'};
            } elsif (length $prnDelim
                     and $text =~ /$self->{regex}{'prn-e-'.$prnDelim}/gc) {
                debug((' ' x $depth) .
                      'Paren end: ' . $self->{delim}{prn}{$prnDelim});
                die "Unclosed quote in the code\n" if $quoteLevel;
                last;
            } elsif ($text =~ /$self->{regex}{'number'}/gc) {
                my $num = $self->parseNumber($1);
                debug((' ' x $depth) .
                      "Number: $num");
                my $quoted = $self->parseQuote($num, $quoteLevel);
                $quoteLevel = 0;
                push @list, $num;
            } elsif ($text =~ /$self->{regex}{'identifier'}/gc) {
                my $name = $self->parseIdentifier($1);
                debug((' ' x $depth) .
                      "Identifier: $name");
                my $symbol = $self->parseQuote
                    (Scripts::insLisp::Symbol->new($name), $quoteLevel);
                $quoteLevel = 0;
                push @list, $symbol;
            } elsif ($text =~ /$self->{regex}{'str-s'}/gc) {
                my $delim = $1;
                debug((' ' x $depth) .
                      "String start: $delim");
                my $ret = $self->parseString
                    ($text, pos($text), $delim);
                my $quoted = $self->parseQuote($ret->{'str'}, $quoteLevel);
                $quoteLevel = 0;
                pos($text) = $ret->{'pos'};
                push @list, $quoted;
            } elsif ($text =~ /$self->{regex}{'nothing'}/gc) {
                debug((' ' x $depth) .
                      'Ending in command mode');
                die "Unclosed quote in the code\n" if $quoteLevel;
                die "Unclosed paren in the code\n" if $depth;
                last;
            } else {
                die 'Unexpected token `'
                    . (substr $text, pos($text), 1)
                    . "`\n";
            }
        }
    }
    { 'pos' => pos($text), 'list' => \@list };
}

sub parseNumber
{
    my ($self, $num) = @_;
    $num =~ s/,//g;
    0 + $num;
}

sub parseIdentifier
{
    my ($self, $name) = @_;
    $name =~ s/$self->{regex}{'esc-name'}(.)/$1/g;
    $name;
}

sub parseQuote
{
    my ($self, $arg, $level) = @_;
    my $ret = $arg;
    while ($level > 0) {
        $ret = quote $ret;
        $level -= 1;
    }
    $ret;
}

sub parseString
{
    my ($self, $text, $pos, $delim) = @_;
    my $endDelim = $self->{delim}{str}{$delim};
    my $balanced = $delim ne $endDelim;
    my $str = '';
    my $level = 0;
    pos($text) = $pos;
    while (1) {
        if ($text =~ /$self->{regex}{'esc-str'}/gc) {
            debug("Escape Found");
            # check next few chars
            my $found = 0;
            for (keys %{$self->{escape}}) {
                if (my @match =
                    $text =~ /$self->{regex}{'esc-seq'}{$_}/gc) {
                    $found = 1;
                    my $char = $self->{escape}{$_}->(@match);
                    debug('Escaped char ' . $_
                          . ':' . (join ' ', @match)
                          . ':' . $char);
                    $str .= $char;
                    last;
                }
            }
            if (not $found) { # add the next char
                debug('Next Char: '
                      . (substr $text, pos($text), 1));
                $str .= substr $text, pos($text), 1;
                pos($text) += 1;
            }
        } elsif (not $balanced) {
            if ($text =~ /$self->{regex}{'str-e-'.$delim}/gc) {
                debug('Normal Str Ending Delim');
                last;
            } elsif ($text =~ /\G$/gc) {
                die "Missing string end delimeter\n";
            } else {
                $str .= substr $text, pos($text), 1;
                pos($text) += 1;
            }
        } else { # balanced
            debug("This char: ".(substr $text, pos($text), 1));
            debug("st regex: $self->{regex}{'str-s-'.$delim}");
            if ($text =~ /$self->{regex}{'str-s-'.$delim}/gc) {
                debug("Start Delim: $delim");
                $level += 1;
            } elsif ($text =~ /$self->{regex}{'str-e-'.$delim}/gc) {
                debug("End Delim: $endDelim");
                last if $level == 0;
                $level -= 1;
            } elsif ($text =~ /\G$/gc) {
                die "Missing string end delimeter\n";
            } else {
                debug('Normal Char: ' . (substr $text, pos($text), 1));
                pos($text) += 1;
            }
            # in all cases we need to extract the next char
            $str .= substr $text, pos($text) - 1, 1;
        }
    }
    { 'pos' => pos($text), 'str' => $str };
}

1;
