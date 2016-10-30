package Scripts::Configure;
use 5.012;
use Exporter;
no warnings 'experimental';

our @ISA = qw/Exporter/;
our @EXPORT_OK = qw//;
our @EXPORT = qw/$defg/;
our $defg = 'main'; # default group
my $sortName = '_sort';
=comment new
my $config = Scripts::Configure->new ($file, $default);
    my $config = Scripts::Configure->new ("${configDir}weather", "${defConfDir}weather");
    use Scripts::scriptFunctions;
    my $config = conf 'weather'; # 简略写法.和上边作用一样.
=cut
sub new
{
    my $class = shift;
    my $config = { Conf => {}, Sort => {} };
    bless $config, $class;
    $config->parseConf (@_);
    $config;
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
=comment parseConf
my $ref = Scripts::Configure::parseConf (user-config, default-config);
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
    my ($self, $uf, $df) = @_;
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
    for my $fh ($default, $defaultw, $user, $userw) {
        $fh or next;
        my @this;
        while (<$fh>) {
            #say $l;
            #say $_;
            my (undef, $result, @match) = readLine $_;
            next if $result eq 'comment';
            if ($result eq 'confg') { # config group
                #say 'config group';
                @this = ($match[0], $match[1]);
            } elsif ($result eq 'simple') { # simple group
                #say 'simple group: '.$1;
                @this = $match[0];
            } elsif ($result eq 'conf') { # config
                #say "config:$1 = $2";
                $self->modify(@this, $match[0], $match[1]);
            }
        }
    }
    $self;
}

sub hash
{
    my $self = shift;
    %{$self->hashref};
}

sub hashref
{
    my $self = shift;
    $self->{Conf};
}

sub origValue : lvalue
{
    my $self = shift;
    my $confhash = $self->hashref;
    my $sorthash = $self->sortRef;
    if (@_ == 1) {
        if (not exists $confhash->{$defg}) {
            $confhash->{$defg} = {};
            $sorthash->{$defg} = {};
        } elsif (ref $confhash->{$defg} ne 'HASH') {
            die;
        }
        $confhash->{$defg}{$_[0]};
    } elsif (@_ == 2) {
        if (not exists $confhash->{$_[0]}) {
            $confhash->{$_[0]} = {};
            $sorthash->{$_[0]} = {};
        } elsif (ref $confhash->{$_[0]} ne 'HASH') {
            die;
        }
        $confhash->{$_[0]}{$_[1]};
    } elsif (@_ == 3) {
        if (not exists $confhash->{$_[0]}) {
            $confhash->{$_[0]}{$_[1]} = {};
            $sorthash->{$_[0]}{$_[1]} = {};
        } elsif (ref $confhash->{$_[0]} ne 'HASH') {
            die;
        } elsif (not exists $confhash->{$_[0]}{$_[1]}) {
            $confhash->{$_[0]}{$_[1]} = {};
        } elsif (ref $confhash->{$_[0]}{$_[1]} ne 'HASH') {
            die;
        }
        $confhash->{$_[0]}{$_[1]}{$_[2]};
    } else {
        die;
    }
}

sub getOrigValue
{
    my $ret = eval { shift->origValue(@_) };
    $@ ? undef : $ret;
}

sub modify
{
    my $self = shift;
    my $value = pop;
    my $orig = eval { $self->origValue(@_) };
    return if ref $orig or $@; # cannot modify a group
    $self->origValue(@_) = $value;
    if (pop eq $sortName) {
        $self->parseSort(@_);
    }
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
    my $ret = $self->getOrigValue (@_);
    do { $ret =~ s/\$\{([^}]+)}/($1 eq '-') ? '$' : $ENV{$1}/ge;
         $ret =~ s/\$\[([^\]]+)\]/($1 eq '-') ? '$' : $self->get (split '::', $1)/ge; } if $ret;
    $ret;
}

sub getGroup
{
    my $confhash = shift->hashref;
    my $ret;
    if (@_ == 1) {
        $ret = $confhash->{$_[0]};
    } elsif (@_ == 2) {
        $ret = $confhash->{$_[0]}{$_[1]};
    } elsif (@_ == 0) {
        $ret = $confhash->{$defg};
    }
    ref $ret eq 'HASH' ? $ret : undef;
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
        return if ref $confhash->{$_[0]} ne 'HASH';
        my $ret = $confhash->{ + shift }{ + shift };
        if (ref $ret eq 'HASH') {
            return keys %$ret;
        }
    }
    return;
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

sub outputFile
{
    my ($self) = @_;
    my $h = $self->hashref;
    my $order = sub { $a cmp $b };
    my $ret;
    for my $group ($self->childList) {
        my @all = $self->childList($group);
        my $flags = $self->getSortFlags($group);
        my $entriesFirst = 0;
        if ($flags->{groupOrder} eq 'G_LAST') {
            $entriesFirst = 1;
        }
        $entriesFirst = !$entriesFirst if $flags->{'reverse'};
        my @subgroups = grep { ref $h->{$group}{$_} eq 'HASH' } @all;
        my @entries = grep { not ref $h->{$group}{$_} } @all;
        my $e = sub {
            if (@entries) {
                $ret .= "[${group}]\n";
                for (@entries) {
                    $ret .= $_.' = '.$h->{$group}{$_}."\n";
                }
                $ret .= "\n";
            }
        };
        $e->() if $entriesFirst;
        for my $subg (@subgroups) {
            $ret .= "[${group}]:$subg\n";
            for my $entry ($self->childList($group, $subg)) {
                $ret .= $entry . ' = ' . $h->{$group}{$subg}{$entry}."\n";
            }
            $ret .= "\n";
        }
        $e->() if ! $entriesFirst;
    }
    $ret;
}

