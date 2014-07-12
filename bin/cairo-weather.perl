#!/usr/bin/perl
use warnings;
use Encode qw(_utf8_on _utf8_off encode decode);
use Cairo;
use Gtk2;
use Scripts::scriptFunctions;
use 5.012;
no if $] >= 5.018, warnings => "experimental";

sub drawpng;
sub drawtxt;
sub drawframe;

my $cfg = conf 'weather';
#use Data::Dumper;print Dumper $cfg;exit;
my $logDir = "${cacheDir}weather";
my $uri = $cfg->get('weather-uri');
my $logf = $logDir . join '-', $uri =~ m'^http://qq\.ip138\.com/weather/([A-Za-z]+)/([A-Za-z]+)\.wml$';
my $icondir = $pathConf->get ('iconDir').'天气/';
#say $icondir;
my $font = $cfg->get ('font') // 'ZhunYuan';
my $outputfile= "${cacheDir}weather.png";
my $max=$cfg->get ('max') // 7; #从今天算起，最多显示几天。
my $align=10;
my %indexcolor=(
#        ">"=>"200,200,200,250", # 今天
#        "-"=>"200,200,200,250", # 周日
#        " "=>"200,200,200,255", # 其他
    ">"=>$cfg->get ('color-today'),# 今天
    "-"=>$cfg->get ('color-rest'),# 周日
    " "=>$cfg->get ('color-other'),# 其他
    "0"=>$cfg->get ('back-today'),# 今天背景
    "1"=>$cfg->get ('back-rest'),# 周日背景
);
my $shadow = $cfg->get ('show-shadow') // 1;
# 不更新或许是path的问题.
system "${scriptsDir}weather.perl", '-q';
$_ = `xwininfo -root`;
/Width:\s*\K(\d+)/;
my $scrennw = $1 // 1366; #不是在X之下的，怎么办?
my $hpos = $scrennw*0.25;
chdir $icondir;
-f "00.png" or die "can not fetch picture file.\n";
#my $_surface = Cairo::ImageSurface->create_from_png ("00.png");
#my $size = $_surface->get_width;
#say $size;
#$size = $size*$scrennw/1680;
#say $size;
my $size = $cfg->get ('size') // 90;
open REC, '<', $logf or die "Cannot open $logf: $!\n";
@_=<REC>; close REC;#say @_;
my $surface = Cairo::ImageSurface->create ('argb32',($size*2)*$max+20,$size*4);
my $fsize = $cfg->get ('font-size') // ($size / 5);
my $origPicSize = 128;
my $psize = $cfg->get ('picture-size') // 128;
my $month=0;
my $is=0;
my $w0=$size*2;
my $h0=$size/2;	# 单位方框尺寸
my $today=time2date;
my $year= (split '-', $today)[0];
my $x0=$align;
my $y0=$align;
my $color;

