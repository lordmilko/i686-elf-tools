# i686-elf-tools
Cross compiling an i386- or i686-elf Win32 toolchain is an outstandingly complicated and painful process. Both Binutils and GCC fail to properly articulate the extent of software dependencies required to build them, resulting in a litany of spurious and confusing error messages being emitted during compilation. Even once you do have the required software dependencies in place, you will still run into roadblocks due to anomalies in how GCC performs cross compilation.

This repo provides a set of precompiled binaries to those who want to use get what they came for and move on (an i686-elf toolchain that, **unlike others on the internet, includes cc1 and GDB**), as well as a set of instructions for those that would like to build these things themselves. Also featured are a set of instructions for those that wish to install these tools on Mac OS X or Linux.

[Pre-compiled binaries can be found here!](https://github.com/lordmilko/i686-elf-tools/releases)

[Information on using i686-elf-tools in Visual Studio can be found here!](https://github.com/lordmilko/VSKernelDev)

## Win32
### Tutorial

By default, `i686-elf-tools.sh` will download

  * GCC 7.1.0
  * Binutils 2.28
  * GDB 8.0

If you would like to change these versions, specify the `-gv`, `-bv` and `-dv` parameters when invoking the script (for overriding the Binutils, GCC and Debugger versions, respectively). Instead of using MinGW32 or MinGW64, [MXE](http://mxe.cc) is used, providing us with an awesome Win32 toolchain that always produces statically linked binaries that just work (and don't need random MinGW DLLs).

Note: if you already have MXE installed, `i686-elf-tools.sh` won't attempt to make MXE's version of GCC. Please ensure that MXE's gcc has been built (run `make gcc` in your MXE install directory), else you will experience issues during compilation.

### Docker

The following command will compile all Linux/Windows binaries, placing the results under the current user's profile. Substitute `/home/admin` in this command for whatever your home directory is.

```sh
docker run -it -v "/home/admin:/root" --rm lordmilko/i686-elf-tools
```

Any arguments (see below) specified after the image name (`lordmilko/i686-elf-tools`) will be passed as arguments to `i686-elf-tools.sh` within the container. In the above example, build results will be stored in `/home/admin/build-i686-elf`.

Note that absolute paths must be used when when specifying Docker volumes, as such specifying `~` for the local user's home directory will not work.
To avoid making a mess on your system, the container will automatically self delete itself after it has run (`--rm`) leaving only the build results in your home directory.

```sh
# Compile GCC 9.2.0, Binutils 2.34 and GDB 9.1
docker run -it -v "/home/admin:/root" --rm lordmilko/i686-elf-tools -gv 9.2.0 -bv 2.34 -dv 9.1
```

### Native

1. Install a Debian based operating system, ideally 32-bit (i386). This procedure has successfully been performed on Debian 9.5 i386 and Ubuntu 18.04 64-bit (amd64). If you wish to compile a x86_64-elf toolchain (via `-64`), you should probably use a 64-bit operating system.

2. Remove the CD-ROM source from `/etc/apt/sources.list` (if applicable)

3. If you are running Ubuntu, you may need to modify `/etc/apt/sources.list` to include `universe` and `multiverse` in addition to `main`. If you simply do the default Ubuntu install, these appear to be included by default.

   ```diff
   -deb http://archive.ubuntu.com/ubuntu bionic main
   +deb http://archive.ubuntu.com/ubuntu bionic main universe multiverse
   deb http://archive.ubuntu.com/ubuntu bionic-security main
   deb http://archive.ubuntu.com/ubuntu bionic-updates main
   ```

4. Run the following commands. `sudo -s` is optional, however if you are not running as root you will get repeated password request prompts during the course of the execution.

    ```sh
    sudo -s
    wget https://raw.githubusercontent.com/lordmilko/i686-elf-tools/master/i686-elf-tools.sh
    chmod +x ./i686-elf-tools.sh
    ./i686-elf-tools.sh
    ```
    
    A full run (including installing prerequisites and configuring MXE) takes approximately 1.5-2 hours on a 4xCPU virtual machine.

5. When the script completes you will have two zip files containing your i686-elf toolchain

    * `~/build-i686-elf/i686-elf-tools-windows.zip`
    * `~/build-i686-elf/i686-elf-tools-linux.zip`

If you experience any issues, you can specify one or more command line arguments to only perform certain parts of the script. The following arguments are supported

* `binutils`
* `gcc`
* `gdb`
* `zip` - zip it all up!
* `linux` - compile the linux toolchain only
* `win` - compile the windows toolchain only
* `env` - only install the prerequisite packages + MXE
* `-gv`/`--gcc-version` - specify the GCC version to build
* `-bv`/`--binutils-version` - specify the Binutils version to build
* `-dv`/`--gdb-version` - specify the GDB version to build
* `-64` - compile for x86_64-elf instead of i686-elf
* `-parallel` - build `make` recipes in [parallel](https://www.gnu.org/software/make/manual/html_node/Parallel.html) (`-j4`). To modify the number of jobs executed in parallel, modify `i686-elf-tools.sh`

```sh
# Compile binutils and gcc only
./i686-elf-tools.sh binutils gcc
```

The `win` argument should only be used if the Linux toolchain has already been compiled and you're experiencing issues with the Win32 part.

Logs are stored for each stage of the process under *~/build-i686-elf/build-**xyz**/**xyz**_**stage**.log*

e.g. **~/build-i686-elf/build-gcc-7.1.0/gcc_make.log**

If you attempt to run `make` and `configure` commands manually that depend on components of the linux i686-elf toolchain, ensure `~/build-i686-elf/linux/output/bin` is on your path, else you may get errors about binaries being missing.

By default, i686-elf-tools will build `make` recipes in parallel. If any arguments are specified to `i686-elf-tools.sh` however, parallel compilation must be opted into by explicitly specifying `-parallel`.

## Mac OS X

Installing an i386-elf toolchain on Mac OS X is - theoretically - outstandingly simple process. Note that the following relies on a third party script and is not supported by me. It may be possible to run *i686-elf-tools.sh* on Mac OS X with a bit of tweaking (like not using `apt-get` to install packages) however this is not supported.

1. Install [Brew](http://brew.sh/)
2. Download the [i386-elf recipes](https://github.com/altkatz/homebrew-gcc_cross_compilers)
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
I originally tried to use CentOS 7 64-bit, however along the way I encountered various issues potentially attributable to bitness, resulting in my switching to a 32-bit OS to simplify troubleshooting. CentOS 7 32-bit _cannot_ be used, as all the packages required by MXE are not available on yum.

If you are determined not to use Debian (or another Debian derivitive), please see the [prerequisites for MXE](http://mxe.cc/#requirements). Note: you may need additional packages to these to successfully compile gcc, e.g. _texinfo_, _readline-devel_, etc. Google any error messages you get to reveal the appropriate package you need to install.

### When running these steps manually and running `make` for binutils I get an error _GCC_NO_EXECUTABLES_
The path to the compiler specified as `--host` to `configure` cannot be found on your `PATH`. (i.e. if you're compiling for Windows, check that `/opt/mxe/usr/bin` is present). Update your `.bashrc` and login/logout.

### When running these steps manually I get _i686-elf-gcc: command not found_
This is caused by two bugs(?) in the GCC Makefile

1. The file `make` is looking for is called `xgcc`, not `i686-elf-gcc`
2. To create `i686-elf-gcc` you must compile a toolchain for linux first

You can try and hack the GCC makefile to execute `wine ./xgcc.exe` instead, however you'll still run into issues when you try and compile libgcc. If you compile a linux i686-elf toolchain first, all your issues go away. Is this the correct way to do things? Who knows.

### How do I compile x86_64 myself?

See the [OSDev Wiki](https://wiki.osdev.org/Libgcc_without_red_zone). Note that when compiling for Windows however, `make install-target-libgcc` does not appear to copy the no-red-zone libgcc version to the output directory. To get around this, simply `cd` into `x86_64-elf/no-red-zone/libgcc` in your output directory and run `make install` yourself.

### How on earth did you compile libgcc?

One does not simply `make all-target-libgcc` for `host=MinGW32`. The reason for this is that when libgcc is configured, both its target *and* host are set to **i686-elf**. As a result, libgcc's makefile will look for a *host=linux, target=1686-elf* `i686-elf-gcc`, will only find your MinGW32 `i686-elf-gcc.exe` from your previous `make all-gcc` (which it obviously can't execute) and thus will fail.

Attempting to trick the makefile by creating shell scripts on your path named after the missing binaries that internally invoke `wine <mingw32 version>` does not work (you get strange errors on during compilation).

The solution to this therefore is to first compile a linux i686-elf toolchain, followed by the MinGW32 toolchain we're actually interested in. This helps solve other bugs in the compilation process, such as GCC attempting to perform selftests on your MinGW32 cross compiler (which won't work) yet looking for i686-elf-gcc instead (which wouldn't exist).

One would expect libgcc would have host=&lt;the actual host&gt; instead of i686-elf and thus generate a file `libgcc.dll` for mingw32, but from what I've found that doesn't appear to be the case. If you do have issues with GCC not interfacing with libgcc properly, let me know!
