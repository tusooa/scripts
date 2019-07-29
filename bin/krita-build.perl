#!/usr/bin/env perl

=head1 Krita build script
=cut
=head2 Preparation

Install MinGW & MSYS -- MSYS is only for its Perl. Alternatively install a Perl interpretor.

Install CMake, either through `pacman -S mingw-w64-x86_64-cmake` -- or the corresponding 32-bit version if you are building on a 32-bit system -- or by yourself (you need to manually add it to PATH)

Install Boost in MinGW, through `pacman -S mingw-w64-x86_64-boost` -- the Boost in krita-deps will only be found if we use MinGW 7.3, not any other version

Install Python 3.6

Download and unpack krita-deps.zip -- the download link is at https://binary-factory.kde.org/job/Krita_Nightly_Windows_Dependency_Build/

Fetch the source code of krita
=cut
=head2 Editing configurations

Turn to `Config Part' and edit the directories as needed

Create the directories specified by `$kritaBuildDir`
=cut
=head2 Running the script

You should have received a copy of the Perl interpreter from MSYS

Invoke the script with:

    <msysDir>/usr/bin/perl.exe <path-to>/krita-build.perl ARGS

In the following lines I will use `<krita-build>` to denote `<msysDir>/usr/bin/perl.exe <path-to>/krita-build.perl`.

First, modify some hardcoded paths in krita-deps:

    <krita-build> prepare

Then, run cmake:

    cd <kritaBuildDir>
    <krita-build> cmake

Then, compile the sources:

    <krita-build> build

Then, install:

    <krita-build> install

If you use an IDE like KDevelop or QtCreator, you can try to launch your IDE from this script,
after you have run cmake on the sources (and then choose the build directory in your IDE).
This will automatically add the suitable environment variables so that your IDE can find the
correct libraries.

To make sure Krita can correctly run, some libraries need to be linked in the krita installation directory,
if you do not want to create an installer (chances are you want to keep both your build and another one,
say, the stable version).
If you are using a windows with symlink support (via mklink), you can run the following command to do so.
You will probably need to run *As Administrator*:

    <krita-build> link-deps

Alternatively, if your system does not support symlinks, copy these directories to your installation directory.

It is probably a good idea to use the same set of environment vairables to run krita. You can do so by:

    <krita-build> run

Alternatively, permanently add `<pythonDir>;<depsDir>/bin;<depsDir>/lib;<mingwDir>/bin` to your PATH, in Control Panel.

You will probably encounter the problem that Krita's startup is *very* slow. See https://docs.krita.org/en/KritaFAQ.html#slow-start-up and add an exception for the krita directory.

`install` will also trigger `build` so if you want to build AND install,
`build` can be skipped to avoid re-scanning of all targets.
=cut
use 5.012;
use Pod::Usage;

# from lib/Scripts/WindowsSupport.pm
sub winPath
{
    my $path = shift;
    $path =~ s{/}{\\}g;
    $path;
}

sub winPathInStr
{
    my $path = shift;
    $path =~ s{/}{\\\\}g;
    $path;
}

sub unixPath
{
    my $path = shift;
    $path =~ s{\\}{/}g;
    $path;
}

sub ln {
    my ($target, $name) = @_;
    say "`$name' -> `$target'";
    # use windows-style path
    $target = winPath $target;
    $name = winPath $name;
    my @args;
    @args = ('/D') if -d $target;
    system 'mklink', @args, $name, $target;
}

### Config Part -- change as needed
# the directory extracted from krita-deps.zip
# you should have downloaded it from https://binary-factory.kde.org/job/Krita_Nightly_Windows_Dependency_Build/
my $depsDir = 'c:/Home/Programs/krita-deps/deps-install';
# the path to MinGW installation
my $mingwDir = 'c:/Home/Programs/msys64/mingw64';
# the path to your Python 3.6
my $pythonDir = 'c:/Home/Programs/python3'; # krita-dep's python build does not seem to consider PYTHONPATH
# the directory to install krita
my $kritaInstallDir = 'c:/Home/Programs/krita-testing';
# krita source directory
my $kritaSrcDir = 'c:/Home/Code/krita';
# the directory to build krita
my $kritaBuildDir = 'c:/Home/Code/krita-build';
# how many jobs can we run at the same time
my $jobs = 3;
# whether to build tests
my $tests = 1;
### End config part

# Chances are MinGW has a higher version of Python, which we do not want.
$ENV{'PATH'} = (winPath "$pythonDir;$depsDir/bin;$depsDir/lib;$mingwDir/bin;").$ENV{'PATH'};
$ENV{'PYTHONPATH'} = length $ENV{'PYTHONPATH'} ?
    (winPath "$depsDir/lib/krita-python-libs").";$ENV{'PYTHONPATH'}" :
    (winPath "$depsDir/lib/krita-python-libs");

# Just in case you have some Boost installed...
# it will cause problems if you do not have the libraries of the correct type
# these environment variables are specified in FindBoost.cmake:40-45 (provided by CMake)
delete $ENV{'BOOST_ROOT'};
delete $ENV{'BOOSTROOT'};
delete $ENV{'BOOST_LIBRARYDIR'};
delete $ENV{'BOOST_INCLUDEDIR'};

