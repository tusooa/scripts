@rem ='--*-Perl-*--
@echo off
..\perl32\perl\bin\perl.exe "%0"
goto endofperl
@rem ';
#!/usr/bin/env perl

use Win32;
use Cwd;
use 5.012;
my $orig = cwd;
$orig =~ s{/}{\\}g;
chdir $orig.'\src\windy\interp';
system qq{"$^X" build.perl};
Win32::CopyFile('interp.dll', $orig.'..\Plugin\windy.xx.dll', 1);
chdir $orig.'\src\windy-perl';
system qq{"$^X" Makefile.PL};
system qq{"$^X" dmake};
system qq{"$^X" dmake install};



__END__
use 5.012;
use Win32::TieRegistry qw(:KEY_);
use Cwd;
use Win32::API;
my $changed = 0;
my $env = Win32::TieRegistry->new(
    'HKEY_CURRENT_USER/Environment',
    {
        Access => KEY_READ() | KEY_WRITE() | 256,
        Delimiter => '/',
    }
);
my $cwd = cwd;
$cwd =~ s{/}{\\}g;
if ( !defined($env->GetValue('XDG_CONFIG_HOME'))) {
$env->SetValue('XDG_CONFIG_HOME', $cwd.'\config');
mkdir $cwd.'\config';
mkdir $cwd.'\config\windy-conf';
$changed = 1;
}
if ( !defined($env->GetValue('XDG_CACHE_HOME'))) {
$env->SetValue('XDG_CACHE_HOME', $cwd.'\cache');
mkdir $cwd.'\cache';
$changed = 1;
}

if ($changed) {
  #gonna send WM_SETTINGCHANGE broadcast - to avoid the need for logout/login
  my $HWND_BROADCAST   = 0xFFFF;
  my $WM_SETTINGCHANGE = 0x001A;
  my $SMTO_ABORTIFHUNG = 0x0002;
  my $null = pack('xxxxxxxx'); # 8 x zero byte

  my $SendMessageTimeout = Win32::API->new("user32", "SendMessageTimeout", 'NNNPNNP', 'N') or die "Can't import SendMessageTimeout: $!\n";
  $SendMessageTimeout->Call($HWND_BROADCAST,$WM_SETTINGCHANGE,0,'Environment',$SMTO_ABORTIFHUNG,5000,$null);
}
__END__
:endofperl
