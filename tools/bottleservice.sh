#!/bin/bash

# nuclearmistake 2013
champagne()
{
    source build/envsetup.sh >& /dev/null
    local TARGET_KERNEL_SOURCE=`get_build_var TARGET_KERNEL_SOURCE`
    local TARGET_NO_KERNEL=`get_build_var TARGET_NO_KERNEL`
    local TARGET_KERNEL_VERSION=`get_build_var TARGET_KERNEL_VERSION`

    device=`get_build_var TARGET_DEVICE`

    devicedir="`find device -name "$device" -type d | head -n 1`"
    if [ ! $devicedir ] || [ `echo $devicedir | wc -c` -le 1 ]; then
        devicedir="`find device -name '*'"$device" -type d | head -n 1`"
    fi
    if [ ! $devicedir ] || [ `echo $devicedir | wc -c` -le 1 ]; then
        devicedir="`find device -name "$device"'*' -type d | head -n 1`"
    fi
    if [ ! $devicedir ] || [ `echo $devicedir | wc -c` -le 1 ]; then
        echo "$device IS A SACK OF CRAP AND SO ARE YOU."
        return 1
    fi

    if [ $TARGET_NO_KERNEL ] && [ "$TARGET_NO_KERNEL" = "true" ]; then
        return 0
    fi

    if [ ! $TARGET_KERNEL_SOURCE ]; then
        TARGET_KERNEL_SOURCE=`echo $devicedir | sed -e 's/^device/kernel/g'`
    fi

    kernelsource="android_`echo $TARGET_KERNEL_SOURCE | sed 's/\//_/g'`"

    source .repo/manifests/kernel_special_cases.sh $device
    [ ! $remote ] && remote=$defaultremote
    [ ! $remoterevision ] && remoterevision=$defaultrevision

    if [ ! -e .repo/local_manifests ] || [ ! -e .repo/local_manifests/bottleservice.xml ]; then
        mkdir -p .repo/local_manifests
        echo '<?xml version="1.0" encoding="UTF-8"?>
    <manifest>
    </manifest>' > .repo/local_manifests/bottleservice.xml
    fi
    needschecking=
    if [ `cat .repo/local_manifests/bottleservice.xml | egrep "path=\"$TARGET_KERNEL_SOURCE\"" | wc -l` -gt 1 ]; then
       echo " UH OH! You have duplicate repos for $TARGET_KERNEL_SOURCE in bottleservice.xml" 1>&2
       echo " Let's pick one arbitrarily and get rid of the rest." 1>&2
       line=`cat .repo/local_manifests/bottleservice.xml | egrep "path=\"$TARGET_KERNEL_SOURCE\"" | tail -n 1`
       cat .repo/local_manifests/bottleservice.xml | grep -v "</manifest>" | egrep -v "path=\"$TARGET_KERNEL_SOURCE\"" > .repo/local_manifests/tmp.xml
       echo "$line" >> .repo/local_manifests/tmp.xml
       echo "</manifest>" >> .repo/local_manifests/tmp.xml
       mv .repo/local_manifests/tmp.xml .repo/local_manifests/bottleservice.xml
       needschecking=1
    fi
    getkernelline='path="'$TARGET_KERNEL_SOURCE'" name="'$kernelsource'"'
    [ $remote ] && getkernelline=$getkernelline' remote="'$remote'"'
    [ $remoterevision ] && getkernelline=$getkernelline' revision="'$remoterevision'"'
    haskernelline=`cat .repo/local_manifests/bottleservice.xml | egrep "$getkernelline" | wc -l`
    hasdevice=`cat .repo/local_manifests/bottleservice.xml | egrep "<!-- $device -->" | wc -l`
    if [ $precompiled ] && [ $hasdevice -gt 0 ] || [ $hasdevice -gt 0 ] && [ $haskernelline -eq 0 ]; then
       #device comment is in the file, but its kernel is the wrong one
       line=`cat .repo/local_manifests/bottleservice.xml | egrep "<!-- $device -->"`
       cat .repo/local_manifests/bottleservice.xml | grep -v "</manifest>" | egrep -v "$line" > .repo/local_manifests/tmp.xml
       remainingdevs=""
       echo " removing $device from previous kernel line: $line" 1>&2
       for x in `echo $line | sed 's/.*\/> //g' | sed 's/<!-- //g' | sed 's/ -->/ /g'`; do
           if [ ! "$device" = $x ]; then
               remainingdevs="$remainingdevs $x"
           fi
       done
       if [ `echo $remainingdevs | wc -c` -gt 1 ]; then
           needschecking=1
           comments=""
           for x in $remainingdevs; do
              comments="$comments<!-- $x -->"
           done
           echo " remaining line that used to have device = `echo "$line" | sed 's/<!--.*//g'`$comments" 1>&2
           echo "`echo "$line" | sed 's/<!--.*//g'`$comments" >> .repo/local_manifests/tmp.xml
       else
           echo " deleting line used by no devices" 1>&2
       fi
       echo "</manifest>" >> .repo/local_manifests/tmp.xml
       mv .repo/local_manifests/tmp.xml .repo/local_manifests/bottleservice.xml
    elif [ $haskernelline -gt 0 ] && [ $hasdevice -eq 0 ]; then
        #device's kernel is in the file, but device comment isn't added yet
        line=`cat .repo/local_manifests/bottleservice.xml | egrep "$getkernelline"`
        echo "Adding $device to already existing kernel line: $line" 1>&2
        cat .repo/local_manifests/bottleservice.xml | egrep -v "$line" | grep -v "</manifest>" > .repo/local_manifests/tmp.xml
        echo "$line <!-- $device -->" >> .repo/local_manifests/tmp.xml
        echo "</manifest>" >> .repo/local_manifests/tmp.xml
        mv .repo/local_manifests/tmp.xml .repo/local_manifests/bottleservice.xml
    fi
    if [ ! $precompiled ] && [ $haskernelline -eq 0 ]; then
        #if bottlservice is prevented (which is useful to maintain versioning consistency while building nightlies, then we should exit non-zero here
        if [ $VANIR_BOTTLESERVICE_DISABLE ]; then
            echo "WARNING: SKIPPING BOTTLESERVICE FOR $device, WHICH NEEDS A F&^%ING BOTTLE SERVED TO IT."
            return 1
        fi
        #add kernel to the file
        echo " "
        echo " VANIR BOTTLESERVICE. YOU KNOW HOW WE DO."
        echo " "
        echo " Adding a line for $device's kernel to .repo/local_manifests/bottleservice.xml,
        and adding another bottle of Cristal to your tab."
        echo " "
        cat .repo/local_manifests/bottleservice.xml | grep -v '</manifest>' > .repo/local_manifests/tmp.xml
        NEWLINE="<project path=\"$TARGET_KERNEL_SOURCE\" name=\"$kernelsource\""
        [ $remote ] && NEWLINE="$NEWLINE remote=\"$remote\""
        [ $remoterevision ] && NEWLINE="$NEWLINE revision=\"$remoterevision\""
        NEWLINE="$NEWLINE /> <!-- $device -->"
        echo "  $NEWLINE" >> .repo/local_manifests/tmp.xml
        echo "</manifest>" >> .repo/local_manifests/tmp.xml
        mv .repo/local_manifests/tmp.xml .repo/local_manifests/bottleservice.xml
        echo " Added:  $NEWLINE to bottleservice.xml"
        if  [ ! $IN_THE_MIDDLE_OF_CASCADING_RESYNC ]; then
            if [ $needschecking ]; then
                echo ""
                echo "*** It looks like the bottleservice project for multiple device was changed." 1>&2
                echo "*** Double-checking validity of all bottleserviced devices' kernel projects by automagically re-lunching them" 1>&2
                echo ""
                export IN_THE_MIDDLE_OF_CASCADING_RESYNC=1
                cat .repo/local_manifests/bottleservice.xml | grep project | sed 's/.*\/>//g' | sed 's/<!--//g' | sed 's/-->//g' | while read line ; do
                  for x in $line; do
                    for choice in ${LUNCH_MENU_CHOICES[@]}; do
                        if [[ $choice == *$x* ]] && [[ $choice == vanir_* ]]; then
                            lunch $choice && echo "RE-LUNCHED $choice"&& break
                        fi
                    done
                  done
                done
            fi
            echo " "
            echo " re-syncing!" 1>&2
            reposync -c -f -j32
            echo " "
            echo " re-sync complete" 1>&2
        fi
    fi
    unset IN_THE_MIDDLE_OF_CASCADING_RESYNC
    return 0
}
