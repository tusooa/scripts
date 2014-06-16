#!/usr/bin/env perl

use 5.012;
use Gtk2 qw/-init/;
use utf8;
sub test;
sub closeWindow;
sub clickButton;
sub mouseHover;

my $mw = Gtk2::Window->new;
my $button = Gtk2::Button->new ('开始测试');
my $id;
$mw->add ($button);
$mw->resize (300, 200);
$mw->signal_connect (destroy => sub { Gtk2->main_quit });
$button->signal_connect (clicked => \&test);
$mw->show_all;
Gtk2->main;
sub test {
    my $dialog = Gtk2::Window->new;
    my $mainBox = Gtk2::VBox->new;
    my $secBox = Gtk2::HBox->new;
    my $text = Gtk2::Label->new ('你是煞笔吗？');
    my $b1 = Gtk2::Button->new ('是的');
    my $b2 = Gtk2::Button->new ('不是');
    $mainBox->add ($text);
    $mainBox->add ($secBox);
    $secBox->add ($b1);
    $secBox->add ($b2);
    $dialog->add ($mainBox);
    $dialog->resize (300, 200);
    $id = $dialog->signal_connect (destroy => \&closeWindow);
    $b1->signal_connect (clicked => \&clickButton, $dialog);
    $b1->signal_connect (enter => \&mouseHover, $b2);
    $b2->signal_connect (clicked => \&clickButton, $dialog);
    $b2->signal_connect (enter => \&mouseHover, $b1);
    $dialog->show_all;
}

sub closeWindow {
    my $dialog = Gtk2::Window->new;
    my $text = Gtk2::Label->new ('关了窗口也改变不了你是煞笔的事实。');
    $dialog->add ($text);
    $dialog->resize (300, 200);
    $dialog->show_all;
}
sub clickButton {
    my $dialog = Gtk2::Window->new;
    my ($button, $parent) = @_;
    my $text = Gtk2::Label->new ($button->get_label eq '是的' ? '我就知道你会点是的。' : '操?!那牛逼?!告诉我你是怎么做到的!!!');
    $dialog->add ($text);
    $dialog->resize (300, 200);
    $dialog->show_all;
    $parent->signal_handler_disconnect ($id);
    $parent->destroy;
}
sub mouseHover {
    my ($this, $other) = @_;
    if ($this->get_label eq '不是') {
        $this->set_label ('是的');
        $other->set_label ('不是');
    }
}
