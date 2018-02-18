package Scripts::Windy::Web::ApiCaller;

use Scripts::Base;
use Mojo::Base 'Mojo::EventEmitter';
use Scripts::Windy::Util;

has [qw/ua sendAddr/];

sub new
{
    my $class = shift;
    my $self = $class->Mojo::EventEmitter::new(@_);
    $self->sendAddr($windyConf->get('MPQ', 'sendAddr')
                    // 'http://127.0.0.1:7456/api/call');
    $self;
}

# $ac->callSeq(['OutPut', 'mewww']);
sub callSeq
{
    my $self = shift;
    my @callback = ref $_[-1] eq 'CODE' ? (pop) : ();
    my @seq = ();
    for (@_) {
        my @this = @$_;
        push @seq, { func => $this[0],
                     args => [@this[1..$#this]],
        };
    }
    my $json = { seq => \@seq };
    $self->ua->post($self->sendAddr, json => $json, @callback);
}

1;
