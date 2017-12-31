unit class Scripts::Configure;
use v6;

our $defg is export = 'main'; # default group
has $!confhash;
submethod BUILD(:$fn, :$defc)
{
    self.parseConf(:$fn, :$defc);
    self;
}
my Bool $DEBUG = False;
sub debug
{
    say "D:", |@_ if $DEBUG;
}
grammar Config
{
    token TOP { ^ <no-header> \n*
                { debug "no-header end. `{$/.postmatch}'" }
                [ <section> <.comments> ]* $ }
    rule no-header { [ <kv> ]* }
    rule section {
        { debug "section start, `{$/.postmatch}'" }
        <header>
        <.comments>
        { debug "got header: `$<header>'" }
        <kv>*
        { debug "section ENDS." }
        <.comments>
    }
    proto rule header { * }
    rule header:sym<subg> { '[' <symbol> ']:' <symbol> }
    rule header:sym<simple> { '[' <symbol> ']' }
    token symbol { <-[:\[\]\s\n]>+ }
    token string { <-[\n]>+ }
    token ws { \s* }
    rule kv { ^^
              <.comments>
              { debug "kv start" }
              <symbol> '=' <string>
              { debug "symbol: $<symbol>, string: $<string>, rest: `{$/.postmatch}'" }
              <.comments>
            }
    token comments {
        [ ^^ '#' <.string> ]*
        { debug "comment:", ~$/ if $/ }
    }
}

class ConfigParser
{
    method TOP ($/)
    {
        my @r = ($<no-header>.made, |$<section>>>.made);
        my %h;
        for (@r) {
            .value or next; # 如果组是空的，就不生成它
            if (.key.elems == 1) { # 一层分组
                %h{.key} = hash .value;
            } else { # 二层分组
                %h{.key[0]}{.key[1]} = hash .value;
            }
        }
        make %h;
    }
    method no-header ($/) { make $defg => $<kv>>>.made; }
    method section ($/)
    {
        debug "HEAD: ", $<header>.made;
        make $<header>.made => $<kv>>>.made;
    }
    method header:sym<simple> ($/) { make ~$<symbol>; }
    method header:sym<subg> ($/) { make (~$<symbol>[0], ~$<symbol>[1]); }
    method kv ($/) { make ~$<symbol> => ~$<string>; }
}

method parseConf(Str :$fn!, Str :$defc!)
{
    my Str $conf;
    debug $fn, $defc;
    my Str @files = $*DISTRO.is-win ??
    # 处理 windows 专门配置
        ($defc, $defc ~ '.windows', $fn, $fn ~ '.windows') !!
        ($defc, $fn);
    # 首次标志
    my Bool $first = True;
    for @files {
        with open $_ -> $fh {
            if $first {
                $conf = $fh.slurp;
                $first = False;
            } else {
                $conf ~= "\n[$defg]\n" ~ $fh.slurp; #默认分组。防止默认配置里原有分组，算到用户配置里去。
            }
        }
    }
    debug $conf.perl;
    $!confhash = Config.parse($conf,
                              actions => ConfigParser.new).made;
    debug "Config hash = " ~ $!confhash.perl;
    $!confhash;
}

method hash (--> Hash)
{
    %($!confhash);
}

method hashref (--> Hash)
{
    $!confhash;
}

multi method get ($entry --> Str) { $!confhash{$defg}{$entry}; }
multi method get ($group, $entry --> Str) { $!confhash{$group}{$entry}; }
multi method get ($group, $subg, $entry --> Str) { $!confhash{$group}{$subg}{$entry}; }


method runHooks ($hookName)
{
    $!confhash<Hooks> ~~ Hash or fail;
    $!confhash<Hooks>{$hookName} ~~ Hash or fail;
    for (keys $!confhash<Hooks>{$hookName})
    {
        debug "$hookName hook => $_";
        shell $!confhash<Hooks>{$hookName}{$_};
    }
}

