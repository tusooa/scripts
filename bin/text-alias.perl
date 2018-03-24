#!/usr/bin/env perl

use Scripts::Base;
use Getopt::Long qw/:config gnu_getopt/;
use 5.014;#才能使用s///r
no if $] >= 5.018, warnings => "experimental";

sub parseFile;
sub output;
my $debug = 0;
my $fh;
my $file;
my $help;
#say for @ARGV;die;
GetOptions
  (
   'o|output-file=s' => \$file,
   'c|stdout' => sub { $file = '' },
   'd|debug' => \$debug,
   'help' => \$help,
  );

if ($help) {
    print term
qq{text-alias.perl [opts] file1 [file2 ...]
-o, --output-file='' set output file instead of stdout
-c, --stdout         print to stdout
--help               what you are reading now
};
    exit;
}
if ($file) {
    open $fh, '>:unix', term $file;
} else {
    $fh = 'STDOUT';
}
my @aliasName;
my @aliasReplace;
my %vars;
say qq{@ARGV} if $debug;
my @text;
#@ARGV = map { term $_ } @ARGV;
parseFile shift;
output for @text;

sub parseFile
{
    my $filename = shift;
    open my $in, '<', $filename;
LINE:
    while (<$in>) {
        chomp;
        #s/^\s+//;s/\s+$//;
        #say;
        #next if /^$/;
        #my $new;
        for ($_) {
            when (/^(#==?>\s+)/) {
                #say 'cmd';
                my $str = s/$1//r;
                my $command = (split /\s+/, $str)[0];
                my $args = $str =~ s/\Q$command\E\s+//r;
                for ($command) {
                    when ('alias') {
                        say 'alias' if $debug;
                        my $name = (split /=/, $args)[0];
                        push @aliasName, $name;
                        push @aliasReplace, $args =~ s/\Q${name}\E=//r;
                        #say "$name, $aliases{$name}";
                    }
                    when ('block') {
                        say 'block' if $debug;
                        push @aliasName, $args;
                        my $block;
                        while (<$in>) {
                            last if /^#==?>\s+end-block\s+\Q$args\E$/;
                            next if /^#/;
                            $block = $block.$_;
                        }
                        chomp $block;
                        push @aliasReplace, $block;
                    }
                    when ('layout') {
                        say 'layout' if $debug;
                        parseFile $args;
                    }
                    when ('eval-layout') {
                        say 'eval-layout' if $debug;
                        parseFile eval $args;
                    }
                    when ('eval-alias') {
                        say 'eval-alias' if $debug;
                        my $name = (split /=/, $args)[0];
                        push @aliasName, $name;#say eval $args =~ s/\Q${name}\E=//r;
                        push @aliasReplace, eval $args =~ s/\Q${name}\E=//r;
                    }
                    when ('def-var') {
                        say 'def-var' if $debug;
                        my $name = (split /=/, $args)[0];
                        $vars{$name} = eval $args =~ s/\Q${name}\E=//r;
                    }
                }
                next LINE;
            }
            next LINE when /^#/;
            default {
                    say 'simple' if $debug;
                    push @text, $_;
            }
        }
    }
    close $in;
}

sub output
{
    #my $_ = shift;
    # 注意！因为这个奇葩的特性，前边定义的alias，可以使用后边的alias，而反过来就不能。
    for my $num (0..$#aliasName)
    {
        #say $alias;
        #say "DEBUG=>$aliasName[$num],$aliasReplace[$num],line= $_";
        s(\Q$aliasName[$num]\E)($aliasReplace[$num])g;
    }
    # 不要尝试在 {{{ }}} 块里做一些奇怪的事情哟。
    s/{{{(.+?)}}}/eval $1/ges;#再次注意！如果使用了layout，这里的某些变量，可能会和预期的不一样。比如，$ARGV
    $fh->say (-t $fh ? term $_ : $_);
}
=comment example
# file-- layout
#=> alias $this=FooBar
#=> eval-alias $file=$ARGV
This is @CONTENT@.
You can see something boring here.

# file-- text
#=> layout layout
#=> block @CONTENT@
hhhhhhh
say "$this";
file is `$file'
say {{{ {our $a= 'aaaaaf';++$a} }}};{{{++$a}}}
#=> end-block @CONTENT@
#=> eval-alias $file=$ARGV

# finally, the result--
● text-alias.perl text
This is hhhhhhh
say "FooBar";
file is `text'
say aaaaag;aaaaah.
You can see something boring here.

=cut
