package Scripts::Configure;
require Exporter;

use 5.012;

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
    my $file = shift;
    my $default = shift;
    my ($config,$errors) = parseConf (
        fn => $file,
        defc => $default,
    );
    bless [$config,$errors], $class;
}
my %errors = (
    0 => "No errors.",
    1 => "Not enough args.",
);

=comment parseConf
my $ref = Scripts::Configure::parseConf (%args);
args:
    fn  filename for parsing
    fh  filehandle ``
    str string ``
    arr array(ref)
    defc if file not found, use it
returns:
    @array = ($hashRef, $errors)
example:
    my ($conf, $errors) = Scripts::Configure::parseConf (
    fn => "${configDir}weather",
    defc => "${defConfDir}weather",
    );
=cut
=filestyle configure
[group1]
var = val
[defgroup]:name
var = val
=cut
#my $debug = 1;
sub parseConf
{
    my %args = (@_);
    my @conf;
    my $errors = [0];
    if ($args{fn})
    {
        my (@defconf, @userconf);
        if (open my $fh, '<', $args{defc})
        {
            @defconf = <$fh>;
            close $fh;
        }
        if (open my $fh, '<', $args{fn})
        {
            @userconf = <$fh>;
            close $fh;
        }
        @conf = (@defconf, "[$defg]", @userconf); #默认分组。防止默认配置里原有分组，算到用户配置里去。
    }
    elsif ($args{fh})
    {
        my $fh = $args{fh};
        @conf = <$fh>;
    }
    elsif ($args{str})
    {
        @conf = split "\n", $args{str};
    }
    elsif ($args{arr})
    {
        @conf = @{$args{arr}};
    }
    else
    {
        $errors = [1];
        return (undef, $errors);
    }
    #say @conf;
    # parse @conf
    my $ret = {};
    my $l = -1;
    my $group = $defg;
    my $subg;
    # 这样,在遍历每个group的时候,如果没有main,不会加进去.
    #$ret->{$group} = {};
    my $cfg;# = $ret->{$group};
    #use Data::Dumper;print Dumper ($cfg), ref($cfg);
    #say $#conf;
    while ($l < $#conf)
    {
        $l++;
        $_ = $conf[$l];
        #say $l;
        #say $_;
        chomp;
        s/^\s+//;s/\s+$//;
        s/^#.+$//;
        next if /^$/;
#        while (s/\\$//) # 转行
#        {
#            say "'\\' found at EOL.";
#            $l++;
#            $_ .= $conf[$l];
#        }
        if (/^\[(.+?)\]:(.+)/) # config group
        {
            #say 'config group';
            $group = $1;
            $subg = $2;
            $ret->{$group} or ($ret->{$group} = {});
            $ret->{$group}{$subg} or ($ret->{$group}{$subg} = {});
            $cfg = $ret->{$group}{$subg};
        }
        elsif (/^\[(.+?)\]/) # simple group
        {
            #say 'simple group: '.$1;
            $group = $1;
            $ret->{$group} or ($ret->{$group} = {});
            $cfg = $ret->{$group};
        }
        elsif (/^(.+?)\s*=\s*(.+)/) # config
        {
            #say "config:$1 = $2";
            #print Dumper ($ret), ref($cfg);
            unless ($cfg)
            {
                $ret->{$group} or ($ret->{$group} = {});
                $cfg = $ret->{$group};
            }
            $cfg->{$1} = $2;
        }
    }
    #use Data::Dumper;
    #print Dumper ($ret);
    return ($ret, $errors);
}

sub hash
{
    my $self = shift;
    %{$self->[0]};
}

sub hashref
{
    my $self = shift;
    $self->[0];
}

=comment get
$config->get ($var); # equal to $config->get ($defg, $var);
$config->get ($group, $var);
$config->get ($group, $subg, $var);
=cut
sub get
{
    my $self = shift;
    my $confhash;
    %$confhash= $self->hash;
    my $ret;
    #my $arg = \undef; # make $$arg false
    #if (ref $_[-1]) # a ref to command line arg var.
    #{
    #    $arg = pop @_;
    #}
    if (@_ == 1)
    {
        return $confhash->{$defg}{$_[0]};
    }
    elsif (@_ == 2)
    {
        return $confhash->{$_[0]}{$_[1]};
    }
    elsif (@_ == 3)
    {
        return $confhash->{$_[0]}{$_[1]}{$_[2]};
    }
    else
    {
        return undef;
    }
#    $ret =~ s/(^|[^\\])\$([a-zA-Z0-9_])/$1$main::$2/g;
#    $ret =~ s/(^|[^\\])\$\{([a-zA-Z0-9_])\}/$1$main::$2/g;
#    $ret =~ s/(^|[^\\])\$\[([a-zA-Z0-9_])\]/$1$this->{$2}/g;
    return $ret;
}

sub runHooks
{
    my ($self, $hookName) = @_;
    ref $self->[0]->{Hooks} eq 'HASH' or return undef;
    ref $self->[0]->{Hooks}->{$hookName} eq 'HASH' or return undef;
    for (keys %{ $self->[0]->{Hooks}->{$hookName} })
    {
        say "$hookName hook => $_";
        system $self->[0]->{Hooks}->{$hookName}->{$_};
    }
}

1;
