#!/bin/bash
source build/envsetup.sh
if [ $? != 0 ] ; then
    echo "must be called from build root dir -> failed"
    exit 255
fi
dow="$(date +'%A')"
fd="$(date)"
echo $dow
dname=$ANDROID_BUILD_TOP/nightly_build_results
fname=$ANDROID_BUILD_TOP/vendor/exodus/devices/build-$dow
if [ -f ~/build-results ] ; then
    rm ~/build-results
fi
if [ ! -d $dname ]; then
    cd $ANDROID_BUILD_TOP
    git clone git@github.com:TeamExodus/nightly_build_results
fi
cd $dname
git fetch && git checkout origin/EXODUS-5.1
if [ -d latest ] ; then
    git rm -r latest
fi
if [ -d latest ] ; then
    rm -rf latest
fi
mkdir latest
cd $ANDROID_BUILD_TOP
resname=$dname/latest/build-results
if [ -f $fname ] ; then
    echo "Todays($fd) meal list:" >$resname
    IFS=$'\n' read -d '' -r -a lines < $fname
    cnt=0
    for LINE in "${lines[@]}"
    do
        LINE="$(echo -e "${LINE}" | tr -d '[[:space:]]')"
        if [[ ${LINE:0:1} != '#' ]] ; then
            echo "$LINE waiting..."  >>$resname
            let cnt=cnt+1
        fi
    done
    idx=0
    for LINE in "${lines[@]}"
    do
        LINE="$(echo -e "${LINE}" | tr -d '[[:space:]]')"
        if [[ ${LINE:0:1} != '#' ]] ; then
                let idx=idx+1
                perc=$(echo "scale=0; $idx*100/$cnt" | bc)
                echo "building $LINE now ( ${perc}%)"
                lognam=$dname/latest/build_$LINE.log
                wl="$LINE waiting..."
                bl="$LINE building..."
                fl="$LINE failed to build"
                sl="$LINE successfully build"
                sed -i -e "s/$wl/$bl/g" $resname
                time build/tools/server/compile.sh exodus-5.1 $LINE >$lognam 2>&1
                if [ $? -ne 0 ] ; then
                    sed -i -e "s/$bl/$fl/g" $resname
                else
                    sed -i -e "s/$bl/$sl/g" $resname
                fi
                echo "-----------------------------"
        fi
    done
    cd $dname
    git add *
    git commit -a -m "Build result for $fd"
    git push origin HEAD:EXODUS-5.1
else
    echo "seems to be a day off for me !"
fi
