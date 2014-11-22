#!/bin/bash
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' autogen|grep "install ok installed")
echo Checking for autogen: $PKG_OK
if [ "" == "$PKG_OK" ]; then
  echo "autogen is required to build ccache and was not found."
  echo "installing autogen..."
  sudo apt-get --force-yes --yes install autogen
fi

if [ -e ./ccache/ccache ] && grep $(./ccache/ccache -V | grep "ccache version" | awk '{print $3}') ccache/version.c 2>&1 >/dev/null; then
    # ccache exists and its --version output matches the latest source
    echo "ccache is up to date" 1>&2
else
    echo "building ccache binary" 1>&2
    pushd ccache 2>&1 >/dev/null
    ./autogen.sh 1>&2
    ./configure 1>&2
    make 1>&2
    popd 2>&1 >/dev/null
    echo "ccache updated to version `ccache/ccache -V`" 1>&2
fi
