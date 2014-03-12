#!/usr/bin/perl

use utf8;
use 5.010;
use WWW::Mechanize;
#use Net::DBus;

#use Getopt::Long:
#GetOptions ( "long" => \$long );

#my $bus = Net::DBus->session->get_service('org.freedesktop.Notifications')
#->get_object('/org/freedesktop/Notifications','org.freedesktop.Notifications');
my $mech = WWW::Mechanize->new();
my $web_select="ubuntu";   #选择贴图网站的缩写短语，会在列表中自动匹配的。
my $add;
#======================
my %web=(   "http://www.cjb.net/"=>{ image =>$ARGV[0]},
      "http://kimag.es/"=>{ userfile1 =>$ARGV[0]},
      "http://imagebin.org/index.php?page=add"=>{ nickname =>"tusooa",
          image => $ARGV[0], disclaimer_agree => "Y"},
      "http://paste.ubuntu.org.cn/"=>{ poster =>"tusooa", screenshot => $ARGV[0],
          code2 => `xsel`},
   );
#$add = grep (/$web_select/, keys %web);
for (keys %web) { $add = $_, last if /$web_select/ }
say $add;
#if(!$add){$bus->Notify("paste-img", 0, "error", '无效网站地址', ':(', [], { }, -1);exit;}
$add or die "无效网站地址\n";
print $web_select."\n";
#======================
if($web_select eq "ubuntu"){
    $mech -> get("http://paste.ubuntu.org.cn/");
    $mech -> submit_form(
           form_name => "editor" ,
            fields => $web{$add},#{ poster =>"tusooa", screenshot => $ARGV[0],code2 => $ARGV[1]},
            button => "paste");
}
#$mech -> get($add);
#$mech -> submit_form(from_name => 'editor' , fields => $web{$add}, botton => 'paste');
#======================
if ($mech->success()) {
   my $rr=$mech->uri();
   say $rr;
   $rr = `wgetpaste -u $rr`;# unless $long;
   say $rr;
   #$bus->Notify("paste-img", 0, "sunny", '贴图地址', $rr, [], { }, -1);
} else {
    #$bus->Notify("paste-img", 0, "error", '贴图失败', ':(', [], { }, -1);
   print "ERROR:\t".$mech->status()."\n";
}

