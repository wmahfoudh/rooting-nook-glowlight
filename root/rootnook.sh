#!/bin/sh

TMPD=/data/local/tmp/.nookrooter
XBINF="su supolicy busybox"

adb start-server >/dev/null 
ANDROID_SERIAL=`adb devices -l | grep BNRV510 | sed 's/ .*//'` 
if [ -z $ANDROID_SERIAL ]; then
    echo 'ADB not connected?'
    exit 1
fi

if [ x`adb shell su -c 'busybox id -u'| tr -d '\r'` = "x0" ]; then
    if [ "`adb shell "test -e /data/data/eu.chainfire.supersu && echo yes" | tr -d '\r'`" = "yes" ]; then
        echo Already rooted.
        exit 0
    else
        echo Already rooted, but SuperSU not found.
    fi
fi

adb shell rm -rf $TMPD
adb push files $TMPD
adb shell pm install -r $TMPD/eu.chainfire.supersu.apk

adb shell "sh $TMPD/doroot.sh adbhack" >/dev/null
printf "\nRestarting adbd as root... "

if [ `adb wait-for-device shell $TMPD/busybox id -u | tr -d '\r'` -ne 0 ]; then
    printf "\nFailed to get root privilege, exiting."
    exit 1
fi

echo
adb shell "XBINF=\"${XBINF}\" sh ${TMPD}/doroot.sh"
echo Rooted.
