#!/bin/bash####################################################################
##                                                                           ##
## A simple build tool to compile the kernel from the custom rom source root ##
## The output file is located in the TARGET_DEVICE product /out directory    ##
## named $(TARGET_DEVICE)_kernel.zip.  This script will automatically create ##
## a subtree of our AnyKernel formatting tool to be used in the process      ##
## which is located at https://github.com/TeamExodus/AnyKernel2/             ##
##                                                                           ##
## Dave Kessler <activethrasher00@gmail.com>                                 ##
## github: AlmightyMegadeth00                                                ##
## Written for Vanir-Exodus 1/11/15                                          ##
##                                                                           ##
## Alex Naidis <alex.naidis@linux.com>                                       ##
## github: TheCrazyLex                                                       ##
## Updated for Exodus September 2015                                         ##
###############################################################################

CL_YLW="\033[33m"
CL_RST="\033[0m"
CL_RED="\033[31m"
CL_CYN="\033[36m"

DATE_START=$(date +"%s")
DATE=`date +%m%d%Y`
CORES=`nproc --all`
SET_CORES="-j$CORES"

export KBUILD_BUILD_USER=Reactor
export KBUILD_BUILD_HOST=Exodus

# Inherited build variables
DEVICE=$1
TOOLCHAIN=$2
TARGET_KERNEL_SOURCE=$3
TARGET_KERNEL_CONFIG=$4

# Directories
T=$PWD
OUT=$T/out/target/product/$DEVICE
ANYKERNEL=$T/build/tools/AnyKernel2

# Add our AnyKernel repo as a subtree to prevent metadata generation and uncommited changes
if [ ! -d "$ANYKERNEL" ]; then
    cd $T/build
    echo "AnyKernel tool not detected... cloning into a subtree"
    echo -e `git subtree add --prefix tools/AnyKernel2 https://github.com/TeamExodus/AnyKernel2.git EXODUS-5.1 --squash`
else
    echo ""
fi
# double check...
if [ ! -d "$ANYKERNEL" ]; then
    exit 1;
fi

cd $T/$TARGET_KERNEL_SOURCE
#sed -i s/CONFIG_LOCALVERSION=\".*\"/CONFIG_LOCALVERSION=\"~${DEVICE}_kernel\"/ arch/arm/configs/$TARGET_KERNEL_CONFIG

echo ""
echo -e $CL_RST"Cleaning up..."
make clean && make mrproper; sleep 3; make distclean; sleep 3;
rm -rfv .config; rm -rfv .config.old

echo ""
echo ""
echo -e $CL_RST"Compiling..."

# TO DO: make toolchain location var more flexible
make CROSS_COMPILE=$TOOLCHAIN/arm-eabi- ARCH=arm $TARGET_KERNEL_CONFIG
make CROSS_COMPILE=$TOOLCHAIN/arm-eabi- ARCH=arm $SET_CORES

echo ""
echo ""
echo -e $CL_YLW"======================================="
echo -e $CL_RST"   Kernel compilation completed ... "
echo -e $CL_RST"   ... creating a flashable zip file"
echo -e $CL_YLW"======================================="
echo ""

cd $T/$TARGET_KERNEL_SOURCE

zipfile="${DEVICE}_kernel_$DATE.zip"
if [ ! $5 ]; then
    rm -f /tmp/*.img
    echo -e $CL_RST"making zip file"
    cp -vr arch/arm/boot/zImage $T/build/tools/AnyKernel2/
    find . -name \*.ko -exec cp '{}' AnyKernel/system/lib/modules/ ';'
    cd build/tools/AnyKernel2
            rm -f *.zip
            zip -r $zipfile *
            rm -f /tmp/*.zip
            mv *.zip /$OUT
fi

if [[ $1 == *exp* ]]; then
    if [[ $1 == *bm* ]]; then
            mf="44latestbigmem"
    else
            mf="44latestexp"
    fi
else
    mf="44latest"
fi

cd $T; cd $TARGET_KERNEL_SOURCE
ZIPSIZE=`ls -lah $zipfile | awk '{ print $5}' `
if [ -d "$T/host/darwin-x86" ]; then
OUT_TARGET_HOST="darwin-x86"
else
OUT_TARGET_HOST="linux-x86"
fi

echo ""
echo -e $CL_YLW"===================================================================================="
DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo -e $CL_YLW"               Kernel build:" $CL_RED"completed" $CL_RST"in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo -e $CL_YLW"===================================================================================="
echo ""

if [ -f $OUT/$zipfile ]; then
	echo -e $CL_YLW"  Signing zip ..."
	echo -e $CL_YLW"      ... this will take a moment to finish"
	SECURITYDIR=$T/build/target/product/security
	java -Xmx2048m \
		-jar $T/out/host/$OUT_TARGET_HOST/framework/signapk.jar \
		-w $SECURITYDIR/testkey.x509.pem $SECURITYDIR/testkey.pk8 \
		$OUT/$zipfile $zipfile
    OUTPUT_STRING="SUCCESSFUL!"
    
    echo ""
	echo -e $CL_YLW"  Cleaning up auto-generated files..."$CL_RST
	echo `make mrproper`
	echo `rm -f $T/$TARGET_KERNEL_SOURCE/$zipfile`
else
    OUTPUT_STRING="UNSUCCESSFULL!"
fi

echo ""
echo -e $CL_YLW"===================================================================================="
echo -e $CL_YLW"                                 BUILD:"$CL_RST" $OUTPUT_STRING"
echo -e $CL_YLW"===================================================================================="
echo ""
echo -e $CL_YLW"  Package Size: "$CL_RST"$ZIPSIZE     "
echo -e $CL_YLW"  Zip file location:"
if [ -f $OUT/$zipfile ]; then
    echo -e $CL_RST"      $OUT/"$CL_CYN"$zipfile" $CL_RST
    echo ""
fi

