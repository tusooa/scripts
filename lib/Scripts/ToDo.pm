package Scripts::ToDo;

#use DateTime;
use Scripts::scriptFunctions;
use 5.012;
use List::Util qw/max/;
use Encode;
use Term::ReadKey;
use Scripts::TimeDay;
no if $] >= 5.018, warnings => "experimental";
our $showAll = 0;
=todo file style
name<tab>emergency<tab>done?<tab>due<tab>tag1 tag2...
=cut
sub new
{
    my ($class, $file) = @_;
    open FILE, '<', $file or return undef;
    my $self = {
        file => $file,
        list => [],
        changed => 0,
    };
    while (<FILE>)
    {
        chomp; # 一定要记住。
        my @list = split /\t/;
        #$list[2] =~ /^(\d+)-(\d+)-(\d+)$/;
        #$list[2] = DateTime->new (year => $1, month => $2,
        #                          day => $3, time_zone => 'Asia/Shanghai');
        $list[4] = [split / /, $list[4]];
        push @{$self->{list}}, \@list;
    }
    close FILE;
    bless $self, $class;
}

my $cfg = conf 'todo.perl';
my @termColors = (
    $cfg->get ('Colors', '0term') // "\e[0m", # 0
    $cfg->get ('Colors', '1term') // "\e[1;32m", # 1
    $cfg->get ('Colors', '2term') // "\e[1;33m", # 2
    $cfg->get ('Colors', '3term') // "\e[1;31m", # 3
    $cfg->get ('Colors', 'tags-term') // "\e[1;35m", # 4
    $cfg->get ('Colors', 'todo-term') // "\e[1;36m", # 5
    $cfg->get ('Colors', 'done-term') // "\e[1m", # 6
    $cfg->get ('Colors', 'countup4d-term') // "\e[1;31m", # 7
    $cfg->get ('Colors', 'countup7d-term') // "\e[1;32m", # 8
    $cfg->get ('Colors', 'countup10d-term') // "\e[1;33m", # 9
    $cfg->get ('Colors', 'countup-term') // "\e[1;34m", # 10
);
my @conkyColors = (
    $cfg->get ('Colors', '0conky') // '${color}', # 0
    $cfg->get ('Colors', '1conky') // '${color2}', # 1
    $cfg->get ('Colors', '2conky') // '${color3}', # 2
    $cfg->get ('Colors', '3conky') // '${color1}', # 3
    #$cfg->get ('Colors', 'tags-conky') // '${color5}', # #
    $cfg->get ('Colors', 'countup4d-conky') // '${color1}', # 4
    $cfg->get ('Colors', 'countup7d-conky') // '${color2}', # 5
    $cfg->get ('Colors', 'countup10d-conky') // '${color3}', # 6
    $cfg->get ('Colors', 'countup-conky') // '${color4}', # 7
);

sub cuColorTerm
{
    given (shift)
    {
        return $termColors[7] when $_ <= 4;
        return $termColors[8] when $_ <= 7;
        return $termColors[9] when $_ <= 10;
        default { return $termColors[10] }
    }
}