#chdir $kritaBuildDir;

my $action = $ARGV[0];
if ($action eq 'cmake') {
    # from build.cmd
    system 'cmake', $kritaSrcDir,
        "-DCMAKE_INSTALL_PREFIX=$kritaInstallDir",
        '-DBoost_DEBUG=OFF',
        # Here we gotta make another exception for Boost --
        # if your mingw version doesn't match the one that compiled boost-system in krita-deps,
        # chances are cmake can't find them at all ;(
        "-DBOOST_INCLUDEDIR=$mingwDir/include",
        "-DBOOST_ROOT=$mingwDir",
        # dynamic libraries are located at prefix/bin, under MinGW
        "-DBOOST_LIBRARYDIR=$mingwDir/bin",
        # used by FindSIP.cmake to set PYTHONPATH -- it will mess up with Boost, though
        "-DCMAKE_PREFIX_PATH=$depsDir",
        '-DBUILD_TESTING=' . ($tests ? 'ON' : 'OFF'),
        '-DHAVE_MEMORY_LEAK_TRACKER=OFF',
        '-DFOUNDATION_BUILD=ON',
        '-DUSE_QT_TABLET_WINDOWS=ON',
        '-Wno-dev',
        '-G', "MinGW Makefiles",
        '-DCMAKE_BUILD_TYPE=RelWithDebInfo',
        # " For MinGW make to work correctly sh.exe must NOT be in your path."
        '-DCMAKE_SH=CMAKE_SH-NOT-FOUND';
} elsif ($action eq 'build') {
    system 'mingw32-make', "-j$jobs";
} elsif ($action eq 'install') {
    system 'mingw32-make', "-j$jobs", 'install';
} elsif ($action eq 'prepare') {
    my $origDepsDir = 'C:/Packaging/KritaWS/deps-install';
    my $escapedOrigDepsDir = winPathInStr $origDepsDir;
    # change the hardcoded path in VcConfig
    my $vcConfig = "$depsDir/lib/cmake/Vc/VcConfig.cmake";
    open VCCONF, '<', $vcConfig;
    my $content = join '', <VCCONF>;
    close VCCONF;
    $content =~ s@\Q$origDepsDir\E@$depsDir@g;

    open VCCONFW, '>', $vcConfig;
    print VCCONFW $content;
    close VCCONFW;

    # ... and sipconfig.py
    my $sipConfig = "$depsDir/lib/krita-python-libs/sipconfig.py";
    my $escapedDepsDir = winPathInStr $depsDir;
    open SIPCONF, '<', $sipConfig;
    $content = join '', <SIPCONF>;
    close SIPCONF;
    $content =~ s@\Q$origDepsDir\E@$depsDir@g;
    $content =~ s@\Q$escapedOrigDepsDir\E@$escapedDepsDir@g;

    open SIPCONFW, '>', $sipConfig;
    print SIPCONFW $content;
    close SIPCONFW;

    # ... and ask CMake not to find boost inside deps dir
    my @boostDirs = glob "$depsDir/include/boost*";
    for (@boostDirs) {
        rename $_, $_.'-backup';
    }

    say 'The source is prepared to build.';
} elsif ($action eq 'run') {
    my $program = "$kritaInstallDir/bin/krita.exe";
    system { $program } $program;
} elsif ($action eq 'link-deps') {
    # Well, if these are not directly inside <kritaInstallDir>/bin, it just won't run
    my $pluginsDir = "$depsDir/plugins";

    opendir PLUGINSDIR, $pluginsDir;
    while (readdir PLUGINSDIR) {
        /^\./ && next;
        ln "$pluginsDir/$_", "$kritaInstallDir/bin/$_";
    }
    closedir PLUGINSDIR;

    # Krita forces to use bundled python...
    ln "$depsDir/python", "$kritaInstallDir/python";

    my $pythonLibsDir = "$depsDir/lib/krita-python-libs";

    opendir PYLIBDIR, $pythonLibsDir;
    while (readdir PYLIBDIR) {
        /^\./ && next;
        /__pycache__/ && next;
        ln "$pythonLibsDir/$_", "$kritaInstallDir/lib/krita-python-libs/$_";
    }
    closedir PYLIBDIR;

    # QtQuick QMLs, for touch docker
    my $qmlDir = "$depsDir/qml";
    opendir QMLDIR, $qmlDir;
    while (readdir QMLDIR) {
        /^\./ && next;
        ln "$qmlDir/$_", "$kritaInstallDir/bin/$_";
    }
    closedir QMLDIR;
} elsif ($action eq '' or
         $action eq 'help' or
         $action eq '-h' or
         $action eq '--help' or
         $action eq '-help' or
         $action eq '-?') {
    say 'Usage: krita-build.perl cmake|build|install|prepare|link-deps|run|help|<cmdline>';
    say 'If the first argument is not one of cmake, build, install, prepare, link-deps, run and help, the program specified by <cmdline> will be run in the build environment.';
    say 'e.g.: krita-build.perl gmake -j5 install';
    say '';
    pod2usage(   -msg     => '',
                 -exitval => 0,
                 -verbose => 2,
                 -output  => \*STDOUT);
} else {
    system { $ARGV[0] } @ARGV;
}
