#!/usr/bin/env perl

use 5.012;
use Scripts::Base;
use Getopt::Long qw/:config gnu_getopt/;
use WWW::Mechanize;

my $config = conf 'paste-img.perl';
chomp (my $name = $config->get ('name') // $ENV{USER} // `whoami`);
my $select = $config->get ('web-select') // 'ubuntu';
my $help = 0;
my $list = 0;

GetOptions (
    'select|s=s' => \$select,
    'name|n=s' => \$name,
    'help' => \$help,
    'list|l' => \$list,
);

my $image = $ARGV[0];

my %web = ( # from eexpress: https://github.com/eexpress/eexp-bin/blob/master/paste-img/pasteimg.pl
            "http://imm.io/"=>{"image"=>'xxxx'},	#改js了
#"file://localhost/home/eexp/imm.io.html"=>{"image"=>'xxxx'},
            "http://www.cjb.net/"=>{"image"=>'xxxx'},	#废弃
            "http://bkup.co/"=>{"file1"=>'xxxx'},
            "http://kimag.es/"=>{"userfile1"=>'xxxx'},
            "http://imagebin.org/index.php?page=add"=>{"nickname"=>$name,"image"=>'xxxx',"disclaimer_agree"=>"Y"},
            "http://paste.ubuntu.org.cn/"=>{"poster"=>$name,"screenshot"=>'xxxx',"submit"=>"paste"},
            "http://uploadpie.com/"=>{"uploadedfile"=>'xxxx',"result"=>'value.*?auto_select,http[^"]*'},
            "http://ompldr.org/"=>{"file1"=>'xxxx',"result"=>'BBCode.*?img,http[^]]*'},
            "http://picpaste.com/"=>{"upload"=>'xxxx',"rules"=>"yes","result"=>'Picture\ URL.*?/a,http[^"]*'},
            'http://derp.co.uk/?basic=1' => {'Filedata' => 'xxxx'},
            'http://prntscr.com/' => {'image' => 'xxxx'},
    );
for (keys %{$config->hashref})
{
    /^http/ or next;
    #print Dumper $_;
    $web{$_} = $config->hashref->{$_};
}

if ($list)
{
    for (sort { $a cmp $b } keys %web)
    {
        s@http://@@;s@/.*@@;
        $_ = "\e[32m".$_."\e[0m" if /$select/o;
        say;
    }
    exit 0;
}

if ($help)
{
    say qq{paste-img.perl [-s|--select=website] <file>
paste-img.perl -l|--list
paste-img.perl --help};
    exit;
}
#print Dumper %web;
-e $image or die "Image file not found: $image\n";
my $site;
for (keys %web) {
    $site = $_, last if /$select/;
}
if (!$site) {
    system 'notice-msg', 'paste-img.perl', 'error', '无效的paste网站', "网站选择 $select，但是没有匹配任何选项。";
    die "网站选择 $select，但是没有匹配任何选项。\n";
}
my %fields = %{$web{$site}};
while (my ($key, $value) = each %fields) {
    if ($value eq 'xxxx') {
        $fields{$key} = $image;
        last;
    }
}
my $submit;
if (defined $fields{submit}) {
    $submit = $fields{submit};
    delete $fields{submit};
}
my $result;
if ($fields{result}) {
    $result = $fields{result};
    delete $fields{result};
}
my $mech = WWW::Mechanize->new (agent => 'Mozilla/5.0 (X11; Linux x86_64; rv:29.0) Gecko/20100101 Firefox/29.0');
# http://whatsmyuseragent.com/
$mech->get ($site);say $mech->content;
#$mech->form_with_fields (keys %fields);
#$mech->set_fields (%fields);
if ($submit) {
    $mech->submit_form (with_fields => \%fields, button => $submit);
} else {
    $mech->submit_form (with_fields => \%fields);
}
say 'posted';
if (!$mech->success) {
    system 'notice-msg', 'paste-img.perl', 'error', '贴图失败', "无法submit到$site";
    die "无法submit到$site\n";
}

my $uri;
if ($result)
{
    my $content = $mech->content;
    my @regex = split /,/, $result;
    $uri = $content;
    for (@regex) {
        $uri = $uri =~ /$_/;
    }
}
else
{
    $uri = $mech->uri;
}
system 'notice-msg', 'paste-img.perl', '贴图成功', "uri: $uri";
open XSEL, '|-', 'xsel', '-i';
print XSEL $uri;
#system qq{echo -n "$uri" | xsel -i};
close XSEL;
say "贴图成功, uri: $uri";

