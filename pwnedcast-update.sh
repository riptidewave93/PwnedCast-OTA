#!/bin/busybox

#Start infinite loop to imitate the google updater
while true
do
	echo "PWNEDCAST-OTA: Running PwnedCast OTA Updater!"

	#are we allowed to run?
	if [ -f /data/disable_ota ]
	then
		echo "PWNEDCAST-OTA: OTA updates disabled per user request, Terminating"
		
		# Create a empty loop so this script is never ran again.
		while true
		do
			sleep 72000
		done
		
		# Somehow, if we break out, exit, do NOT continue!
		exit 0
	fi

	#delete any existing OTA
	if [ -f /cache/flashcast.zip ]
	then
		rm /cache/flashcast.zip
	fi

	#variables
	BuildVersion="$(getprop ro.build.version.incremental)"
	Serial="$(cat /factory/serial.txt)"
	URL="http://servernetworktech.com/pwnedcast-ota/update.php?version=$BuildVersion&serial=$Serial"

	#Check for the update
	echo "PWNEDCAST-OTA: Checking for Updates"
	Response="$(busybox wget -q $URL -O - )"

	# Error checking for update, due to server/web issues
	if [ $? -ne 0 ]
	then
		echo "PWNEDCAST-OTA: Error Checking for update, Connection Issues"
		echo "PWNEDCAST-OTA: Restarting Service in 5 Minutes"
		sleep 300
		exit 1
	# Update is available, do something
	elif [ "$Response" != "NoUpdate" ]
	then
		echo "PWNEDCAST-OTA: Update Found! Downloading now!"
		busybox wget -q "$Response" -O /cache/eureka_image.zip
		if [ $? -ne 0 ];
		then
			echo "PWNEDCAST-OTA: Error Downloading, Terminating!"
			rm /cache/flashcast.zip
			exit 1
		else
			echo "PWNEDCAST-OTA: Update Downloaded Successfully"
			echo "PWNEDCAST-OTA: Rebooting into Flashcast To Update..."
			reboot recovery
		fi
	else
		echo "PWNEDCAST-OTA: No Update Required!"
	fi

	# sleep a while
	echo "PWNEDCAST-OTA: Sleeping 20 hours"
	sleep 72000

done
