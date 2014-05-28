#!/usr/bin/env perl

use Scripts::scriptFunctions qw/$appsDir/;

use 5.012;
use File::Basename;
my $backupDir = "${appsDir}GentooConfig/";

# Gentoo Config
#cp -v /etc/make.conf /etc/hosts \
#    /var/lib/portage/world "$backupDir"

system qw@rsync -rv /etc/make.conf /etc/hosts 
    /var/lib/portage/world /etc/portage/profile 
    /etc/portage/package.accept_keywords
    /etc/portage/package.mask
    /etc/portage/package.unmask
    /etc/portage/package.use 
    /etc/rc.conf /etc/conf.d /etc/local.d@, $backupDir;

# Kernel Config
for my $kernel (</usr/src/linux-*/>) {
    my $config = "${kernel}.config";
    my $version = basename ${kernel};
    $version =~ s/^linux-//;
    $version =~ s/-gentoo$//;
    system 'cp', '-v', $config, "${backupDir}kernel-config-${version}.txt";
}

#crontab
$ENV{EDITOR} = 'cat';
open CRON, '-|', 'crontab', '-e';
open CRONTAB, '>', "${backupDir}cron-tab";
print CRONTAB while <CRON>;
#system qq{EDITOR=cat crontab -e > "${backupDir}cron-tab"};
close CRON;
close CRONTAB;
