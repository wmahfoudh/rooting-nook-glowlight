# Rooting the NOOK GlowLight Plus (Linux)
# and opening Arabic eBooks (epub)

*It's a pity that the Barnes & Noble NOOK having such interesting hardware is not able to read Arabic (and Hebrew) eBooks out of the box. The problem is in the stock application wich does not support it. Once rooted you can unlock the full potential of the device like installing a better launcher (see below) and using the integrated browser or a third party capable reader.*

*Disclaimer: Please note that rooting your device voids its warranty and can brick it. Do it at your own risk!*

All the credit goes to the author of the original rooting script that can be found [at this XDA thread](https://is.gd/Om4KCW). The script runs on any distro.

## Let's do it

Install ADB (Android Debug Bridge) included in the Android platform tools
````shell
sudo pacman -S android-tools
````
In order to have our nook listed as a normal device under ``/dev/`` we need to install the ``android-udev`` package
````shell
sudo pacman -S android-udev
````
Connect your NOOK and run ``adb devices``
You should have something like this
````shell
XXXXXXXXXXXXXXXX        unauthorized
````
*XXXXXXXXXXXXXXXX being the serial number of your NOOK*

Go to *Setting* menu then to *About*. Click 8 times (or more if you want) on the icon just above the *Check for system update* button, you will enter the developer settings page. Click on the second button *(Android development settings)* and tick the *USB debugging* checkbox. Ensure *Developer options* on the top of the page is et to *ON*.

Unplug your device and plug it again. Run ``adb devices`` again and you should now have your device recognized
````shell
XXXXXXXXXXXXXXXX        device
````
If you are still not able to see your NOOK, please follow [these instructions](https://wiki.archlinux.org/index.php/Android_Debug_Bridge).

Download the *root* folder and its contents in your home directory. Launch the root script as follows
````shell
chmod 755 rootnook.sh
./rootnook.sh
````
After a few seconds, you should have the following output, and the ``supersu`` app lauches on your device
````shell
./rootnook.sh: line 13: [: too many arguments
files/: 9 files pushed. 1.3 MB/s (7413987 bytes in 5.599s)
pkg: /data/local/tmp/.nookrooter/eu.chainfire.supersu.apk
Success
Restarting adbd as root...
Rooted.
````
On some devices the boot animation will lag, just press the wake button to open the device. If that annoys you, you can remove the boot animation by deleting or renaming the animation file
````shell
adb shell
su
# here you should grant root access when asked by the supersu app on the device
mount -o remount, rw /system
mv /system/bin/bootanimation /system/bin/bootanimation.bak
````
Finally, you can use ``adb`` to upload an ebook to your NOOK, here is a sample Arabic epub
````shell
adb push AR-Kalila-wa-Dimna.epub /sdcard/NOOK/My\ Files
# "Kalila wa Dimna" is famous collction of fables translated from Persian to Arabic in the eighth century
````
## Et voilà

The integrated browser

![Browser view](/images/im-a.jpg)

A sample Arabic ebook on the ``Moon+ Reader`` application

![Browser view](/images/im-b.jpg)

## For a better experience
1. Install [ReLaunch](https://forum.xda-developers.com/nook-touch/general/relaunch-best-nst-launcher-version-1-4-t3060782), an excellent community launcher and file manager well adapted to the NOOK
2. Install a good reader like ``Moon+`` or ``Aldiko``
3. [Optional] Disable the stock NOOK applications (Settings -> Apps -> -> All), this will save some battery and some data sent by the application
4. Install ``Button Savior`` application to have a floating back button just like normal tablets

## Bonus: Rooting the GlowLight 3
[This XDA post](https://forum.xda-developers.com/nook-touch/general/how-to-root-set-nook-glowlight-3-t3802331) reports that the same script works on the NOOK GlowLight 3, you just need to change the model number in ``rootnook.sh`` from **BNRV510** to **BNRV520**

````shell
ANDROID_SERIAL=`adb devices -l | grep BNRV510 | sed 's/ .*//'`
````
For the GlowLight 3, should be
````shell
ANDROID_SERIAL=`adb devices -l | grep BNRV520 | sed 's/ .*//'`
````
