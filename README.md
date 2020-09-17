

# Generic build files.

These build files allow the following easy targets:

### Main Targets:

        The default action is "build"

        build       =>  Run Test:           See target test
                        Build Debug         See target debug
                        Build Release       See target release
                        Install locally     (installs into $(THORSANVIL_ROOT)/build/include and $(THORSANVIL_ROOT)/build/lib)
                                            THORSANVIL_ROOT should be the root of your project.

        install     =>  Run Test
                        Build Debug
                        Build Release
                        Install globally    This usually means /usr/local/include
                                            But the included "configure" tools can allow you to customize this.


        Conversely there reverse of the main commands are:
        verclean    =>  Runs clean them removes all locally installed objects.
        uninstall   =>  Runs clean them removes all globally installed objects.

### Development Targets:

        clean       =>  Removes all objects / reports / coverage information.

        debug       =>  Compiles a version with the debug flags set and all symbols still included.
                        Any libraries build will have the suffix "D" to distinguish them from release libraries.
        release     =>  Compiles a version with the release flags set and all symbols will be stripped.

        test        =>  Build and run Unit Test:        See: testonly
                        Run Code Coverage Tools:        See: covonly
                        Run Static Analysis Tools:      See: veraonly

        testonly    =>  Build the code with flags to generate coverage metrics.
                        If the test directory exists byuild all the unit tests.
                        Create an executable to run the unit tests.
                        Run the unit tests: Showing passing and failing tests.
                        -----
                        If there are not changes since last build
                        Simply show the results from the last run of the unit tests.

        covonly     =>  Requires that unit tests have run.
                        Calculate the code coverage of all *.cpp *.tpp *.h files
                        Display the code coverage for each file and the whole directory.
                        Fails if the directory code coverage is below CODE_COVERAGE (default 80)

        vera        =>  Runs static analysis on the source files *.cpp *.tpp *.h
                        Make sure they conform to the vera rules: see $(THORSANVIL_ROOT)/buid/vera/rules

        test-X.Y    =>  Make sure the unit test executable is upto date.
                        Run only test X.Y
 
        coverage-Z  =>  Make sure the test exectuable is upto-date
                        If it is rebuily then re-run the test.
                        Show detailed coverage for file Z.



