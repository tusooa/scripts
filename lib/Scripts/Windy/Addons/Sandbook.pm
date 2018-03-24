package Scripts::Windy::Addons::Sandbook;

use Scripts::Base;
use Encode qw/_utf8_on _utf8_off/;
use 5.012;
use utf8;
sub dbg
{
    ;
    #say term @_;
}
my $newline = "<NL>";
sub new
{
    my $class = shift;
    my $cfgFile = $configDir.'windy-conf/sandbook';
    my $self = { file => $cfgFile, sentences => [] };
    bless $self, $class;
    if (open my $f, '<', $self->{file}) {
        while (<$f>) {
            chomp;
            dbg "$_";
            _utf8_on($_);
            if (/^([^\t]+)\t(.+)$/) {
                my ($db, $sentence) = ($1, $2);
                $sentence =~ s/\Q$newline\E/\n/g;
                $self->add($db, $sentence);
            }
        }
        close $f;
        $self;
    } else {
        undef;
    }
}

sub add
{
    my ($self, $db, $s) = @_;
    push @{$self->{sentences}}, [$s, $db];
}


sub addSave
{
    my ($self, $db, $s) = @_;
    $self->add($db, $s);
    if (open my $f, '>>', $self->{file}) {
        dbg "adding $s to $db";
        binmode $f, ':unix';
        $s =~ s/\n/$newline/g;
        _utf8_off($db);
        _utf8_off($s);
        say $f $db."\t".$s;
        close $f;
    } else {
        dbg "cannot open file: $!";
        undef;
    }
}

sub read
{
    my ($self, $db) = @_;
    if ($db) {
        my @a = grep $_->[1] eq $db, @{$self->{sentences}};
        if (@a) {
            return @{$a[int rand @a]};
        }
    }
    # 每句平等概率，并给出出处。
    my @all = @{$self->{sentences}};
    @{$all[int rand @all]};    
}

sub readByRegex
{
    my ($self, $pattern) = @_;
    $pattern or return;
    my $rPattern = eval { qr/$pattern/ };
    $rPattern = qr/\Q$pattern\E/ if $@;
    if ($rPattern) {
        my @a = grep $_->[0] =~ $rPattern, @{$self->{sentences}};
        if (@a) {
            return @{$a[int rand @a]};
        }
    }
    # 每句平等概率，并给出出处。
    my @all = @{$self->{sentences}};
    @{$all[int rand @all]};
}

1;
