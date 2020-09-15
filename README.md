

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
 
        cov-Z       =>  Show detailed coverage for file Z.



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

## Simplified Makefile

Each project directory you will need a makefile that looks like this:

           
            #
            # The directory where you installed build (see the git clone above)
            PROJECT_ROOT         = $(realpath ../../)

            #
            # The targets you want to build
            # There are three types of target static-lib/shared-lib/application
            # A TARGET may specify more than one thing to build (but only one lib per directory)
            # See features for details.
            TARGET               ?= MyLibName.slib

            include $(CLOUD_ROOT)/build/tools/Makefile


## Features:

### 1: Integration with autotools

Automatically includes $(PROJECT_ROOT)/Makefile.cfg (if it exists)
Thus making it easy to use with Makefile generators like autotools (Autoconf, Automake and Libtool)

### 2: Target Specific Extensions

Target are automatically suffixed to make them unique. Thus all versions can be installed simultaneously.

        03          => C++ 03 release binary
        03D         => C++ 03 debug binary
        11          => C++ 11 release binary
        11D         => C++ 11 debug binary

 (Support for specifically single threaded code is planned with the `S` suffix)

 When specifying libraries to link against:

            LDLIBS      specifies generic system libraries.
            LINK_LIBS   specifies Thor libraries.
                        The makefile will automatically suffix these library names with the correct
                        suffix to match the current build so that they link correctly.

 ### 3: Platform  Specific Extensions

 The library will use the platform specific extension required for shared libraries.


### 4: Neat Easy to read output

When compiling and no error are encountered then only the compiler file-name are printed
-- I hate having all the compiler arguments taking up screen real-estate when not required.
When an error is encountered for command line parameters are displayed.
Also on colour terminals (the output is colour coded to make reading easy)

        Example:    Working:

            $ make
            Building debug
            g++ -c CloudStream.cpp                                               OK
            g++ -c ConfigFileLoader.cpp                                          OK
            g++ -c Logger.cpp                                                    OK
            g++ -shared -o debug/libCloudUtil.so                                 OK
            Done Building debug/libCloudUtil.so

        Example Failure:

            $ make
            Building debug
            g++ -c CloudStream.cpp                                               OK
            g++ -c ConfigFileLoader.cpp                                          ERROR
            g++ -c ConfigFileLoader.cpp -o debug/ConfigFileLoader.o -std=c++0x -Wno-deprecated-declarations -fPIC -Wall -Wextra -Wstrict-aliasing -ansi -pedantic -Werror -Wunreachable-code -Wno-long-long -I/home/Loki/Clean/Cloud/build/include -isystem /home/Loki/Clean/Cloud/build/include3rd -g -std=c++0x
            ========================================
            ConfigFileLoader.cpp: In member function ‘void Moz::Cloud::CloudUtil::ConfigFileLoader::convertCommandLineToJsonMap(const std::vector<std::basic_string<char> >&)’:
            ConfigFileLoader.cpp:175:13: error: expected ‘;’ before ‘}’ token
            make: *** [debug/ConfigFileLoader.o] Error 1

        3:Unit-Test and code coverage
        -----------------------------

        No extra work is required.
        Just create a directory called test (in the same directory as your code) and add unit test files in this directory.
        Currently only google's unit test framework is supported.

## TARGET:

        To build a static-library specify the *.a extension
        To build a shared-library specify the *.slib extension
        To build an application specify the *.app extension.

        Note: For applications the .app is not placed on the final executable.

        For libraries       All *.c *.cpp *.lex *.yacc files are compiled into the libraies.
                            Except any files that have the same name as an application target in the same directory.

        For Applications    If the application is the only target then all files (just like a library are used).
                            If the application is NOT the only target then only the source file with the same name as the application is used.

        FLAGS automatically used:


            CXXSTDVER           03/11   Default     03      Builds C++ 03 version of the executable.
            VERBOSE				Off/On  Default     Off     Dumps extra debug information about the make processes.

            LINK_LIBS                                       Like LDLIBS (bug suffix automatically applied)

        Flags used as normal by Make (Should probably use += with these)
            CPPFLAGS
            CXXFLAGS
            LDFLAGS

            LOADLIBES
            LDLIBS

        Target Specific FLAGS (libs applied only to target)
            UNITTEST_LINK_LIBS
            <TargetName>_LDLIBS
            <TargetName>_LINK_LIBS

    Example:
    ========
        All these features are used in several libraries.
        A publicly available one that I have also built is ThorsSerializer (please check it out for example usages)