sub childList
{
    my $self = shift;
    my ($g, $sg);
    eval { ($g, $sg) = ([$self->getGroups(@_)], $self->sortGroup(@_)); };
    return () if $@;
    my $func = $self->getSortFunc(@_);
    my @path = @_;
    sort { $func->($self, $a, $b, @path) } @$g;
}

sub defaultOrder
{
    $a cmp $b;
}

sub sortRef
{
    shift->{Sort};
}

sub sortGroup : lvalue
{
    my $self = shift;
    my $group = $self->getGroups(@_) or die;
    my $sorthash = $self->sortRef;
    if (@_ == 0) {
        $sorthash->{$defg};
    } elsif (@_ == 1) {
        $sorthash->{$_[0]};
    } elsif (@_ == 2) {
        $sorthash->{$_[0]}{$_[1]};
    } else {
        die;
    }
}

sub sortFunc : lvalue
{
    my $self = shift;
    my $group = $self->sortGroup(@_);
    $group->{__func__};
}

sub sortWords : lvalue
{
    my $self = shift;
    my $group = $self->sortGroup(@_);
    $group->{__words__};
}

sub sortFlags : lvalue
{
    my $self = shift;
    my $group = $self->sortGroup(@_);
    $group->{__flags__};
}

sub getSortFunc
{
    my $self = shift;
    my $func;
    my @path = @_;
    for (0..@path) {
        eval { $func = $self->sortFunc(@path) };
        $func = undef if $@;
        if ($func) {
            last;
        }
        pop @path;
    }
    
    $func or $func = sub { $_[1] cmp $_[2] };
    $func;
}
my $defaultSortFlags = { defOrder => 'DEF_FIRST', groupOrder => 'G_NORMAL', 'reverse' => 0, };
sub getSortFlags
{
    my $self = shift;
    my $flags;
    my @path = @_;
    for (0..@path) {
        eval { $flags = $self->sortFlags(@path) };
        $flags = undef if $@;
        last if $flags;
        pop @path;
    }
    $flags or $flags = $defaultSortFlags;
    $flags;
}


sub byNumber { $_[0] <=> $_[1]; }
sub byChar { $_[0] cmp $_[1]; }
sub reversedSort { -shift; }
sub groupFirst
{
    my ($self, $first, $second, @path) = @_;
    ref $self->getGroup(@path, $second) cmp ref $self->getGroup(@path, $first); # '' cmp 'HASH'
}
sub groupLast
{
    my ($self, $first, $second, @path) = @_;
    ref $self->getGroup(@path, $first) cmp ref $self->getGroup(@path, $second); # '' cmp 'HASH'
}
# DEF_FIRST:DEF_LAST:NUM:CHAR:G_FIRST:G_LAST:G_NORMAL:REVERSE:a,b,c,d,e
# sortFunc ($a, $b, @path);
sub parseSort
{
    my $self = shift;
    eval { $self->sortWords(@_) = {}; };
    return if $@;
    eval { $self->sortFlags(@_) = {}; };
    return if $@;
    eval { $self->sortFunc(@_) };
    return if $@;

    my $sortOrder = $self->get(@_, $sortName);
    my @flags = split /:/, $sortOrder, -1;
    my @words = split /,/, pop @flags;
    my $sortFunc;
    my ($comp, $groupOrder, $defOrder, $reverse)
        = (\&byChar,
           $defaultSortFlags->{'groupOrder'},
           $defaultSortFlags->{'defOrder'},
           $defaultSortFlags->{'reverse'});
    for (@flags) {
        $comp = \&byNumber when 'NUM';
        $comp = \&byChar when 'CHAR';
        $defOrder = $_ when /^DEF_(?:FIRST|LAST)$/;
        $groupOrder = $_ when /^G_(?:FIRST|LAST|NORMAL)$/;
        $reverse = 1 when 'REVERSE';
    }
    $self->sortFlags(@_) = { defOrder => $defOrder, groupOrder => $groupOrder, 'reverse' => $reverse };
    my $gFunc = sub { 0 };
    if ($groupOrder eq 'G_FIRST') {
        $gFunc = \&groupFirst;
    } elsif ($groupOrder eq 'G_LAST') {
        $gFunc = \&groupLast;
    }
    
    my $this = $defOrder eq 'DEF_FIRST' ? -1 : 1;
    my $add = $defOrder eq 'DEF_FIRST' ? -1 : 1;
    my $w = $self->sortWords(@_);
    for ($defOrder eq 'DEF_FIRST' ? reverse @words : @words) {
        $w->{$_} = $this;
        $this += $add;
    }
    $self->sortFunc(@_) = sub {
        my ($self, $first, $second, @path) = @_;
        #ay ($first, $second);
        #my $s = $self->sortWords(@path);
        my $ret = $gFunc->($self, $first, $second, @path) ||
            $w->{$first} <=> $w->{$second} ||
            $comp->($first, $second);
        #ay $ret;
        $reverse ? -$ret : $ret;
    };
}

1;