sub printListFromList
{
    my $maxLen = max map { length encode 'euc-cn', decode 'utf-8', $_->[0] } @_; # 无奈的中文对齐。。
    for (0..$#_)
    {
        my $todo = $_[$_];
        next if !$showAll && $todo->[2];
        my ($countup, $cuText);
        if ($todo->[3])
        {
            $countup = Scripts::TimeDay->now->timeDiff (Scripts::TimeDay->newFromString ($todo->[3]) );
            if ($countup >= 0)
            {
                $cuText = ($countup ? '剩余'.$countup.'天' : '截至今日');
            }
            else
            {
                $cuText = '过期'.$countup.'天';
            }
            $cuText = '  ' . (cuColorTerm $countup) . $cuText;
        }
        if ($showAll)
        {
            print +($todo->[2] ? ($termColors[6].'DONE')
                    : ($termColors[5].'TODO')) . $termColors[0] . '  ';
        }
        say $termColors[$todo->[1]] . "$_: " . $todo->[0] .
            ' ' x ($maxLen - length encode 'euc-cn',
                   decode 'utf-8', $todo->[0]) . $cuText .
                   $termColors[4] . '  Tags: ' . "@{$todo->[4]}" .
                   $termColors[0];
        #printTodoItem $todo;
    }
}

sub printList
{
    my $self = shift;
    #my @t = localtime time;
    #my $today = DateTime->new (year => $t[5] + 1900, month => $t[4] + 1,
    #                           day => $time[3], time_zone => 'Asia/Shanghai');
    printListFromList @{$self->{list}};
    $cfg->runHooks ('printList');
}

sub cuColorConky
{
    given (shift)
    {
        return $conkyColors[4] when $_ <= 4;
        return $conkyColors[5] when $_ <= 7;
        return $conkyColors[6] when $_ <= 10;
        default { return $conkyColors[7] }
    }
}

sub printConky
{
    my $self = shift;
    for (0..$#{$self->{list}})
    {
        my $todo = $self->{list}->[$_];
        next if $todo->[2];
        my ($countup, $cuText);
        if ($todo->[3])
        {
            $countup = Scripts::TimeDay->now->timeDiff (Scripts::TimeDay->newFromString ($todo->[3]) );
            if ($countup >= 0)
            {
                $cuText = ($countup ? '+'.$countup.'D' : 'TODAY');
            }
            else
            {
                $cuText = '-'.$countup.'D';
            }
            $cuText = '  ' . (cuColorConky $countup) . $cuText;
        }
        say $conkyColors[$todo->[1]] . "$_: " . $todo->[0] .
            $cuText .
            $conkyColors[0]; # 不简单。
    }
    $cfg->runHooks ('printConky');
}

sub markChanged
{
    my $self = shift;
    $self->{changed} = 1;
    $cfg->runHooks ('changed');
}

#   !=emergency #=tag
#my $modRegex = qr/^(!|#)/;

sub add
{
    my $self = shift;
    my $name = '';
    my $emergency = 0;
    my $due = '';
    my @tags = ();
    for (@_)
    {
        if (/^\^(.+)$/)
        {
            $emergency = ($1>=0 && $1<=3) ? $1 : 0;
        }
        elsif (/^@(.+)$/)
        {
            push @tags, $1;
        }
        elsif (/^=(\d+[^\d]+\d+[^\d]+\d+)$/)
        {
            $due = $1;
        }
        elsif (! /^\s*$/) # 非空行
        {
            my $new = $_;
            $new =~ s/^,(\^|@|=)/$1/; #转义的^,@
            $name = $name ? "$name $new" : $new;
        }
    }
    my @list = ($name, $emergency, 0, $due, \@tags);
    push @{$self->{list}}, \@list;
    $self->markChanged;
    $cfg->runHooks ('add');
}

sub save
{
    my $self = shift;
    $self->{changed} or return 1;
    open FILE, '>', $self->{file} or return undef;
    for (@{$self->{list}})
    {
        if (ref $_->[4] eq 'ARRAY')
        {
            say FILE $_->[0]."\t".$_->[1]."\t".$_->[2]."\t".$_->[3]."\t"."@{$_->[4]}";
        }
        else
        {
            say FILE $_->[0]."\t".$_->[1]."\t".$_->[2]."\t".$_->[3]."\t";
        }
    }
    close FILE;
    $cfg->runHooks ('save');
}
=comment
sub choose
{
    my $num;
    #my $func = \&printListFromList;
    #if (ref $_[0] eq 'CODE')
    #{
#    say "in choose";
    my $func = shift;
#    say "func=$func";
    $func->(@_);
    ReadMode 4;
    do
    {
        $num = ReadKey 0;
    }
    until ($num>=0 and $num<=@_);
    ReadMode 0;
    $num;
}
=cut
=comment
sub chooseReturnOrigOrd
{
    my $self = shift;
    my $showFunc = \&printListFromList;
    if (ref $_[0] eq 'CODE')
    {
        $showFunc = shift;
        #say $showFunc == \&printDoneListFromList;
        #say "code ref: $showFunc";
    }
#    say $showFunc;
    my @remain = @{$self->{list}};
    map { $remain[$_]->[4] = $_ } 0..$#remain;
    if ($showFunc == \&printDoneListFromList)
    {
        @remain = grep $_->[2], @remain;
    }
    elsif (!$showAll)
    {
        @remain = grep !$_->[2], @remain;
    }
    for my $r (@_)
    {
#        say "$r, @remain";
#        use Data::Dumper;print Dumper @remain;
        @remain = grep { $_->[0] =~ /$r/ } @remain;
    }
    my $select = 0;
    if (@remain == 0)
    {
        die "没有匹配到的todo项。\n";
    }
    elsif (@remain > 1)
    {
        say '有多个匹配到的todo项。数字选择:';
        $select = choose $showFunc, @remain;
    }
    $remain[$select]->[4];
}
=cut
sub remove
{
    my $self = shift;
    my $origOrd = shift;#$self->chooseReturnOrigOrd (@_);
    undef $self->{list}->[$origOrd];
    $self->{list} = [grep { defined $_ } @{$self->{list}}];
    #use Data::Dumper;print Dumper ($self->{list});
    $self->markChanged;
    $cfg->runHooks ('remove');
}

sub done
{
    my $self = shift;
    my $origOrd = shift;
    $self->{list}->[$origOrd]->[2] = 1;
    $self->markChanged;
    $cfg->runHooks ('done');
}

sub undone
{
    my $self = shift;
    my $origOrd = shift;
    $self->{list}->[$origOrd]->[2] = 0;
    $self->markChanged;
    $cfg->runHooks ('undone');
}


sub modify
{
    my $self = shift;
    my $origOrd = shift;
    my @name;
    my %addTags = ();
    my %replaceTags = ();
    my %removeTags = ();
    my $emergency = 'NOTCHANGE';
    my $due = 'NOTCHANGE';
    for (@_)
    {
        if (/^\^(.+)$/)
        {
            $emergency = ($1>=0 && $1<=3) ? $1 : 'NOTCHANGE';
        }
        elsif (/^@(.+)=$/)
        {
            $replaceTags{$1} = 1;
            %addTags = ();
            %removeTags = ();
        }
        elsif (/^@(.+)-$/)
        {
            $removeTags{$1} = 1;
            delete $addTags{$1};
            delete $replaceTags{$1};
        }
        elsif (/^@(.+)\+?$/)
        {
            $addTags{$1} = 1;
        }
        # todo: =12+(延期),=12-(加紧)
        elsif (/^=(\d+[^\d]+\d+[^\d]+\d+)$/) # due
        {
            $due = $1;
        }
        elsif (/^=$/) # 撤销due
        {
            $due = '';
        }
        elsif (! /^\s*$/) # 新名字
        {
            my $new = $_;
            $new =~ s/^,(\^|@|=)/$1/; #转义的^,@,=
            push @name, $new;
        }
    }
    if ($emergency ne 'NOTCHANGE')
    {
        $self->{list}->[$origOrd]->[1] = $emergency;
    }
    if ($due ne 'NOTCHANGE')
    {
        $self->{list}->[$origOrd]->[3] = $due;
    }
    if (@name)
    {
        $self->{list}->[$origOrd]->[0] = join ' ', @name;
    }
    my @newTags;
    if (%replaceTags && %addTags)
    {
        my %all = (%replaceTags, %addTags);
        @newTags = keys %all;
    }
    elsif (%replaceTags)
    {
        @newTags = keys %replaceTags;
    }
    else
    {
        my %all;
        for (@{$self->{list}->[$origOrd]->[4]})
        {
            $all{$_} = 1;
        }
        %all = (%all, %addTags);
        @newTags = keys %all;
    }
    $self->{list}->[$origOrd]->[4] = [grep !($_ ~~ %removeTags), @newTags];
    $self->markChanged;
    $cfg->runHooks ('modify');
}

1;

