# i686-elf-tools.sh
# v1.0

BINUTILS_VERSION=2.25
GCC_VERSION=5.3.0
GDB_VERSION=7.10

# MXE

export PATH=/opt/mxe/usr/bin:$PATH
echo "export PATH=/opt/mxe/usr/bin:$PATH" >> ~/.bashrc

sudo apt-get install wine git \
    autoconf automake autopoint bash bison bzip2 flex gettext\
    git g++ gperf intltool libffi-dev libgdk-pixbuf2.0-dev \
    libtool libltdl-dev libssl-dev libxml-parser-perl make \
    openssl p7zip-full patch perl pkg-config python ruby scons \
    sed unzip wget xz-utils libtool-bin texinfo -y

cd /opt
sudo git clone https://github.com/mxe/mxe.git
cd mxe
sudo make gcc

# Downloads

cd ~
wget http://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.gz
wget ftp://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz
wget http://ftp.gnu.org/gnu/gdb/gdb-$GDB_VERSION.tar.gz

tar -xvf binutils-$BINUTILS_VERSION.tar.gz
tar -xvf gcc-$GCC_VERSION.tar.gz
tar -xvf gdb-$GDB_VERSION.tar.gz

# Automatically download GMP, MPC and MPFR. These will be placed into the right directories.
# You can also download these separately, and specify their locations as arguments to ./configure
cd gcc-$GCC_VERSION
./contrib/download_prerequisites
cd ..

# Binutils

mkdir build-binutils-$BINUTILS_VERSION
cd build-binutils-$BINUTILS_VERSION
../binutils-$BINUTILS_VERSION/configure --host=i686-w64-mingw32.static --target=i686-elf --with-sysroot --disable-nls --disable-werror
make
sudo make install
cd ..

# GCC

mkdir build-gcc-$GCC_VERSION
cd build-gcc-$GCC_VERSION
../gcc-$GCC_VERSION/configure --host=i686-w64-mingw32.static --target=i686-elf --disable-nls --enable-languages=c,c++ --without-headers
sed -i 's:$(GCC_FOR_TARGET) -dumpspecs > tmp-specs: wine ./xgcc$(exeext) -dumpspecs > tmp-specs:g' gcc/Makefile
make all-gcc
sudo make install-gcc
cd ..

# GDB

mkdir build-gdb-$GDB_VERSION
cd build-gdb-$GDB_VERSION
../gdb-$GDB_VERSION/configure --host=i686-w64-mingw32.static --target=i686-elf --disable-nls --disable-werror
make
sudo make install

# Finalize

zip -r i686-elf-tools.zip /usr/local/bin /usr/local/libexec
