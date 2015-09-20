#!/usr/bin/env perl

use 5.012;
open ROUTE,'/proc/net/route';
$_=(grep /^[a-z]+[0-9]/, (grep /0001/, <ROUTE>))[0];
close ROUTE;
s/\s.*$//g;
chomp;
my $s=/eth/?"\${color3}$_":$_;
#print "\${downspeedgraph $_ 20,80 000000 00ff00}\${upspeedgraph $_ 20,80 000000 ff0000}
#\${voffset -25}\${color3}网络\${color} ▼\${downspeedf $_}K\${tab 80}▲\${upspeedf $_}K
#\${tab 30}●\${addr $_}\${tab 80}$s";
#__END__
print "\${template4 $_}
\${template5 $_}
●\${addr $_}\${alignr}$s\${color}";
#print "\${color3}网络信息\${tab 30}\${color}\${downspeedgraph $_ 20,80 000000 00ff00}\${tab 30}\${upspeedgraph $_ 20,80 000000 ff0000}\${offset -168}\${color}\${font DejaVu Sans YuanTi Mono}\${downspeedf $_}K\${tab 0}\${upspeedf $_}K
#●\${addr $_}\${tab 60}$s\${color}\${font ZhunYuan}";
