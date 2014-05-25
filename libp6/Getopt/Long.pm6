use v6;
module Getopt::Long;

sub GetOptions (*%options is rw) is export
{
    my @args;
    ARG:
    while @*ARGS {
        my $arg = shift @*ARGS;
        if $arg ~~ s:P5/^--// { #:: # --abcdefg
            $arg or @args.push(@*ARGS),last; # --
            my $val;
            if ($arg ~~ rx:P5/^(.+?)=(.+)$/) {
                $arg = $0;$val = $1;
            }
            OPT1:
            for %options.kv -> $k, $v is rw {
                my ($opts,$entry) = split '=', $k;
                $opts = split '|', $opts;say $opts.perl;
                if $arg eq any(@($opts)) {
                    say "Found opt: $arg";
                    given $v {
                        when (Sub) {
                            $_();
                        }
                        when (Any) {
                            $_ = $entry ?? ($val // shift @*ARGS) !! 1;
                        }
                    }
                    say "$v";
                    last 'OPT1';
                }
                #say $v;
            }
            say %options<help>;
        } elsif $arg ~~ s:P5/^-// { #:: #-abcdefg
            my $s = split '', $arg;
            while $s {
                my $this = $s.shift;
                OPT2:
                for %options.kv -> $k, $v is rw {
                    my ($opts, $entry) = split '=', $k;
                    $opts = split '|', $opts;
                    $opts = grep rx:P5/^.$/, $opts;
                    if $this ~~ $opts {
                        given $v {
                            when (Sub) {
                                $v();
                            }
                            when (Any) {
                                if $entry {
                                    if $s { $v = join '', $s; } else { $v = shift @*ARGS; next 'ARG'; }
                                } else { $v = 1; }
                            }
                        }
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