for (@_)
{
    next if ! /$today/ && ! $is;
    next if /^\s*$/;
    $is++;
    last if $is>$max;
    chomp;
    my ($sign,$date,$weather,$temp,$wind)=split "\t",$_;
    my ($y,$m,$d)=split "-",$date;
    
    if ($year == $y) {
        $y="";
    } else {
        $year=$y;
    }
    if ($month == $m) {
        $m="";
    } else {
        $month=$m;
    }
    
    $y.="年" if $y;
    $m.="月" if $m;
    $d.="日";

    my $color=$indexcolor{$sign};
    #if($sign eq ">"){drawpng("bg.png",$x0-$align,$y0-$align);}
    #if($sign eq "-"){drawpng("bg-w.png",$x0-$align,$y0-$align);}
    if ($sign eq ">")
    {
        drawframe( $x0-$size/6,22,$indexcolor{0} );
    }
    if ($sign eq "-")
    {
        drawframe( $x0-$size/6,22,$indexcolor{1} );
    }

    my $y1=$y0+10;
    #my $fsize=$size/5;
    drawtxt "$y$m$d",$x0+1,$y1+1,"20,20,20,200", $fsize if $shadow;
    drawtxt "$y$m$d",$x0,$y1,$color, $fsize;
    $y1+=$fsize;
    do { #$x2=$x0+$size/2; $y2=$y1+$size/2;
#    s/小到//;s/中到//;s/大到//;s/小雨/10.png/g;
#    s/中雨/11.png/g; s/大雨/12.png/g;s/雨夹雪/07.png/g;
#    s/小雪/13.png/g; s/中雪/14.png/g; s/大雪/15.png/g;
#    s/多云/26.png/;s/晴/32.png/;s/阴/31.png/;s/转/-/;
#    s/雷阵雨/17.png/;s/阵雨/09.png/;
        my $_ = $weather;
        s/小到//;s/中到//;s/大到//;
        s/小雨/09.png/g; s/中雨/10.png/g; s/大雨/11.png/g;s/暴雨/12.png/g;
        s/雨夹雪/07.png/g; s/小雪/13.png/g; s/中雪/14.png/g; s/大雪/15.png/g;
        s/暴雪/16.png/g;s/多云/26.png/;s/晴/32.png/;s/阴/31.png/;
        s/转/-/;s/雷阵雨/17.png/;s/阵雨/09.png/;

        if(/-/) {
            my ($img1,$img2)=split "-";
            drawpng $img1,$x0-$size/4,$y1;
            drawpng $img2,$x0+$size/4,$y1+$size/2;
        } else {
            drawpng $_,$x0,$y1;
        }
    };
    #代码高深。不建议修改，或建议由exp亲自修改。
    $y1+=3*$h0;
    drawtxt $weather,$x0,$y1,$color, $fsize;
    $y1+=$h0;# $_=$temp; #s/°C/℃/g;
    drawtxt $temp,$x0+1,$y1+1,"20,20,20,200", $fsize if $shadow;
    drawtxt $temp,$x0,$y1,$color, $fsize;
    $y1+=$h0;
#    $fsize=$size/6;
    _utf8_on($wind);$wind=~s{/}{\n}g;_utf8_off($wind);
    drawtxt $wind,$x0,$y1,$color, $fsize;
    $x0+=$w0;
}
#my @week=('㊐','㊀','㊁','㊂','㊃','㊄','㊅');
#my $color=$indexcolor{'>'};
#drawstamp($week[$tweek],$size,$size*2.5,5);
#drawstamp($year." ", $w0*$max/2, $size*3.5,1.8,-0.2);
$surface->write_to_png ($outputfile);
final;
#---------------------------------
#`$ENV{HOME}/bin/conky/weather-log2txt.pl`;
#`habak $bgfile -mp 360,60 -hi $outputfile`;
#---------------------------------
# functions
sub drawpng
{
    my $img = Cairo::ImageSurface->create_from_png ($_[0]); 
    my $cr = Cairo::Context->create ($surface);
    #my $pattern = Cairo::SurfacePattern->create ($img);
    #my $resize = Cairo::Matrix->init(0.5,0.5,0.5,0.5,$_[1], $_[2]);
    #$resize->scale($origPicSize/$psize, $origPicSize/$psize);
    #$resize->translate($_[1],$_[2]);
    #$pattern->set_matrix($resize);
    #my $resized = Cairo::ImageSurface->create_for_data($img->get_data, $img->get_format, $psize, $psize, $img->get_stride);
    #$pattern->move_to($_[1], $_[2]);
    #$cr->set_source($pattern);
    #say "$_[1] $_[2]";
    #$cr->move_to($_[1], $_[2]);
    $cr->set_source_surface($img,$_[1],$_[2]);
    $cr->scale($psize/$origPicSize,$psize/$origPicSize);
    $cr->paint;
}

sub drawtxt
{
    my $cr = Cairo::Context->create ($surface);
    my $pango_layout = Gtk2::Pango::Cairo::create_layout ($cr);
    my $fontSize = $_[4];
    my $font_desc = Gtk2::Pango::FontDescription->from_string("$font $fontSize"); 
    $pango_layout->set_font_description($font_desc); 
    $pango_layout->set_markup (decode("utf-8", "$_[0]"));
    my ($r,$g,$b,$a)=split ',',$_[3];
    $cr->set_source_rgba($r/256,$g/256,$b/256,$a/256);	#缺省白色字体
    $cr->move_to($_[1],$_[2]);
    Gtk2::Pango::Cairo::show_layout ($cr, $pango_layout); 
    $cr->show_page;
}

sub drawframe
{
    my ($x,$r,$c)=@_;
    my ($R,$G,$B,$A)=split ',',$c;
    my $w=$w0;
    my $h=3.7*$size;
    my $cr = Cairo::Context->create ($surface);
#$PI=3.1415926/180;
    $cr->move_to($x+$r,0);
    $cr->rel_line_to($w-2*$r,0);
    $cr->rel_curve_to(0,0,$r,0,$r,$r);
    $cr->rel_line_to(0,$h-2*$r);
    $cr->rel_curve_to(0,0,0,$r,-$r,$r);
    $cr->rel_line_to(-($w-2*$r),0);
    $cr->rel_curve_to(0,0,-$r,0,-$r,-$r);
    $cr->rel_line_to(0,-($h-2*$r));
    $cr->rel_curve_to(0,0,0,-$r,$r,-$r);
    $cr->set_source_rgba($R/256,$G/256,$B/256,$A/256); $cr->fill;
}
