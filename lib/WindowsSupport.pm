package Scripts::WindowsSupport;
use 5.012;
use Exporter;
use Encode qw/encode decode/;

our $VERSION = 0.1;
our @ISA = qw/Exporter/;
our @EXPORT_OK = qw//;
our @EXPORT = qw/%winFunc/;

our %winFunc = (
            ln => sub {
                my ($target, $name) = @_; # use windows-style path
                $target =~ s</><\\>g;
                $name =~ s</><\\>g;
                my @args;
                @args = ('/D') if -d $target;
                system 'mklink', @args, $name, $target;
            },
            term => sub {
                my $str = join '', @_;
                my $ret;
                eval { $ret = encode 'euc-cn', decode 'utf-8', $str };
                eval { $ret = encode 'euc-cn', $str } if $@;
                die "error: $@, @_" if $@;
                $ret;
            }
);
