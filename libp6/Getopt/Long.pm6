use v6;
module Getopt::Long;

sub set-arg ($arg is rw, $value)
{
    given $arg {
        when (Sub|Block) { $_() }
        when Bool { $_ = True }
        default { $_ = $value() }
    }
}

sub GetOptions (*@options is rw) is export
{
    my @args;
    ARG: while @*ARGS {
        my $arg = shift @*ARGS;
        if $arg ~~ s:P5/^--// { #:: # --abcdefg
            $arg or @args.push(@*ARGS),last; # --
            my $val = '' but False;
            if ($arg ~~ m:P5/^(.+?)=(.*)$/) { #:
                $arg = $0.Str;
                $val = $1.Str but True;#say $val.perl;
                #if ($val ~~ Failure) { $val = '' }
            }
            OPT1: for @options -> $k, $v is rw {
                if $arg ~~ $k {
                    #say "Found opt: $arg";
                    set-arg $v, $val ?? { $val } !! { shift @*ARGS };
                    #say "$v";
                    last 'OPT1';
                }
                #say $v;
            }
        } elsif $arg ~~ s:P5/^-// { #:: #-abcdefg
            my $s = split '', $arg;
            while $s {
                my $this = $s.shift;
                OPT2: for @options -> $k, $v is rw {
                    if $this ~~ $k {
                        set-arg $v, $s ?? { my $str = join '', @($s);$s = ''; $str } !! { shift @*ARGS; };
                        last 'OPT2';
                    }
                }
            }
        } else { # arg
            @args.push($arg);
        }
    }
    @*ARGS = @args;
}


