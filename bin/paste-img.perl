#!/usr/bin/env perl

use 5.012;
use Scripts::scriptFunctions;
use Getopt::Long qw/:config bundling no_ignore_case/;

my $config = conf 'paste-img.perl';
chomp (my $name = $config->get ('name') // $ENV{USER} // `whoami`);
my $select = $config->get ('web-select');
my $help = 0;
my $list = 0;

GetOptions (
    'select|s=s' => \$select,
    'help' => \$help,
    'list|l' => \$list,
);

my $image = $ARGV[0];

my %web = ();
for (keys %{$config->hashref})
{
    /^http/ or next;
    #print Dumper $_;
    $web{$_} = {
        fields => { ($config->get ($_, 'name-field') ? ($config->get ($_, 'name-field'), $name) : ()),
                    $config->get ($_, 'image-field'), $image,
        },
        button => $config->get ($_, 'button'),
    };
    if ($config->get ($_, 'form-name'))
    {
        $web{$_}->{form_name} = $config->get ($_, 'form-name');
    }
    else
    {
        $web{$_}->{form_id} = $config->get ($_, 'form-id');
    }
    if ($config->get ($_, 'fields'))
    {
        for my $key (keys %{$config->get ($_, 'fields')})
        {
            $web{$_}->{fields}->{$key} = $config->get ($_, 'fields', $key);
        }
    }
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
for (keys %web)
{
    $site = $_, last if /$select/;
}
unless ($site)
{
    system 'notice-msg', 'paste-img.perl', 'error', '无效的paste网站', "网站选择 $select，但是没有匹配任何选项。";
    die "网站选择 $select，但是没有匹配任何选项。\n";
}

require WWW::Mechanize; #这样在前边help之类的时候，就不用加载WWW::Mechanize了。
my $mech = WWW::Mechanize->new;
$mech->get ($site);
$mech->submit_form (%{$web{$site}});
unless ($mech->success)
{
    system 'notice-msg', 'paste-img.perl', 'error', '贴图失败', "无法submit到$site";
    die "无法submit到$site\n";
}

my $uri;
my $regex = $config->get ($site, 'uri-regex');
if ($regex)
{
    my $content = $mech->content;
    $uri = $content =~ /$regex/;
}
else
{
    $uri = $mech->uri;
}
system 'notice-msg', 'paste-img.perl', '贴图成功', "uri: $uri";
system qq{echo -n "$uri" | xsel -i};
say "贴图成功, uri: $uri";

