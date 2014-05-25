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



=comment
 如下显示了这个方法怎么得来的.
tlcr: 0 2014-05-25 18:25 tusooa-laptop ~scripts perl6
● perl6 -e 'my @arr = <1 2 3 4>;say @arr'
1 2 3 4
tlcr: 0 2014-05-25 22:38 tusooa-laptop ~scripts perl6
● perl6 -e 'my $a = 5;my @arr = <<1 $a 3 4>>;say @arr'
1 5 3 4
tlcr: 0 2014-05-25 22:38 tusooa-laptop ~scripts perl6
● perl6 -e 'my $a = 5;my @arr = <<1 $a 3 4>>;say @arr;$a = 6; say @arr'
1 5 3 4
1 5 3 4
tlcr: 0 2014-05-25 22:39 tusooa-laptop ~scripts perl6
● perl6 -e 'my $a = 5;my @arr = <<1 :$a 3 4>>;say @arr;$a = 6; say @arr'
1 "a" => 5 3 4
1 "a" => 5 3 4
tlcr: 0 2014-05-25 22:39 tusooa-laptop ~scripts perl6
● perl6 -e 'my $a = 5;my @arr = <<1 $a 3 4>>;say @arr;$a = 6; say @arr' 
1 5 3 4
1 5 3 4
tlcr: 0 2014-05-25 22:39 tusooa-laptop ~scripts perl6
● perl6 -e 'my $a = 5;my @arr = <<1 $a 3 4>>;say @arr;@arr[1] := $a; $a = 6; say @arr'
1 5 3 4
1 6 3 4
tlcr: 0 2014-05-25 22:39 tusooa-laptop ~scripts perl6
● perl6 -e 'my $a = 5;my @arr = <<1 $a 3 4>>;say @arr;@arr[1] := $a;$a = 6; say @arr' 
1 5 3 4
1 6 3 4
tlcr: 0 2014-05-25 22:39 tusooa-laptop ~scripts perl6
● perl6 -e 'my $a = 5;my @arr = <<1 $a 3 4>>;say @arr;@arr[1] := $a;$a = 6;sub a (*@array is rw) {} say @arr'
===SORRY!=== Error while compiling -e
Two terms in a row
at -e:1
------> ] := $a;$a = 6;sub a (*@array is rw) {} ⏏say @arr
    expecting any of:
        statement list
        horizontal whitespace
        postfix
        infix stopper
        infix or meta-infix
        statement end
        statement modifier
        statement modifier loop
tlcr: 1 2014-05-25 22:39 tusooa-laptop ~scripts perl6
● perl6 -e 'my $a = 5;my @arr = <<1 $a 3 4>>;say @arr;@arr[1] := $a;$a = 6;sub a (*@array is rw) {}; say @arr'
1 5 3 4
1 6 3 4
tlcr: 0 2014-05-25 22:39 tusooa-laptop ~scripts perl6
● perl6 -e 'my $a = 5;my @arr = <<1 $a 3 4>>;say @arr;@arr[1] := $a;$a = 6;sub a (*@array is rw) { @array[1] = 7 }; say @arr'
1 5 3 4
1 6 3 4
tlcr: 0 2014-05-25 22:40 tusooa-laptop ~scripts perl6
● perl6 -e 'my $a = 5;my @arr = <<1 $a 3 4>>;say @arr;@arr[1] := $a;$a = 6;sub a (*@array is rw) { @array[1] = 7 };a(@arr); say @arr'
1 5 3 4
1 7 3 4
tlcr: 0 2014-05-25 22:40 tusooa-laptop ~scripts perl6
● perl6 -e 'my $a = 5;my @arr = <<1 $a 3 4>>;say @arr;@arr[1] := $a;$a = 6;sub a (*@array is rw) { @array[1] = 7 };a(@arr); say @arr;say $a;'
1 5 3 4
1 7 3 4
7
tlcr: 0 2014-05-25 22:40 tusooa-laptop ~scripts perl6
● 
tlcr: 1 2014-05-25 23:18 tusooa-laptop ~scripts perl6
● perl6 -e 'my $a = 5;my $b = 100;my @arr := ($a, $b);say @arr;$a = 6;sub a (*@array is rw) { @array[1] = 7 };a(@arr); say @arr;say $a;' 
5 100
6 7
6
tlcr: 0 2014-05-25 23:19 tusooa-laptop ~scripts perl6
● perl6 -e 'my $a = 5;my @arr := (1, $a, 3, 4);say @arr;$a = 6;sub a (*@array is rw) { @array[1] = 7 };a(@arr); say @arr;say $a;'       
1 5 3 4
1 7 3 4
7
tlcr: 0 2014-05-25 23:19 tusooa-laptop ~scripts perl6
● perl6 -e 'my $a = 5;my @arr := (1, $a, 3, 4);say @arr;$a = 6;say @arr;sub a (*@array is rw) { @array[1] = 7 };a(@arr); say @arr;say $a;'
1 5 3 4
1 6 3 4
1 7 3 4
7
=cut

