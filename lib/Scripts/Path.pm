=encoding utf8
=cut
=head1 名称

Scripts::Path - 路径
=cut
package Scripts::Path;
use base 'Exporter';
use utf8;
use 5.012;
use File::Basename qw/basename dirname/;
use Scripts::Path::defConf;
use Scripts::Configure;
use Scripts::WindowsSupport;

our @EXPORT = qw/$appsDir $defConfDir $home
$configDir $cacheDir $dataDir
$accountDir $scriptsDir $libDir
$verbose verbose debug confFound
conf $pathConf $userPathConf $defg $scriptName/;
sub conf;
sub confFound;

=head1 变量

本节中的变量，如果没有额外说明，都是 our 声明的，被导出的变量。
=cut
=head2 $home

指明了家目录的位置。支持 Windows 和 Linux。
=cut
our $home = isWindows ? $ENV{HOMEDRIVE}.$ENV{HOMEPATH} : $ENV{HOME};
=head2 $scriptName

设定为正在执行的程序的文件名(C<basename $0>)。
=cut
our $scriptName = basename $0;
# 目录，其名称最后一定要加上/，可能是eexp最差的一个设计了。然而却提升了伊的流动性。
=head2 my $xdgConf

未被导出。指示了 XDG_CONFIG_HOME 的位置，如果这个环境变量未被设定，则使用家目录下的 .config。

应当总是使用环境变量来指定配置文件的位置，因为在访问配置文件之前，Scripts 不能从别处得知配置文件的存放处。

采用系统编码。
=cut
my $xdgConf = $ENV{XDG_CONFIG_HOME} ? "$ENV{XDG_CONFIG_HOME}/" : "$home/.config/";
=head2 $configDir

指示了 Scripts 的配置存放的地方。在 $xdgConf 下的 Scripts 目录中。

使用 utf8 编码。
=cut
our $configDir = utf8df "${xdgConf}Scripts/";
=head2 my $xdgCache

未被导出。指示了 XDG_CACHE_HOME 的位置，如果这个环境变量未被设定，则使用家目录下的 .cache。

使用系统编码。

应当总是使用环境变量来指定缓存的位置，因为要和 $xdgConf 保持对称。
=cut
my $xdgCache = $ENV{XDG_CACHE_HOME} ? "$ENV{XDG_CACHE_HOME}/" : "$home/.cache/";
=head2 $cacheDir

指示了 Scripts 的缓存存放的地方。在 $xdgCache 下的 Scripts 目录中。
=cut
our $cacheDir = utf8df "${xdgCache}Scripts/";
=head2 $defConfDir

未被导出。指示了默认配置存放的地方。是从 Scripts::Path::defConf 导入的。

Scripts::Path::defConf 是由 defConf.perl 生成的文件。这个程序应该在安装的时候被调用。
=cut
# 占位
=head2 $pathConf, $appsDir(未导出), $dataDir, $accountDir, $scriptsDir, $libDir

$pathConf 是存储配置信息的 Scripts::Configure 对象。

其对应的配置文件名是 C<scriptFunctions> 或者 C<scriptpath>。

C<$--Dir> 变量是从配置文件里读取的。参阅下文 C<配置文件> 一节。
=cut
our $pathConf = (confFound 'syspath')
    // (confFound 'scriptFunctions')
    // (confFound 'scriptpath')
    // die "No pathConf found in your config dir.\n"
         . "Please run installer.perl\n";
our $appsDir = $pathConf->get('appsDir') // "$home/应用/";
our $dataDir = $pathConf->get('dataDir') // "${appsDir}数据/";
our $userPathConf = (confFound 'userpath')
    // (confFound 'scriptFunctions')
    // (confFound 'scriptpath')
    // die "No userPathConf found in your config dir.\n"
         . "Please create a file named `userpath' in $configDir\n";
our $accountDir = $userPathConf->get('accountDir') // "$home/个人/账号/";
our $scriptsDir = $pathConf->get('scriptsDir') // "${appsDir}脚本/";
our $libDir = $pathConf->get('libDir') // "${appsDir}库/脚本/";

if (my $p = $pathConf->get('addPath')) {
    if ($^O eq 'MSWin32') {
        $ENV{PATH} = (term winPath $p) . ';' . $ENV{PATH};
    } else {
        $ENV{PATH} = (unixPath $p) . ':' . $ENV{PATH};
    }
}
=head1 函数
=head2 conf CONFIG
=cut
=head2 conf

读取配置文件。如果 CONFIG 未被指定，默认为 $scriptName。返回 Scripts::Configure 对象。

配置文件存放在 $configDir 里。
=cut
=head2 confFound
    同上。但是若文件未找到则返回 undef。
=cut
sub conf
{
    my $file = shift // $scriptName;
    Scripts::Configure->new((term $configDir.$file),
                            (term $defConfDir.$file));
}

sub confFound
{
    my $file = shift;
    my $config = conf($file);
    $config->found ? $config : undef;
}

1;
