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

sub readLine
{
    my $orig = shift;
    local ($_);
    $_ = $orig;
    chomp;
    s/^\s+//;s/\s+$//;
    s/^#.+$//;
    if (/^$/) {
        ($orig, 'comment');
    } elsif (/^\[(.+?)\]:(.+)/) { # config group
        ($orig, 'confg', $1, $2);
    } elsif (/^\[(.+?)\]/) { # simple group
        ($orig, 'simple', $1);
    } elsif (/^(.+?)\s*=\s*(.+)/) { # config
        ($orig, 'conf', $1, $2);
    }
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
            my (undef, $result, @match) = readLine $_;
            next if $result eq 'comment';
#            say;
#        while (s/\\$//) # 转行
#        {
#            say "'\\' found at EOL.";
#            $l++;
#            $_ .= $conf[$l];
#        }
            if ($result eq 'confg') { # config group
                #say 'config group';
                $group = $match[0];
                $subg = $match[1];
                $ret->{$group} or ($ret->{$group} = {});
                $ret->{$group}{$subg} or ($ret->{$group}{$subg} = {});
                $cfg = $ret->{$group}{$subg};
            } elsif ($result eq 'simple') { # simple group
                #say 'simple group: '.$1;
                $group = $match[0];
                $ret->{$group} or ($ret->{$group} = {});
                $cfg = $ret->{$group};
            } elsif ($result eq 'conf') { # config
                #say "config:$1 = $2";
                #print Dumper ($ret), ref($cfg);
                unless ($cfg) {
                    $ret->{$group} or ($ret->{$group} = {});
                    $cfg = $ret->{$group};
                }
                $cfg->{$match[0]} = $match[1];# =~ s/\$\[([^\]]+)\]/get ($ret, split '::', $1)/ger;
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

sub getOrigValue : lvalue
{
    my $self = shift;
    my $confhash = $self->hashref;
    if (@_ == 1) {
        $confhash->{$defg}{$_[0]};
    } elsif (@_ == 2) {
        $confhash->{$_[0]}{$_[1]};
    } elsif (@_ == 3) {
        $confhash->{$_[0]}{$_[1]}{$_[2]};
    }
}
sub modify # 似乎并没有用
{
    my $self = shift;
    my $value = pop;
    $self->getOrigValue(@_) = $value;
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
    my $ret = $self->getOrigValue (@_);
#    $ret =~ s/(^|[^\\])\$([a-zA-Z0-9_])/$1$main::$2/g;
#    $ret =~ s/(^|[^\\])\$\{([a-zA-Z0-9_])\}/$1$main::$2/g;
#    $ret =~ s/(^|[^\\])\$\[([a-zA-Z0-9_])\]/$1$this->{$2}/g;
    do { $ret =~ s/\$\{([^}]+)}/($1 eq '-') ? '$' : $ENV{$1}/ge;
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
