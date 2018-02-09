package Scripts::Math::Expr;
use 5.012;
use Number::Fraction;
no warnings 'experimental';
use List::Util;
use overload
    q/""/ => 'strize',
    '+' => 'add',
    '*' => 'mult',
    '-' => 'minus',
    '/' => 'div',
    '**' => 'exp',
    fallback => 1;

=comment
[ [ [6, -1], [5, 1], [3, 1/2], ['a', 5'], ], ... ]
5 _/3 a^5
---------
6
=cut
my $debug = 1;
my $fracPtn = qr<^([+-]?\d+(/\d+)?)>;
my $numPtn = qr<^([+-]?\d+\.\d+)>;
my $varPtn = qr<^([A-Za-z]((\*\*|\^))?)>;
sub new {
    my $class = shift;
    my $terms = [];
    for my $this (@_) {
        if (ref $this eq 'Scripts::Math::Expr') {
            push @$terms, @{$this->{this}};
        } else {
        #    local $_ = $this;
        #    my $start = 1;
        #    my $term = {};
        #    while ($_) {
        #        if ($start and s<$fracPtn><>) {
        #            $term{num} = 
        #        } elsif ($start and s<$numPtn><>) {
        #            $term{num} = $1;
        #        } elsif (s<><>) {
        #        }
        #    }
        }
    }
    my $self = {this => $terms};
    bless $self, $class;
    $self->simplify;
}

sub simplify {
    my $self = shift;
    #$self->{this} = [grep { all $_->[0] != 0, @$_ } @{$self->{this}}]; #删除所有0的项
    for my $item (@{$self->{this}}) {
        $item = [grep { $_->[1] == 0 } @$item];# 0次方=1
    }
    $self;
}

sub strize {
    my $self = shift;
    my $str;
    for my $term (@{$self->{this}}) {
        for (@$term) {
            my $show = $_->[0];
            if ($show =~ /^-/) { $show = '('.$show.')' }
            given ($_->[1]) {
                $str .= '_/'.$show when (1/2);
                $str .= $show when (1);
                default { $str .= (length $show == 1 ? $show : qq<($show)>).'^'.$_; }
            }
            $str .= ' * ';
        }
        $str =~ s/ \* $/ + /;
    }
    $str =~ s/ \+ $//;
    @{$self->{this}} == 1 ? $str : "($str)";
}
sub add {
    Scripts::Math::Expr->new (shift,shift);
};
sub mult {
}
sub minus {
}
sub div {
}
sub exp {
}
1;
