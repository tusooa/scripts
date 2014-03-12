#!/bin/bash

if [[ "$EUID" != 0 ]] ; then
    echo "Restarting with Root."
    exec sudo "$0" "$@"
fi

ifconfig eth0 0.0.0.0
ifconfig usb0 0.0.0.0
brctl addbr br0
brctl addif br0 eth0
brctl addif br0 usb0
ifconfig br0 up
dhcpcd br0
/opt/android-sdk-update-manager/platform-tools/adb shell dhcpcd usb0
echo 'Done if only dhcpcd output'