## Tools You will need

    brew install autoconf
    brew install automake
    brew install libtool
    brew install cmake
    brew install boost
    brew install boost-python

    # Need to convert the versioned boost libraries to 
    # nonversioned. This creates the appropriate symbolic links
    cd /usr/local/lib
    for src in `ls libboost_python*`; do
        dst=${src//[[:digit:]]/}
        ln -s ${src} ${dst}
    done

## SetUp

        mkdir MyProj
        cd MyProj
        git init
        wget https://raw.githubusercontent.com/Loki-Astari/ThorMaker/master/autotools/Notes
        ./Notes MyProj
        git commit -a -m "First Commit"

## HowToUse

#### Notes:

The Makefiles documented in this section load the master makefile from: `$(THORSANVIL_ROOT)/build/tools/<Makefile>`. This implies that the `build` directory is this `ThorMaker` project. If you look at the scrip `Notes` from the "SetUp" section you will see that it adds this (ThorMaker) project as a submdule of the current project in the build directory:

    git submodule add https://github.com/Loki-Astari/ThorMaker.git .build
    ln -s .build build

----

There are two types of Makefile:

* A makefile for simply building all sub directories.
* A makefile for building a project

### SubDirectory Makefile

This makefile contains three lines:

    THORSANVIL_ROOT             = $(realpath ../)

    TARGET                      = ThorsIOUtil ThorsCrypto ThorsSocket ThorsDB ThorsDBCommon MySQL Postgres Mongo ThorsDBBuild ThorsDBBuildTest

    include $(THORSANVIL_ROOT)/build/tools/Project.Makefile


What each line means:

The `THORSANVIL_ROOT` is a variable used within the makefiles and points to the directory that contains the "build" directory. This directory contains all the build tools you need and any intermediate objects will be built into the "$(THORSANVIL_ROOT)/build" direcotory.

The `TARGET` is a list of sub directories. It will execute the `Makefile` in each of these subdirectories.

The `include` line simply includes a generic Makefile that will expand the `TARGET` variable and provides all the target information.

### Project Makefile

The standard Makefile contains only three lines.

    THORSANVIL_ROOT				?= $(realpath ../../)

    TARGET						= Apolication.app

    include $(THORSANVIL_ROOT)/build/tools/Makefile

You will notice the difference in two lines. The Target is the name of what you want to build and the include line contains the name of the master makefile (rather than the simpler one to handle sub directories only).

The above Makefile is for building an application but you can build application / library / header only libraries using this makefile.  
Lots of details can be found at the top of the `build/tools/Makefile` about how it works. If I implement something then can't remember how it works next time around I add notes at the top of this file to remind myself. This page will be periodically updated with details about the commands as they become well used. But I try not to break backward compatibility when I make changes.

#### Building an Application

    TARGET  = Executable.app

This will build the application "Executable" (for release) and "ExecutableD" (for debug).  
This will be built into the directory `$(THORSANVIL_ROOT)/build/bin` for "build" target.  
This will be built into the directory `/usr/local/bin` for "install" target.  

The file `Executable.cpp` is assumed to have the `main()` function and will not be build into the test executable.
All `*.cpp` fill will be used to build the application.

If there is a test directory all `*.cpp` files (except `Executable.cpp`) will be built into the test executable and all the unit tests will be run against this executable that does code coverage on these source files.

#### Building a Header Only Library

    TARGET = LibraryAlpha.head

This will be create the directory `$(THORSANVIL_ROOT)/build/include/LibraryAlpha` and copy all `*.h` files into it for "build" target.  
This will be create the directory `/usr/local/include/LibraryAlpha` and copy all `*.h` files into it for "install" target.  

If there is a test directory this will be used to build the test executable and all the unit tests will be run against this executable that does code coverage on these source files.

#### Building a Library

There are two types of library (static and dynamic). Conversely there are two suffix you can use to specify the type of library you want to build `*.a` static or `*.slib` for dynamic. If you don't want to be specific use the `*.lib` suffix. By default this will create a shared library but can be configured by the `configure.ac` file to be static/dynamic or both. So usually you want to use the `*.lib` suffix and allow the person building your library to make a specific choice.

Note: Building a shared library will result in the library suffix being selected based on platform. (So Mac=>dylib, Linux=>so, etc)

    TARGET  = MyCrypto.lib

The will build the library "libMyCrypto17.dylib" (for relase) and "lib/MyCrypto17D.dylib" (for debug).
Notice that we add `17` to the name of the library in case you build multiple versions with difference versions of the standard. I wanted to be able to make sure I did not link versions built against difference version of the library. The version of the library that is used is specified in the `configure.ac` file.

For the "build" target this will:
    * install the library into the directory `$(THORSANVIL_ROOT)/build/lib`
    * create the directory `$(THORSANVIL_ROOT)/build/include/MyCrypto` and copy all `*.h` files into it for "build" target.  
For the "install" target this will:
    * install the library into the directory `/usr/local/lib`
    * create the directory `/usr/local/include/MyCrypto` and copy all `*.h` files into it for "build" target.  

If there is a test directory all `*.cpp` files will be built into the test executable and all the unit tests will be run against this executable that does code coverage on these source files.

### Other Options

You can use any standard flags that are used by MAKE.
eg.

    CXXFLAGS        += <Any Flags You Want to Add>
    LDLIBS          += Add any libraries you want to link with.


Normally you want to use the `+=` to add extra flags and not override anything on the command line.   
The master build file also sets a lot of extra flags they consider essential. `-Wall -Wextra` etc. For debug/release build it will add `-g` or `-O3` respectively etc.

Some custom options are:

    COVERAGE_REQUIRED   = By default a code coverage of 80% is required to build/install to complete.
                          You can override this default by adding this to the Makefile.
    FILE_WARNING_FLAGS  = Special as it is added after all other flags.
    CXXSTDVER           = 03/11/14/17/20 // One of those    overides the default set in `configure.ac`
    LINK_LIBS           += Special version of LDLIBS.
                           This is for linking against libraries built with `ThorMaker`.
                           It will correctly add the appropriate suffix to the library name (eg. 17D for version 17 Debug libraries).

### Specific Target

If you want to add flags to specific files you can use the following form:

    %/File.o:       CXXFLAGS += -Wno-depricated-warnings

For the file "File.cpp" we all add extra flags when building it into "File.o". You can be more specific and do this only for debug or release like this:

    debug/File.o:   CXXFLAGS += -gExtra
    release/File.o: CXXFLAGS += -OMyFlag

### Unit Test Options

    UNITTEST_CXXFLAGS               += -Wno-special
    UNITTEST_LDLIBS                 += -lsync
    UNITTEST_LINK_LIBS              += ThorsDB
    UNITTEST_FILE_WARNING_FLAGS     += -Wno-problems








    



