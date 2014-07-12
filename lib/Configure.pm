package Scripts::Configure;
use 5.012;
use Exporter;

our @ISA = qw/Exporter/;
our @EXPORT_OK = qw//;
our @EXPORT = qw/$defg/;
our $defg = 'main'; # default group

=comment new
my $config = Scripts::Configure->new ($file, $default);
returns:
    A Scripts::Configure object.
    check errors with $config->checkErrors.
example:
    my $config = Scripts::Configure->new ("${configDir}weather", "${defConfDir}weather");

    use Scripts::scriptFunctions;
    my $config = conf 'weather'; # 简略写法.和上边作用一样.
=cut
sub new
{
    my $class = shift;
    my $config = parseConf (@_);
    bless $config, $class;
}
#去除errors
=comment parseConf
my $ref = Scripts::Configure::parseConf (%args);
args:
    fn  filename for parsing
    fh  filehandle ``
    str string ``
    arr array(ref)
=filestyle configure
[group1]
var = val
[defgroup]:name
var = val
=cut
#my $debug = 1;
sub parseConf
{
    #print @_;
    #local @ARGV = reverse (shift, shift);
    my ($uf, $df) = @_;
    my ($user, $default, $userw, $defaultw);
    if ($^O eq 'MSWin32') {
        open $userw, '<', "${uf}.windows" or undef $userw;
        open $user, '<', $uf or undef $user;
        open $defaultw, '<', "${df}.windows" or undef $defaultw;
        open $default, '<', $df or undef $default;
    } else {
        open $user, '<', $uf or undef $user;
        open $default, '<', $df or undef $default;
    }
    my $ret = {};
    for my $fh ($default, $defaultw, $user, $userw) {
        $fh or next;
        my $group = $defg;
        my $subg;
        # 这样,在遍历每个group的时候,如果没有main,不会加进去.
        #$ret->{$group} = {};
        my $cfg;# = $ret->{$group};
        #use Data::Dumper;print Dumper ($cfg), ref($cfg);
        #say $#conf;
        while (<$fh>) {
            #say $l;
            #say $_;
            chomp;
            s/^\s+//;s/\s+$//;
            s/^#.+$//;
            next if /^$/;
#            say;
#        while (s/\\$//) # 转行
#        {
#            say "'\\' found at EOL.";
#            $l++;
#            $_ .= $conf[$l];
#        }
            if (/^\[(.+?)\]:(.+)/) { # config group
                #say 'config group';
                $group = $1;
                $subg = $2;
                $ret->{$group} or ($ret->{$group} = {});
                $ret->{$group}{$subg} or ($ret->{$group}{$subg} = {});
                $cfg = $ret->{$group}{$subg};
            } elsif (/^\[(.+?)\]/) { # simple group
                #say 'simple group: '.$1;
                $group = $1;
                $ret->{$group} or ($ret->{$group} = {});
                $cfg = $ret->{$group};
            } elsif (/^(.+?)\s*=\s*(.+)/) { # config
                #say "config:$1 = $2";
                #print Dumper ($ret), ref($cfg);
                unless ($cfg) {
                    $ret->{$group} or ($ret->{$group} = {});
                    $cfg = $ret->{$group};
                }
                $cfg->{$1} = $2;# =~ s/\$\[([^\]]+)\]/get ($ret, split '::', $1)/ger;
            }
        }
    }
    #use Data::Dumper;
    #print Dumper ($ret);
    return $ret;
}

sub hash
{
    my $self = shift;
    %{$self};
}

sub hashref
{
    my $self = shift;
    $self;
}

=comment get
$config->get ($var); # equal to $config->get ($defg, $var);
$config->get ($group, $var);
$config->get ($group, $subg, $var);
=cut
sub get
{
    my $self = shift;
    my $confhash = $self->hashref;
    my $ret;
    #my $arg = \undef; # make $$arg false
    #if (ref $_[-1]) # a ref to command line arg var.
    #{
    #    $arg = pop @_;
    #}
    if (@_ == 1) {
        $ret = $confhash->{$defg}{$_[0]};
    } elsif (@_ == 2) {
        $ret = $confhash->{$_[0]}{$_[1]};
    } elsif (@_ == 3) {
        $ret = $confhash->{$_[0]}{$_[1]}{$_[2]};
    } else {
        return undef;
    }
#    $ret =~ s/(^|[^\\])\$([a-zA-Z0-9_])/$1$main::$2/g;
#    $ret =~ s/(^|[^\\])\$\{([a-zA-Z0-9_])\}/$1$main::$2/g;
#    $ret =~ s/(^|[^\\])\$\[([a-zA-Z0-9_])\]/$1$this->{$2}/g;
    do { $ret =~ s/\${([^}]+)}/($1 eq '-') ? '$' : $ENV{$1}/ge;
         $ret =~ s/\$\[([^\]]+)\]/($1 eq '-') ? '$' : $self->get (split '::', $1)/ge; } if $ret;
    $ret;
}

sub getGroup
{
    my $confhash = shift->hashref;
    if (@_ == 1) {
        return $confhash->{$_[0]};
    } elsif (@_ == 2) {
        return $confhash->{$_[0]}{$_[1]};
    } elsif (@_ == 0) {
        return $confhash->{$defg};
    }
    undef;
}

sub getGroups
{
    my $confhash = shift->hashref;
    if (@_ == 1) {
        my $ret = $confhash->{ + shift };
        if (ref $ret eq 'HASH') {
            return keys %$ret;
        }
    } elsif (@_ == 0) {
        return keys %$confhash;
    } elsif (@_ == 2) {
        my $ret = $confhash->{ + shift }{ + shift };
        if (ref $ret eq 'HASH') {
            return keys %$ret;
        }
    }
    undef;
}

sub runHooks
{
    my ($self, $hookName) = @_;
    my $confhash = $self->hashref;
    ref $confhash->{Hooks} eq 'HASH' or return undef;
    ref $confhash->hashref->{Hooks}->{$hookName} eq 'HASH' or return undef;
    for (keys %{ $confhash->{Hooks}->{$hookName} }) {
        say "$hookName hook => $_";
        system $confhash->{Hooks}->{$hookName}->{$_};
    }
}

1;
