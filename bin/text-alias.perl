#!/usr/bin/env perl

use 5.014;

my @aliasName;
my @aliasReplace;

while (<>)
{
    chomp;
    #s/^\s+//;s/\s+$//;
    #say;
    #next if /^$/;
    my $new;
    given ($_)
    {
        when (/^(#==?>\s+)/)
        {
            #say 'cmd';
            my $str = s/$1//r;
            my $command = (split /\s+/, $str)[0];
            my $args = $str =~ s/$command\s+//r;
            given ($command)
            {
                when ('alias')
                {
                    my $name = (split /=/, $args)[0];
                    push @aliasName, $name;
                    push @aliasReplace, $args =~ s/${name}=//r;
                    #say "$name, $aliases{$name}";
                }
            }
            next;
        }
        when (/^#/)
        { next; }
        default
        {
            #say 'simple';
            for my $num (0..$#aliasName)
            {
                #say $alias;
                s($aliasName[$num])($aliasReplace[$num])g;
            }
            $new = $_;
        }
    }
    say $new unless /^#/;
}
