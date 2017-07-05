# i686-elf-tools
Cross compiling an i386- or i686-elf Win32 toolchain is an outstandingly complicated and painful process. Both Binutils and GCC fail to properly articulate the extent of software dependencies required to build them, resulting in a litany of spurious and confusing error messages being emitted during compilation. Even once you do have the required software dependencies in place, you will still run into roadblocks due to anomalies in how GCC performs cross compilation.

This repo provides a set of precompiled binaries to those who want to use get what they came for and move on (an i686-elf toolchain that, **unlike others on the internet, includes cc1 and GDB**), as well as a set of instructions for those that would like to build these things themselves. Also featured are a set of instructions for those that wich to install these tools on Mac OS X or Linux.

## Win32
### Tutorial

By default, `i686-elf-tools.sh` will download

  * GCC 7.1.0
  * Binutils 2.28
  * GDB 8.0

If you would like to change these versions, open the script in your favourite text editor and change the values of `BINUTILS_VERSION`, `GCC_VERSION` and `GDB_VERSION`. Instead of using MinGW32 or MinGW64, [MXE](http://mxe.cc) is used, providing us with an awesome Win32 toolchain that always produces statically linked binaries that just work (and don't need random MinGW DLLs).

Note: if you already have MXE installed, `i686-elf-tools.sh` won't add MXE to your PATH. Please ensure the MXE bin folder is on your path, else you will experience issues during compilation.

1. Install a 32-bit (i386) version of Debian. This procedure was performed on top of the CD version of [Debian 9 i386](https://cdimage.debian.org/debian-cd/current/i386/iso-cd/debian-9.0.0-i386-xfce-CD-1.iso)

2. Remove the CD-ROM source from `/etc/apt/sources.list` (if applicable)

3. Run the following commands. `sudo -s` is optional, however if you are not running as root you will get repeated password request prompts during the course of the execution

    ```sh
    sudo -s
    wget https://raw.githubusercontent.com/lordmilko/i686-elf-tools/master/i686-elf-tools.sh
    chmod +x ./i686-elf-tools.sh
    ./i686-elf-tools.sh
    ```

4. When the script completes you will have two zip files containing your i686-elf toolchain

    * `~/build-i686-elf/i686-elf-tools-windows.zip`
    * `~/build-i686-elf/i686-elf-tools.linux.zip`

If you experience any issues, you can specify one or more command line arguments to only perform certain parts of the script. The following arguments are supported

* binutils
* gcc
* gdb
* zip - zip it all up!
* linux - compile the linux toolchain only
* win - compile the windows toolchain only

```sh
# Compile binutils and gcc only
./i686-elf-tools.sh binutils gcc
```

The `win` argument should only be used if the linux toolchain has already been compiled and you're experiencing issues with the Win32 part.

Logs are stored for each stage of the process under *~/build-i686-elf/build-**xyz**/**xyz**_**stage**.log*

e.g. **~/build-i686-elf/build-gcc-7.1.0/gcc_make.log**

If you attempt to run `make` and `configure` commands manually that depend on components of the linux i686-elf toolchain, ensure `~/build-i686-elf/linux/output/bin` is on your path, else you may get errors about binaries being missing.

## Mac OS X

Installing an i386-elf toolchain on Mac OS X is an outstandingly simple process

1. Install [Brew](http://brew.sh/)
2. Download the [i386-elf recepies](https://github.com/altkatz/homebrew-gcc_cross_compilers)
3. Copy `i386-elf-binutils.rb`, `i386-elf-gcc.rb` and `i386-elf-gdb.rb` to `/usr/local/Library/Formula`. As these formulae depend on one another, attempting to execute these directly with `brew install i386-elf-gcc.rb`, etc will fail.
4. Run `brew install i386-elf-binutils`, `brew install i386-elf-gcc` and `brew install i386-elf-gdb`

## Linux

Extract the contents of `i686-elf-tools-linux.zip` somewhere. By default GCC installs them under `/usr/local/`.

To compile a newer i686-elf toolchain, invoke `i686-elf-tools.sh` as follows

```sh
./i686-elf-tools.sh linux
```

## FAQ

### Why would I want to use this?
For building your own [Operating System](http://wiki.osdev.org/Bare_Bones), of course!

### How do I install this on Windows?
After copying `i686-elf-tools-windows.zip` to your PC, all necessary programs can be found in the `bin` folder. You can then put this folder in your `PATH`, or simply browse to the programs in this folder manually. When running these programs, it is important to make sure all of the subfolders are kept together, as files outside of the bin folder are required for certain programs (such as GCC).

### Does this include libgcc?
Seems so! For more information see the section *How on earth did you compile libgcc?* below.

### Can I use MSYS/MSYS2/MinGW/MinGW/MinGW-w32/MinGW-w64/Cygwin, etc to do this?
No. But you can try. I got all sorts of crazy errors I was simply unable to resolve when I was looking at solutions to compile these tools. I have successfully compiled on Windows in the past, however there have been two issues with this:
* Executables had dependencies on MinGW/Cygwin libraries (most likely as I just didn't know how to statically link)
* GDB would randomly quit whenever I tried to type a command

YMMV.

### Can I use `$DISTRO` instead of Debian?
I originally tried to use CentOS 7 64-bit, however along the way I encountered various issues potentially attributable to bitness, resulting in my switching to a 32-bit OS to simplify troubleshooting. CentOS 7 32-bit _cannot_ be used, as all the packages required by MXE are not available on yum. The ultimate showstopper however was I could not get Wine to execute my cross compiler (see above). Modifying Wine's bitness settings did not appear to resolve this.

If you are determined not to use Debian (or another Debian derivitive), please see the [prerequisites for MXE](http://mxe.cc/#requirements). Note: you may need additional packages to these to successfully compile gcc, e.g. _texinfo_, _readline-devel_, etc. Google any error messages you get to reveal the appropriate package you need to install.

### When running these steps manually and running `make` for binutils I get an error _GCC_NO_EXECUTABLES_
The path to the compiler specified as `--host` to `configure` cannot be found on your `PATH`. Update your `.bashrc` and login/logout.

### When running these steps manually I get _i686-elf-gcc: command not found_
This is caused by two bugs(?) in the GCC Makefile

1. The file `make` is looking for is called `xgcc`, not `i686-elf-gcc`
2. To create `i686-elf-gcc` you must compile a toolchain for linux first

You can try and hack the GCC makefile to execute `wine ./xgcc.exe` instead, however you'll still run into issues when you try and compile libgcc. If you compile a linux i686-elf toolchain first, all your issues go away. Is this the correct way to do things? Who knows.

### How on earth did you compile libgcc?

One does not simply `make all-target-libgcc` for `host=MinGW32`. The reason for this is that when libgcc is configured, both its target *and* host are set to **i686-elf**. As a result, libgcc's makefile will look for a *host=linux, target=1686-elf* `1686-elf-gcc`, will only find your MinGW32 `i686-elf-gcc.exe` from your previous `make all-gcc` (which it obviously can't execute) and thus will fail.

Attempting to trick the makefile by creating shell scripts on your path named after the missing binaries that internally invoke `wine <mingw32 version>` does not work (you get strange errors on during compilation).

The solution to this therefore is to first compile a linux i686-elf toolchain, followed by the MinGW32 toolchain we're actually interested in. This helps solve other bugs in the compilation process, such as GCC attempting to perform selftests on your MinGW32 cross compiler (which won't work) yet looking for i686-elf-gcc instead (which wouldn't exist).

One would expect libgcc would have host=<the actual host> instead of i686-elf and thus generate a file `libgcc.dll` for mingw32, but from what I've found that doesn't appear to be the case. If you do have issues with GCC not interfacing with libgcc properly, let me know!
