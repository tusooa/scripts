#!/usr/bin/env perl

use Scripts::scriptFunctions;
use Getopt::Long qw/:config gnu_getopt/;
use 5.014;#才能使用s///r
no if $] >= 5.018, warnings => "experimental";

my $fh;
my $file;
my $help;
GetOptions
  (
   'o|output-file=s' => \$file,
   'c|stdout' => sub { $file = '' },
   'help' => \$help,
  );

if ($help) {
    print
qq{text-alias.perl [opts] file1 [file2 ...]
-o, --output-file='' set output file instead of stdout
-c, --stdout         print to stdout
--help               what you are reading now
};
}
if ($file) {
    open $fh, '>', $file;
} else {
    $fh = 'STDOUT';
}
my @aliasName;
my @aliasReplace;
my %vars;

LINE:
while (<>) {
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
                    my $name = (split /=/, $args)[0];
                    push @aliasName, $name;
                    push @aliasReplace, $args =~ s/\Q${name}\E=//r;
                    #say "$name, $aliases{$name}";
                }
                when ('block') {
                    push @aliasName, $args;
                    my $block;
                    while (<>) {
                        last if /^#==?>\s+end-block\s+\Q$args\E$/;
                        next if /^#/;
                        $block = $block.$_;
                    }
                    chomp $block;
                    push @aliasReplace, $block;
                }
                push @ARGV, $args when 'layout';
                push @ARGV, eval $args when 'eval-layout';
                when ('eval-alias') {
                    my $name = (split /=/, $args)[0];
                    push @aliasName, $name;#say eval $args =~ s/\Q${name}\E=//r;
                    push @aliasReplace, eval $args =~ s/\Q${name}\E=//r;
                }
                when ('def-var') {
                    my $name = (split /=/, $args)[0];
                    $vars{$name} = eval $args =~ s/\Q${name}\E=//r;
                }
            }
            next LINE;
        }
        next LINE when /^#/;
        default {
            #say 'simple';
            # 注意！因为这个奇葩的特性，前边定义的alias，可以使用后边的alias，而反过来就不能。
            for my $num (0..$#aliasName)
            {
                #say $alias;
                #say "DEBUG=>$aliasName[$num],$aliasReplace[$num],line= $_";
                s(\Q$aliasName[$num]\E)($aliasReplace[$num])g;
            }
            s/{{{(.+?)}}}/eval $1/ge;#再次注意！如果使用了layout，这里的某些变量，可能会和预期的不一样。比如，$ARGV
            $fh->say ($_);
        }
    }
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
