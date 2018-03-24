#!/usr/bin/env perl

use 5.012;
use Scripts::Base;
use WWW::Mechanize;
use Gtk2 qw/-init/;

my ($board, $topic);
if (@ARGV >= 2)
{
    ($board, $topic) = @ARGV;
}
else
{
    my $url = shift @ARGV;
    $url =~ m{^http://archlinuxcn.org/viewtopic.php\?f=(\d+)\&t=(\d+)};
    ($board, $topic) = ($1, $2);
}
my $window = Gtk2::Window->new;
$window->signal_connect (destroy => sub { Gtk2->main_quit; });
my $mainBox = Gtk2::VBox->new;
my $topBox = Gtk2::HBox->new;
my $boldButton = Gtk2::Button->new ('b');
$boldButton->signal_connect (clicked => \&insert, ['[b]', '[/b]']);
$topBox->add ($boldButton);
my $italicButton = Gtk2::Button->new ('i');
$italicButton->signal_connect (clicked => \&insert, ['[i]', '[/i]']);
$topBox->add ($italicButton);
my $underlineButton = Gtk2::Button->new ('u');
$underlineButton->signal_connect (clicked => \&insert, ['[u]', '[/u]']);
$topBox->add ($underlineButton);
my $quoteButton = Gtk2::Button->new ('Quote');
$quoteButton->signal_connect (clicked => \&insert, ['[quote]', '[/quote]']);
$topBox->add ($quoteButton);
my $codeButton = Gtk2::Button->new ('Code');
$codeButton->signal_connect (clicked => \&insert, ['[code]', '[/code]']);
$topBox->add ($codeButton);
my $imgButton = Gtk2::Button->new ('Img');
$imgButton->signal_connect (clicked => \&insert, ['[img]', '[/img]']);
$topBox->add ($imgButton);
my $urlButton = Gtk2::Button->new ('URL');
$urlButton->signal_connect (clicked => \&insert, ['[url]', '[/url]']);
$topBox->add ($urlButton);
$mainBox->add ($topBox);
$mainBox->set_child_packing ($topBox, 0, 0, 0, 'GTK_PACK_START');
my $buffer = Gtk2::TextBuffer->new;
my $textview = Gtk2::TextView->new_with_buffer ($buffer);
$mainBox->add ($textview);
$mainBox->set_child_packing ($textview, 1, 1, 0, 'GTK_PACK_START');
my $bottomBox = Gtk2::HBox->new;
my $replyButton = Gtk2::Button->new ('Reply');
$replyButton->signal_connect (clicked => \&reply);
$bottomBox->add ($replyButton);
my $exitButton = Gtk2::Button->new ('Quit');
$exitButton->signal_connect (clicked => sub { Gtk2->main_quit; });
$bottomBox->add ($exitButton);
$mainBox->add ($bottomBox);
$mainBox->set_child_packing ($bottomBox, 0, 0, 0, 'GTK_PACK_END');
$window->add ($mainBox);
$window->resize (400, 400);
$window->show_all;

open ACCOUNT, '<', "${accountDir}archlinuxcn-forum"
    or die "Cannot open ${accountDir}archlinuxcn-forum: $!\n";
chomp (my ($username, $password) = <ACCOUNT>);
close ACCOUNT;

sub insert
{
    my ($header, $footer) = @{$_[1]};
    my ($start, $end) = $buffer->get_selection_bounds;
    my $currentText;
    if ($start != $end)
    {
        $currentText = $buffer->get_text ($start, $end, 0);
        $buffer->delete_selection (0, 1);
    }
    $buffer->insert_at_cursor ($header.$currentText.$footer);
}

sub reply
{
    my $text = $buffer->get_text ($buffer->get_start_iter, $buffer->get_end_iter, 0);
    #say "$board $topic http://archlinuxcn.org/posting.php?mode=reply&f=$board&t=$topic";
    my $mech = WWW::Mechanize->new;
    $mech->get ("http://archlinuxcn.org/ucp.php?mode=login");
    #print $mech->content;
    $mech->submit_form (
        fields => {
            username => $username,
            password => $password,
        },
        button => 'login',
    );
    $mech->success or die "登录失败,原提示: ".$mech->status."\n";
    $mech->get ("http://archlinuxcn.org/posting.php?mode=reply&f=$board&t=$topic");
    #print $mech->content;
    $mech->submit_form (
        form_id => 'postform',
        fields => { message => $text },
        button => 'post',
    );
    $mech->success or die "回复错误，原提示: ".$mech->status."\n";
    say "回复成功";
    Gtk2->main_quit;
}
Gtk2->main;
