#!/bin/bash

function countdown
{
    local OLD_IFS="${IFS}"
    IFS=":"
    local ARR=( $1 )
    local SECONDS=$((  (ARR[0] * 60 * 60) + (ARR[1] * 60) + ARR[2]  ))
    local START=$(date +%s)
    local END=$((START + SECONDS))
    local CUR=$START

    while [[ $CUR -lt $END ]]
        do
            CUR=$(date +%s)
            LEFT=$((END-CUR))
            printf "\r%02d:%02d:%02d" \
                   $((LEFT/3600)) $(( (LEFT/60)%60)) $((LEFT%60))
            sleep 1
        done

    IFS="${OLD_IFS}"
    echo "        "
}

# Variables
DEVICE=$1
TARGET_PRODUCT=$2
T=$PWD
OUT=$T/out/target/product/$DEVICE
MODVERSION=`sed -n -e'/ro\.modversion/s/^.*=//p' $OUT/system/build.prop`
OUTVERSION="exodus-$TARGET_PRODUCT"_"$MODVERSION.zip"

if [ -z "$OUT" -o ! -d "$OUT" ]; then
    echo -e $CL_RED"ERROR: $0 only works with a full build environment. $OUT should exist."$CL_RST
    exit 1
fi

if [ -f $OUT/$OUTVERSION ]; then
    echo "AUTOFLASHING THE ROM..."
    echo "hit control-c to cancel"
    echo ""
    echo "Starting in"
    countdown "00:00:05"
    echo ""
    echo "Transfering $OUTVERSION..."
else
    echo "target file does not exist!"
    exit 1
fi

#  This is the correct way to do things.. but i'm running into permissions issues with sepolicy changes
#adb shell "mkdir -p /cache/recovery/"
#adb shell "echo 'boot-recovery ' > /cache/recovery/command"
#adb shell "echo '--update_package=/sdcard/:$OUTVERSION' >> /cache/recovery/command"
#adb shell "echo 'reboot' >> /cache/recovery/command"

#  Workaround
adb push $OUT/$OUTVERSION /sdcard/$OUTVERSION && echo "" && echo "Sleeping until we're safetly in recovery..."
adb shell "reboot recovery" && sleep 40 && wait 
echo "Be patient: flashing..."
echo `adb shell recovery --update_package=/sdcard/$OUTVERSION`




