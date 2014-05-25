class Scripts::Configure;
use v6;

our $defg is export = 'main'; # default group
has $.confhash is rw;
#method new($fn, $defc)
#{
    #$.confhash = .parseConf($fn,$defc);
#}
method parseConf(:$fn, :$defc, :$fh, :$str, :$arr)
{
    my @conf;
    if $fn {
        my (@defconf, @userconf);
        given open $defc {
            @defconf = $_.lines;
        }
        given open $fn {
            @userconf = $_.lines;
        }
        @conf = (@defconf, "[$defg]", @userconf); #默认分组。防止默认配置里原有分组，算到用户配置里去。
    } elsif $fh {
        @conf = $fh.lines;
    } elsif $str {
        @conf = split "\n", $str;
    } elsif $arr {
        @conf = @($arr);
    }
    #my $l = -1;
    my $group = $defg;
    my $subg;
    # 这样,在遍历每个group的时候,如果没有main,不会加进去.
    #$ret->{$group} = {};
    my $cfg;# = $ret->{$group};
    #use Data::Dumper;print Dumper ($cfg), ref($cfg);
    #say $#conf;
    for @conf {
        #$l++;
        #my $_ = @conf[$l];!!!-qiru8q3u4riqeowjuq
        #say $l;
        #say $_;
        s:P5/^\s+//;s:P5/\s+$//;
        s:P5/^#.+$//;
        #    jasfop!!!!
        next if /^$/;
        if m:P5/^\[(.+?)\]:(.+)/ { # config group
            #say 'config group'~$0~','~$1;
            $group = $0.Str; # in Perl 6, match group starts with $0, instead of $1.
            $subg = $1.Str;
            $.confhash{$group} = {} if !$.confhash{$group};
            $.confhash{$group}{$subg} = {} if !$.confhash{$group}{$subg};
            $cfg = $.confhash{$group}{$subg};
        } elsif m:P5/^\[(.+?)\]/ { # simple group
            #say 'simple group: '~$0;
            $group = $0.Str;
            $.confhash{$group} = {} if !$.confhash{$group};
            $cfg = $.confhash{$group};
        } elsif m:P5/^(.+?)\s*=\s*(.+)/ { # config
            #say "config:$0 = $1";
            #print Dumper ($.confhash), ref($cfg);
            unless $cfg {
                $.confhash{$group} = {} if !$.confhash{$group};
                $cfg = $.confhash{$group};
            }
            $cfg{$0.Str} = $1.Str;
        }
    }
    #use Data::Dumper;
    #print Dumper ($.confhash);
    #say "here";
    #$.confhash = $.confhash;
}

method hash
{
    %($.confhash);
}

method hashref
{
    $.confhash;
}

multi method get ($entry) { $.confhash{$defg}{$entry}; }
multi method get ($group, $entry) { $.confhash{$group}{$entry}; }
multi method get ($group, $subg, $entry) { $.confhash{$group}{$subg}{$entry}; }


method runHooks ($hookName)
{
    $.confhash<Hooks> ~~ Hash or fail;
    $.confhash<Hooks>{$hookName} ~~ Hash or fail;
    for (keys $.confhash<Hooks>{$hookName})
    {
        say "$hookName hook => $_";
        shell $.confhash<Hooks>{$hookName}{$_};
    }
}

