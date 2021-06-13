#!/bin/sh

ROOTDIR=`pwd`
BUILD_DIR=$ROOTDIR/.build
TARGET=powerpc64-xenon-elf
PREFIX=/tmp/toolchain_wip

PROCS="$(nproc --all 2>&1)" || ret=$?
if [ ! -z $ret ]; then PROCS=4; fi

BINUTILS=binutils-2.36.1
GCC=gcc-11.1.0
NEWLIB=newlib-4.1.0

echo "[*] Root dir: $ROOTDIR"
echo "[*] Build dir: $BUILD_DIR"
echo "[*] Parallel procs: $PROCS"

function fail_with_info()
{
	echo "[-] Script failed" >> /dev/stderr
	exit 1
}

if [ ! -d $ROOTDIR/$BINUTILS ]; then echo "[-] BINUTILS source dir missing: $ROOTDIR/$BINUTILS" && fail_with_info; fi
if [ ! -d $ROOTDIR/$GCC ]; then echo "[-] GCC source dir missing: $ROOTDIR/$GCC" && fail_with_info; fi
if [ ! -d $ROOTDIR/$NEWLIB ]; then echo "[-] NEWLIB source dir missing: $ROOTDIR/$NEWLIB" && fail_with_info; fi

rm -rf $PREFIX && mkdir $PREFIX
rm -rf $BUILD_DIR && mkdir $BUILD_DIR

COMMON_CONFIGURE_FLAGS=" --enable-altivec --enable-lto "
COMMON_CONFIGURE_FLAGS+="--with-cpu=cell "
COMMON_CONFIGURE_FLAGS+="--disable-werror --disable-decimal-float --disable-nls --disable-shared --disable-linux-futex --disable-threads "
COMMON_CONFIGURE_FLAGS+="--disable-libmudflap --disable-libssp --disable-libquadmath --disable-libgomp --disable-libitm "

if [ ! -f $ROOTDIR/.built_binutils ]
then
    rm -rf $BUILD_DIR/binutils && mkdir $BUILD_DIR/binutils && cd $BUILD_DIR/binutils

    echo "[+] Configuring binutils"
    $ROOTDIR/$BINUTILS/configure --prefix=$PREFIX --target=$TARGET \
        $COMMON_CONFIGURE_FLAGS \
        --enable-multilib || fail_with_info

    echo "[+] Building binutils"
    make -j $PROCS || fail_with_info
    echo "[+] Installing binutils"
    make install || fail_with_info

    # Setting flag
    touch $ROOTDIR/.built_binutils
else
    echo "[*] Binutils already built"
fi

if [ ! -f $ROOTDIR/.built_gcc_newlib ]
then
    rm -rf $BUILD_DIR/gcc && mkdir $BUILD_DIR/gcc && cd $BUILD_DIR/gcc

    echo "[+] Creating newlib symlink"
    rm -rf $ROOTDIR/$GCC/newlib
    ln -s $ROOTDIR/$NEWLIB $ROOTDIR/$GCC/newlib

    echo "[+] Configuring gcc / newlib"
    $ROOTDIR/$GCC/configure --prefix=$PREFIX --target=$TARGET \
        $COMMON_CONFIGURE_FLAGS \
        --enable-languages=c,c++ \
        --with-newlib \
        --disable-libstdcxx-time \
        --disable-libsanitizer \
        --disable-libatomic || fail_with_info

    echo "[+] Building gcc w/ newlib"
    make -j $PROCS || fail_with_info

    echo "[+] Installing gcc w/ newlib"
    make install || fail_with_info

    touch $ROOTDIR/.built_gcc_newlib
else
    echo "[*] GCC / Newlib already built"
fi