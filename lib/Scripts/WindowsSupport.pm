package Scripts::WindowsSupport;
use 5.012;
use base 'Exporter';
use Encode qw/encode decode _utf8_on _utf8_off/;

our $VERSION = 0.1;
our @EXPORT_OK = qw//;
our @EXPORT = qw/isWindows winPath unixPath setEnv addPathEnv utf8df utf8 gbk term ln/;

sub isWindows
{
    $^O eq 'MSWin32';
}

sub winPath
{
    my $path = shift;
    $path =~ s{/}{\\}g;
    $path;
}

sub unixPath
{
    my $path = shift;
    $path =~ s{\\}{/}g;
    $path;
}

sub setEnv
{
    my ($name, $value) = @_;
    system 'setx', $name, $value;
}

sub addPathEnv
{
    my ($name, $value) = @_;
    $value = winPath $value;
    my $oldValue = $ENV{$name};
    my @paths = split ';', $oldValue;
    for (@paths) {
        s{[/\\]$}{}g;
        if ((lc winPath $_)
            eq
            (lc $value)) {
            return;
        }
    }
    setEnv $name,
        length $oldValue
        ? ($oldValue . ';' . $value)
        : $value;
}

sub utf8df
{
    my $str = join '', @_;
    my $ret;
    $ret = eval { decode 'GBK', $str, 1 };
    $ret = $str if $@;
    _utf8_off($ret);
    $ret;
}

sub utf8
{
    my $str = join '', @_;
    my $ret;
    $ret = eval { decode 'GBK', $str, 1 };
    $ret = $str if $@;
    _utf8_on($ret);
    $ret;
}

sub gbk
{
    my $str = join '', @_;
    my $ret;
    eval { $ret = encode 'GBK', decode 'utf-8', $str };
    eval { $ret = encode 'GBK', $str } if $@;
    die "error: $@, @_" if $@;
    $ret;
}

sub term;
if (isWindows) {
    *term = sub { gbk @_; };
} else {
    *term = sub { join '', @_; };
}

sub ln;
if (isWindows) {
    *ln = sub {
        my ($target, $name) = @_; # use windows-style path
        $target = winPath $target;
        $name = winPath $name;
        my @args;
        @args = ('/D') if -d $target;
        system 'mklink', @args, $name, $target;
    }
} else {
    *ln = sub {
        my ($target, $name) = @_;
        symlink $target, $name;
    }
}

if (isWindows) {
    # 才可以使用终端颜色。
    system '';
}

1;

