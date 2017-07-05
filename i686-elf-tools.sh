#!/bin/bash

# i686-elf-tools.sh
# v1.1

BINUTILS_VERSION=2.28
GCC_VERSION=7.1.0
GDB_VERSION=8.0

BUILD_DIR="$HOME/build-i686-elf"
export PATH="$BUILD_DIR/linux/output/bin:$BUILD_DIR/windows/output/bin:$PATH"

set -e

if [ $# -eq 0 ]
then
        args="binutils gcc gdb zip"
else
        args=$@
fi



function main {

    installPackages
    installMXE
    downloadSources
    
    if [[ $args == *"win"* ]]; then
        echoColor "Skipping compiling linux as 'win' was specified in commandline args '$args'"
    else    
        compileAll "linux"
    fi
    
    if [[ $args == *"win"* ]]; then
        echoColor "Skipping compiling linux as 'linux' was specified in commandline args '$args'"
    else    
        compileAll "windows"
    fi
        
    finalize
}

function installPackages {
    
    echoColor "Installing packages"

    sudo -E apt-get install git \
        autoconf automake autopoint bash bison bzip2 flex gettext\
        git g++ gperf intltool libffi-dev libgdk-pixbuf2.0-dev \
        libtool libltdl-dev libssl-dev libxml-parser-perl make \
        openssl p7zip-full patch perl pkg-config python ruby scons \
        sed unzip wget xz-utils libtool-bin texinfo g++-multilib -y
}

# MXE

function installMXE {

    echoColor "Installing MXE"

    if [ ! -d "/opt/mxe/usr/bin" ]
    then
        echoColor "    Cloning mxe and compiling mingw32.static GCC"
        cd /opt
        sudo -E git clone https://github.com/mxe/mxe.git
        cd mxe
        sudo make gcc

        echo "export PATH=/opt/mxe/usr/bin:$PATH" >> ~/.bashrc
        export PATH=/opt/mxe/usr/bin:$PATH
    else
       echoColor "    mxe is already installed. You'd better make sure /opt/mxe/usr/bin is on your path!"
    fi
}

# Downloads

function downloadSources {
    mkdir -p $BUILD_DIR
    cd $BUILD_DIR
    
    echoColor "Downloading all sources"
    
    downloadAndExtract "binutils" $BINUTILS_VERSION

    downloadAndExtract "gcc" $GCC_VERSION "http://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz"
    
    echoColor "        Downloading GCC prerequisites"
    
    # Automatically download GMP, MPC and MPFR. These will be placed into the right directories.
    # You can also download these separately, and specify their locations as arguments to ./configure
    cd ./linux/gcc-$GCC_VERSION
    ./contrib/download_prerequisites
    cd ../../windows/gcc-$GCC_VERSION
    ./contrib/download_prerequisites
    cd ../..
    
    downloadAndExtract "gdb" $GDB_VERSION    
}

function downloadAndExtract {
    name=$1
    version=$2
    override=$3
    
    pwd
    
    echoColor "    Processing $name"
    
    if [ ! -f $name-$version.tar.gz ]
    then
        echoColor "        Downloading $name-$version.tar.gz"
        
        if [ -z $3 ]
        then
            wget http://ftp.gnu.org/gnu/$name/$name-$version.tar.gz
        else
            wget $override
        fi
    else
        echoColor "        $name-$version.tar.gz already exists"
    fi
    
    if [ ! -f linux ]
    then
        mkdir -p linux
    fi
    
    cd linux
    
    if [ ! -d $name-$version ]
    then
        echoColor "        [linux]   Extracting $name-$version.tar.gz"
        tar -xf ../$name-$version.tar.gz
    else
        echoColor "        [linux]   Folder $name-$version already exists"
    fi
    
    cd ..
    
    if [ ! -f windows ]
    then
        mkdir -p windows
    fi
    
    cd windows
    
    if [ ! -d $name-$version ]
    then
        echoColor "        [windows] Extracting $name-$version.tar.gz"
        tar -xf ../$name-$version.tar.gz
    else
        echoColor "        [windows] Folder $name-$version already exists"        
    fi
    
    cd ..
}

function compileAll {

    echoColor "Compiling all $1"
    
    cd $1
    
    mkdir -p output

    compileBinutils $1
    compileGCC $1
    compileGDB $1
    
    cd ..
}

function compileBinutils {    
    if [[ $args == *"binutils"* ]]; then
        echoColor "    Compiling binutils [$1]"
    
        mkdir -p build-binutils-$BINUTILS_VERSION
        cd build-binutils-$BINUTILS_VERSION
        
        configureArgs="--target=i686-elf --with-sysroot --disable-nls --disable-werror --prefix=$BUILD_DIR/$1/output"
        
        if [ $1 == "windows" ]
        then
            configureArgs="--host=i686-w64-mingw32.static $configureArgs"
        fi
        
        # Configure
        echoColor "        Configuring binutils (binutils_configure.log)"
        ../binutils-$BINUTILS_VERSION/configure $configureArgs >> binutils_configure.log
        
        # Make
        echoColor "        Making (binutils_make.log)"
        make >> binutils_make.log
        
        # Install
        echoColor "        Installing (binutils_install.log)"
        sudo make install >> binutils_install.log
        cd ..
    else
        echoColor "    Skipping binutils [$1] as 'binutils' was ommitted from commandline args '$args'"
    fi
}

function compileGCC {
    if [[ $args == *"gcc"* ]]; then
    
        echoColor "    Compiling gcc [$1]"

        mkdir -p build-gcc-$GCC_VERSION
        cd build-gcc-$GCC_VERSION
        
        configureArgs="--target=i686-elf --disable-nls --enable-languages=c,c++ --without-headers --prefix=$BUILD_DIR/$1/output"
        
        if [ $1 == "windows" ]
        then
            configureArgs="--host=i686-w64-mingw32.static $configureArgs"
        fi
        
        # Configure
        echoColor "        Configuring gcc (gcc_configure.log)"
        ../gcc-$GCC_VERSION/configure $configureArgs >> gcc_configure.log
        
        # Make GCC
        echoColor "        Making gcc (gcc_make.log)"
        make all-gcc >> gcc_make.log
        
        # Install GCC
        echoColor "        Installing gcc (gdb_install.log)"
        sudo make install-gcc >> gcc_install.log
        
        # Make libgcc
        echoColor "        Making libgcc (libgcc_make.log)"
        make all-target-libgcc >> libgcc_make.log
        
        # Install libgcc
        echoColor "        Installing libgcc (libgcc_install.log)"
        sudo make install-target-libgcc >> libgcc_install.log
        
        
        
        
        #instead of compiling libgcc the way we're doing, what if we tried to manually run its configure script and specified the host as i686-w64-mingw32.static?
        

        

        cd ..
    else
        echoColor "    Skipping gcc [$1] as 'gcc' was ommitted from commandline args '$args'"
fi
}

function compileGDB {
    if [[ $args == *"gdb"* ]]; then

        echoColor "    Compiling gdb [$1]"
    
        configureArgs="--target=i686-elf --disable-nls --disable-werror --prefix=$BUILD_DIR/$1/output"
        
        if [ $1 == "windows" ]
        then
            configureArgs="--host=i686-w64-mingw32.static $configureArgs"
        fi
    
        mkdir -p build-gdb-$GDB_VERSION
        cd build-gdb-$GDB_VERSION
        
        # Configure        
        echoColor "        Configuring (gdb_configure.log)"
        ../gdb-$GDB_VERSION/configure $configureArgs >> gdb_configure.log
        
        # Make
        echoColor "        Making (gdb_make.log)"
        make >> gdb_make.log
        
        # Install
        echoColor "        Installing (gdb_install.log)"
        sudo make install >> gdb_install.log
        cd ..
    else
        echoColor "    Skipping gdb [$1] as 'gdb' was ommitted from commandline args '$args'"
    fi
}

function finalize {
    if [[ $args == *"zip"* ]]; then
        echo "Zipping everything up!"
        cd $BUILD_DIR/windows/output
        zip -r $BUILD_DIR/i686-elf-tools-windows.zip *
        cd $BUILD_DIR/linux/output
        zip -r $BUILD_DIR/i686-elf-tools-linux.zip *
        echo -e "\e[92mZipped everything to $BUILD_DIR/i686-elf-tools-[windows | linux].zip\e[39m"
    else
        echoColor "    Skipping zipping 'zip' was ommitted from commandline args '$args'"
    fi
}

function echoColor {
    echo -e "\e[96m$1\e[39m"
}

main