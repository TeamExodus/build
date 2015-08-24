export BuildBranch=$1
export BuildDevice=$2
export USE_PREBUILT_CHROMIUM=1
export todaystring=`date +%m-%d-%Y`
createchangelog="Y"
export ChangelogPath=${ANDROID_BUILD_TOP}/Changelog-$todaystring.txt

source build/envsetup.sh
if [ $? != 0 ] ; then
	echo "must be called from build root dir -> failed"
	exit 255
fi

#Buildscript
cd ${ANDROID_BUILD_TOP}

# We now want only to create Changelog once per day or if not existing
export CHANGELOG=false
echo "checking for changelog"
if [ -f $ChangelogPath ] ; then
        createchangelog="N"
fi

if [ $createchangelog == "Y" ] ; then
    echo 'creating changelog...'
    ${ANDROID_BUILD_TOP}/vendor/exodus/utils/changelog.sh $ChangelogPath
fi

#Build Environment configuration
export BUILD_WITH_COLORS=0
export USE_CCACHE=1
export CCACHE_DIR=/ccache/${BuildBranch}/${BuildDevice}

prebuilts/misc/linux-x86/ccache/ccache -M 10G

#The Build
export CM_BUILDTYPE=NIGHTLY
if brunch ${BuildDevice} ; then

	if [ ! -d /var/www/html/${BuildBranch}/${BuildDevice} ]; then
	    mkdir -p /var/www/html/${BuildBranch}/${BuildDevice}
	fi
    OUTFILE=$(ls $OUT/*-${CM_BUILDTYPE}-*.zip | sort -V | tail -n 1)
    WEBVERSION=$(basename $OUTFILE)
    UPDATENAME="${WEBVERSION%.*}"
	# Determine what to name the new signed package
    UTCDATE=`sed -n -e'/ro\.build\.date\.utc/s/^.*=//p' $OUT/system/build.prop`
    DESTPATH=/var/www/html/${BuildBranch}/${BuildDevice}
    cd $OUT
    tIndexEntry=$UPDATENAME
    tIndexEntry+=";"
    tIndexEntry+=`md5sum $WEBVERSION`
    tIndexEntry+=";"
    tIndexEntry+=$UTCDATE
    tIndexEntry+=";22"
    IndexEntry="${tIndexEntry/$Searchfor/$OFFICIAL}"       
    if grep -q "$UPDATENAME" ${DESTPATH}/exodus_update_list
    then
        echo "removing old entry"
        sed -i "/^${UPDATENAME}/d" ${DESTPATH}/exodus_update_list
    fi
    echo "Adding new update entry"
    echo "$IndexEntry" >> ${DESTPATH}/exodus_update_list
    cd ${ANDROID_BUILD_TOP}
    cp $OUTFILE $DESTPATH/$WEBVERSION
    cp $OUTFILE.md5sum $DESTPATH/$WEBVERSION.md5
    cp $ChangelogPath ${DESTPATH}/${WEBVERSION}.changelog
    rm -rf ${OUT}
    echo "${OUT} removed"
else
    echo "Build failed"
    rm -rf ${OUT}
    echo "${OUT} removed"
	exit 255    
fi
