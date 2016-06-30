package Scripts::Windy;

use Scripts::scriptFunctions;
use Scripts::Windy::Conf::userdb;
use 5.012;
no warnings 'experimental';
sub new
{
    my $class = shift;
    my $c = conf 'windy';
    my $self = { startGroup => [], };
=comment
    $self->{Addons} = [];
    if (ref $c->{Addons} ne 'HASH') {
        return undef;
    }
    for (sort { $c->{Addons}{$a} <=> $c->{Addons}{$b} } keys %{$c->{Addons}}) {
        say 'configuring addon:'. $_;
        if (! $c->{Addons}{$_} ~~ /^(0||undef|no|off)$/) { # load addon
            say 'Active!';
            push @{$self->{Addons}}, $_;
        }
        say 'done';
    }
=cut
    bless $self, $class;
}

=comment
sub loadAddons
{
    my $self = shift;
    for my $filename (@{$self->{Addons}}) {
        say 'loading'. $filename;
    my $dir = $configDir.'windy-addons/';
    if (-e $dir.$filename.'.pm') {
        require $dir.$filename.'.pm';
    } else {
        eval "require Scripts::Windy::Addons::$filename;";
    }
        say 'Done!';
    }
}
=cut

sub parse
{
    my $self = shift;
    my $msg = shift;
    my $ret = $database->parse($self, $msg);
    $ret->{Text};
=comment
    for my $a (@{ $self->{Addons} }) {
        say 'addon:'. $a;
        no strict 'refs';
        my $prefix = "Scripts::Windy::Addons::$a";
        $ret = $prefix->parse($self, $msg);
        $text.=$ret->{Text};
        return $text if ! $ret->{Next};
    }
=cut
}

1;
