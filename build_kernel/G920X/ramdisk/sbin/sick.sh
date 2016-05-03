#!/system/bin/sh

#Varibles
BB=/system/xbin/busybox

busybox mount -t rootfs -o remount,rw rootfs
busybox mount -o remount,rw /system
busybox mount -o remount,rw /data

sync

/system/xbin/daemonsu --auto-daemon &

# Parse init/d support from prop. If AUTO mode check to see if support has been added to the rom
if [ "`grep "kernel.initd=true" $PROP`" != "" ]; then
	if [ "`grep "init.d" /system/etc/init.sec.boot.sh`" = "" ]; then
		mount -t rootfs -o remount,rw rootfs
	fi
fi

sleep 5

# Parse GApps wakelock fix from prop
if [ "`grep "kernel.gapps=true" $PROP`" != "" ]; then
	sleep 60
	su -c "pm enable com.google.android.gms/.update.SystemUpdateActivity"
	su -c "pm enable com.google.android.gms/.update.SystemUpdateService"
	su -c "pm enable com.google.android.gms/.update.SystemUpdateService$ActiveReceiver"
	su -c "pm enable com.google.android.gms/.update.SystemUpdateService$Receiver"
	su -c "pm enable com.google.android.gms/.update.SystemUpdateService$SecretCodeReceiver"
	su -c "pm enable com.google.android.gsf/.update.SystemUpdateActivity"
	su -c "pm enable com.google.android.gsf/.update.SystemUpdatePanoActivity"
	su -c "pm enable com.google.android.gsf/.update.SystemUpdateService"
	su -c "pm enable com.google.android.gsf/.update.SystemUpdateService$Receiver"
	su -c "pm enable com.google.android.gsf/.update.SystemUpdateService$SecretCodeReceiver"
fi

sleep 1;

# Execute init.d if Auto or ROM control
if [ "`grep "kernel.initd=true" $PROP`" != "" ]; then
	#enforce init.d script perms on any post-root added files
	chmod 755 /system/etc/init.d
	chmod 755 /system/etc/init.d/*
	if [ "`grep "init.d" /system/etc/init.sec.boot.sh`" = "" ]; then
		# run init.d scripts
		if [ -d /system/etc/init.d ]; then
		  run-parts /system/etc/init.d
		fi
	fi
fi

sleep 1;

busybox mount -t rootfs -o remount,ro rootfs
busybox mount -o remount,ro /system

sleep 1;