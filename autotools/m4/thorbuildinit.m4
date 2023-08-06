###################################################################################################

#
# Set the Version of C++ you want to use.
#   Check a set of compieler flags that are not consistent across platforms.
#       All Flags are put in Makefile.config.in automatically.
#       All Flags are used by the build/tools/Makefile
#
#
#       AX_THOR_FUNC_LANG_FLAG
#
# Standard include to get all basic functionality for the build tools.
#
#   AX_THOR_FUNC_INIT_BUILD
#       Calls a st of AX_THOR_FUNC_BUILD_* functions. (see below)
#
#
# Checking Libraries:
#   These functions allow user to specify a location where the libraries could be installed.
#   This information is passed down to any third party configuration libraries.
#   They will also define two variables that should be added to the Makefile.config.in
#           <name>_ROOT_LIB         eg sdl_ROOT_LIB
#           <name>_ROOT_DIR         eg sdl_ROOT_DIR
#       For the XXXConfigure.h file it will also define.
#           HAVE_<name>
#   They can then be used in you Makefile setup flags:
#
#           LDLIBS      += $(sdl_ROOT_LIB)
#           LDFLAGS     += $(if $(sdl_ROOT_DIR), -L$(sdl_ROOT_DIR)/lib,)
#           CXXFLAGS    += $(if $(sdl_ROOT_DIR), -I$(sdl_ROOT_DIR)/include)
#
#
#   Features:
#       AX_THOR_FEATURE_HEADER_ONLY_VARIANT
#
#   Checks Provided:
#       AX_THOR_CHECK_USE_SDL
#       AX_THOR_CHECK_USE_CRYPTO
#       AX_THOR_CHECK_USE_THORS_DB
#       AX_THOR_CHECK_USE_THORS_SERIALIZE
#       AX_THOR_CHECK_USE_THORS_SERIALIZE_HEADER_ONLY
#       AX_THOR_CHECK_USE_MAGIC_ENUM
#       AX_THOR_CHECK_USE_EVENT
#       AX_THOR_CHECK_USE_BOOST
#       AX_THOR_CHECK_USE_YAML
#       AX_THOR_CHECK_USE_SNAPPY
#       AX_THOR_CHECK_USE_SMARTY
#       AX_THOR_CHECK_USE_STATIC_LOAD
#
#   Disable some functionality as it is only used in tests
#       AX_THOR_DISABLE_TEST_REQUIREING_LOCK_FILES
#       AX_THOR_DISABLE_TEST_REQUIREING_POSTGRES_AUTHENTICATION
#       AX_THOR_DISABLE_TEST_REQUIREING_MONGO_QUERY
#
#       == Old Need to verify usability
#       AX_THOR_CHECK_DISABLE_TIMEGM
#       AX_THOR_CHECK_DISABLE_MODTEST
#
# Check if specific applications are available
#       AX_THOR_CHECK_APP_LEX
#
# Specific Functionality Tests:
#       AX_THOR_FUNC_TEST_BOOST_COROUTINE_VERSION
#       AX_THOR_FUNC_TEST_COMP
#       AX_THOR_FUNC_TEST_BINARY
#
# Check if the DB is up and running and we can accesses it:
#       AX_THOR_SERVICE_AVAILABLE_MYSQL
#       AX_THOR_SERVICE_AVAILABLE_POSTGRES
#       AX_THOR_SERVICE_AVAILABLE_MONGO
#       AX_THOR_CHECK_SMARTY_AVAILABLE


###################################################################################################
###################################################################################################
###################################################################################################

AC_DEFUN([AX_THOR_FUNC_LANG_FLAG],
[
    AX_THOR_FUNC_LANG_CHECK_FLAGS()

    AC_ARG_WITH(
        [standard-version],
        AS_HELP_STRING([--with-standard-version=<version>], [Use the specified version <version> of the C++ standard. Default 17])
    )

    askedLangFeature=17
    AS_IF(
        [test "x${with_standard_version}" != "x"],
        [
            askedLangFeature=${with_standard_version}
            subconfigure="${subconfigure} --with-standard-version=${with_standard_version}"
        ]
    )

    minLangFeature=3
    AS_IF([test $minLangFeature -gt $askedLangFeature], AC_MSG_ERROR([Invalid Language requested: ${askedLangFeature}. Minimum: ${minLangFeature}]))

    CXXMaxLanguage=03
    CXXExpLanguage=03
    AX_CHECK_COMPILE_FLAG([-std=c++11], [AC_SUBST([CXXMaxLanguage],11) AC_SUBST([StdFlag11],[-std=c++11])])
    AX_CHECK_COMPILE_FLAG([-std=c++14], [AC_SUBST([CXXMaxLanguage],14) AC_SUBST([StdFlag14],[-std=c++14])])
    AX_CHECK_COMPILE_FLAG([-std=c++17], [AC_SUBST([CXXMaxLanguage],17) AC_SUBST([StdFlag17],[-std=c++17])])
    AX_CHECK_COMPILE_FLAG([-std=c++20], [AC_SUBST([CXXMaxLanguage],20) AC_SUBST([StdFlag20],[-std=c++20])])
    AX_CHECK_COMPILE_FLAG([-std=c++23], [AC_SUBST([CXXMaxLanguage],23) AC_SUBST([StdFlag23],[-std=c++23])])
    AX_CHECK_COMPILE_FLAG([-std=c++1x], [AC_SUBST([CXXExpLanguage],11) AC_SUBST([ExpFlag11],[-std=c++1x])])
    AX_CHECK_COMPILE_FLAG([-std=c++1y], [AC_SUBST([CXXExpLanguage],14) AC_SUBST([ExpFlag14],[-std=c++1y])])
    AX_CHECK_COMPILE_FLAG([-std=c++1z], [AC_SUBST([CXXExpLanguage],17) AC_SUBST([ExpFlag17],[-std=c++1z])])
    AX_CHECK_COMPILE_FLAG([-std=c++2a], [AC_SUBST([CXXExpLanguage],20) AC_SUBST([ExpFlag20],[-std=c++2a])])
    AX_CHECK_COMPILE_FLAG([-std=c++2b], [AC_SUBST([CXXExpLanguage],23) AC_SUBST([ExpFlag23],[-std=c++2b])])

    AS_IF(
        [test $askedLangFeature -le $CXXMaxLanguage],
        [
            AC_SUBST([CXXSTDVER], [$askedLangFeature])
            AC_SUBST([CXX_STD_FLAG], [$(eval echo "\${StdFlag${CXXSTDVER}}")])
        ],
        [
            AS_IF(
                [test $askedLangFeature -le $CXXExpLanguage],
                [
                    AC_SUBST([CXXSTDVER], [$askedLangFeature])
                    AC_SUBST([CXX_STD_FLAG], [$(eval echo "\${ExpFlag${CXXSTDVER}}")])
                ],
                [
                    AC_MSG_ERROR([

Error: Need C++${askedLangFeature} but the compiler only supports ${CXXMaxLanguage} (Experimental ${CXXExpLanguage})

                        ]
                    )
                ]
            )
        ]
    )
])

AC_DEFUN([AX_THOR_FUNC_LANG_CHECK_FLAGS],
[
    AX_CHECK_COMPILE_FLAG(
        [-Wno-unused-private-field],
        [AC_SUBST([NO_UNUSED_PRIVATE_FIELD_TEST], [-Wno-unused-private-field])]
        [],
        [-Werror]
    )
    AX_CHECK_COMPILE_FLAG(
        [-Wno-deprecated-register],
        [AC_SUBST([NO_DEPRECATED_REGISTER_TEST], [-Wno-deprecated-register])]
        [],
        [-Werror]
    )
    AX_CHECK_COMPILE_FLAG(
        [-Winconsistent-missing-override],
        [AC_SUBST([INCONSISTENT_MISSING_OVERRIDE], [-Winconsistent-missing-override])]
        [],
        [-Werror]
    )
    AX_CHECK_COMPILE_FLAG(
        [-Wdelete-non-abstract-non-virtual-dtor],
        [AC_SUBST([DELETE_NON_ABSTRACT_NON_VIRTUAL_DTOR], [-Wdelete-non-abstract-non-virtual-dtor])]
        [],
        [-Werror]
    )
    AX_CHECK_COMPILE_FLAG(
        [-Wdelete-non-virtual-dtor],
        [AC_SUBST([DELETE_NON_VIRTUAL_DTOR], [-Wdelete-non-virtual-dtor])]
        [],
        [-Werror]
    )
    AX_CHECK_COMPILE_FLAG(
        [-Wno-literal-suffix],
        [AC_SUBST([LITERAL_WARNING_SUFFIX], [-Wno-literal-suffix])],
        [],
        [-Werror]
    )
    AX_CHECK_COMPILE_FLAG(
        [-Wno-literal-range],
        [AC_SUBST([LITERAL_WARNING_RANGE], [-Wno-literal-range])],
        [],
        [-Werror]
    )
])

###################################################################################################

AC_DEFUN([AX_THOR_BUILDING],
[
    export BUILDING_$1=1
])

AC_DEFUN([AX_THOR_FUNC_TERM_BUILD],
[
    AX_THOR_FUNC_BUILD_FIX_GIT_SYMLINKS_WINDOWS
    AX_THOR_FUNC_BUILD_THIRD_PARTY_LIBS

    #
    # Add your defintions in here.
    # Note there are some predefined macros in build/autotools/m4/



    # Build all the Makefiles and configuration files.
    # Used by ThorMaker
    # Note: you can push the config file to sub directories in the AC_CONFIG_HEADERS macro (see example)
    # Note: Local Make variables should be placed in Makefile.config.in
    AM_INIT_AUTOMAKE([foreign])
    AH_TOP([

#ifndef  THORS_$1_CONFIG_H
#define  THORS_$1_CONFIG_H

    ])
    AH_BOTTOM([

#endif

    ])

    AC_CONFIG_HEADERS([config.h $2])
    AC_CONFIG_FILES([Makefile.extra Makefile.config:build/autotools/build/Makefile.config.in:Makefile.config.in])
])

AC_DEFUN([AX_THOR_FUNC_INIT_BUILD],
[
    AX_THOR_BUILDING($1)
    AC_LANG(C++)

    AX_THOR_FUNC_BUILD_LOCAL_DIR

    AX_THOR_CHECK_APP_COV

    subconfigure=""
    AX_THOR_FUNC_BUILD_VERA_INIT
    AX_THOR_FUNC_BUILD_LIB_SELECT
    AX_THOR_FUNC_BUILD_COLOUR_MODE
    AX_THOR_FUNC_BUILD_GIT_SUBMODULE_RETRIEVE

    AC_CONFIG_SRCDIR([$2])

    AX_THOR_FUNC_LANG_FLAG

    AX_THOR_FUNC_BUILD_SETUP_BUILDTOOLS
])

AC_DEFUN([AX_THOR_FUNC_BUILD_LOCAL_DIR],
[
    DefaultLinkDir="/usr/local"
    host=$(uname -p)
    AS_IF(
        [test "${host}" == "arm" ],
        [
            DefaultLinkDir="/opt/homebrew"
            AS_IF([test "${prefix}" == "NONE"], [prefix=${DefaultLinkDir}])
            AC_SUBST([DefaultLinkDir], [${DefaultLinkDir}])
        ]
    )
])

AC_DEFUN([AX_THOR_FUNC_BUILD_SETUP_BUILDTOOLS],
[
    AC_CHECK_PROGS([UNZIP], [bzip2], [:])
    if test "$UNZIP" = :; then
        AC_MSG_ERROR([
            The build tools needs bzip2. Please install it.
            We use it to unzip google packages for building tests.
        ])
    fi
    pushd build/third
    ./setup "${CXX}  ${CXX_STD_FLAG}" || AC_MSG_ERROR([Failed to set up the test utilities])
    popd
])

AC_DEFUN([AX_THOR_FUNC_BUILD_VERA_INIT],
[
    AC_ARG_ENABLE(
        [vera],
        AS_HELP_STRING([--disable-vera], [Disable vera. Disable Static analysis of source.])
    )

    VERATOOL="";
    AS_IF(
        [test "x$enable_vera" == "xno"],
        [
            VERATOOL='off';
            subconfigure="${subconfigure} --disable-vera";
        ],
        [
            AC_CHECK_PROGS([TestVera], [vera++], [:])
            AS_IF(
                [test "$TestVera" == ":"],
                [
                    AC_MSG_ERROR([

By default the build tools use vera++ for static analysis of C++ code to ensure the project
maintains a consistent style when people add pull requests. The configuration tests have
detected that "vera++" (the static analysis tool) is not currently installed.

The easy way to install vera++ is using brew:

    > brew install vera++

                    ])
                ],
                []
            )
            VERATOOL='vera++';
        ]
    )
    AC_SUBST([VERATOOL], [${VERATOOL}])
])

AC_DEFUN([AX_THOR_FUNC_BUILD_LIB_SELECT],
[
    THOR_TARGETLIBS=""
    AS_IF(
        [test "x$enable_shared" == "xyes"],
        [THOR_TARGETLIBS+=" slib"]
    )
    AS_IF(
        [test "x$enable_static" == "xyes"],
        [THOR_TARGETLIBS+=" a"]
    )
    AS_IF(
        [test "x$THOR_TARGETLIBS" == "x"],
        [THOR_TARGETLIBS="slib"]
    )

    AC_SUBST([THOR_TARGETLIBS],[${THOR_TARGETLIBS}])
])

AC_DEFUN([AX_THOR_FUNC_BUILD_COLOUR_MODE],
[
    COLOUR_STATE="ON"
    DARK_MODE=""
    AC_ARG_ENABLE(
        [colour],
        AS_HELP_STRING([--disable-colour], [Turns off text colouring in the makefile output])
    )
    AC_ARG_ENABLE(
        [dark-mode],
        AS_HELP_STRING([--enable-dark-mode], [If your background is black some text that was grey is turned yellow])
    )
    AS_IF(
        [test "x$enable_colour" == "xno"],
        [
            COLOUR_STATE="OFF"
            subconfigure="${subconfigure} --disable-colour"
        ]
    )
    AS_IF(
        [test "x$enable_dark-mode" != "xyes"],
        [
            DARK_MODE="ON"
            subconfigure="${subconfigure} --enable-dark-mode"
        ]
    )
    AC_SUBST([COLOUR_STATE], [${COLOUR_STATE}])
    AC_SUBST([DARK_MODE], [${DARK_MODE}])
])

AC_DEFUN([AX_THOR_FUNC_BUILD_GIT_SUBMODULE_RETRIEVE],
[
    if git submodule status | grep --quiet '^-'; then
        git submodule update --init --recursive
    fi
])

AC_DEFUN([AX_THOR_FUNC_BUILD_THIRD_PARTY_LIBS],
[
    export cwd=$(pwd)

    pushd third
    if [[ $? == 0 ]]; then
        for third in $(ls); do
            echo
            echo
            echo "Building Third Party: ${third}"
            pushd ${third}
            if [[ -e ./configure ]]; then
                echo "${third}:  ./configure ${subconfigure} --prefix=${prefix} "
                ./configure ${subconfigure} --prefix=${prefix}
                if [[ $? != 0 ]]; then
                    echo "Failed to configure: ${third}"
                    exit 1
                fi
            fi
            echo "Complete: ${third}"
            echo "================ DONE ================="
            echo
            popd
            AX_THOR_BUILDING(${third})
        done
        popd
    fi
])

AC_DEFUN([AX_THOR_FUNC_BUILD_FIX_GIT_SYMLINKS_WINDOWS],
[
    sedStrip='s/-.*//'
    UNAME=`uname -s | sed "${sedStrip}"`
    echo "Checking Windows Symbolic Links: ${UNAME}"
    AS_IF([test "x${UNAME}" = "xMSYS_NT" || test "x${UNAME}" = "xMINGW64_NT" ],
    [
        AS_IF(
            [test ! -e .windows.fix],
            [
                echo "    Fixing"
                git config --local core.symlinks true
                find src/ -type f | xargs -I^ git restore --source=HEAD ^
                echo "    Fixing DONE"
                touch .windows.fix
            ]
        )
    ],[
        echo "    Not Windows"
    ])
])

###################################################################################################
###################################################################################################
###################################################################################################


AC_DEFUN([AX_THOR_CHECK_USE_TEMPLATE_HEADER_TEST],
[
    dnl 1: =>  configure command line argument:  --with-$1-root=
    dnl 2: =>  underscore version of $1 to be used in variables
    dnl 3: =>  Name of package. We will define HAVE_$3 if it exists for Makefiles
    dnl 4: =>  Header file we should check for.
    dnl 5: =>  Is this flag optional
    dnl 6: =>  Error Msg

    AC_ARG_WITH(
        [$1-root],
        AS_HELP_STRING([--with-$1-root=<location>], [Directory of $3 include folder: the folder that has the include file])
    )

    INCLUDE_DIR="-I${with_$2_root}"
    AS_IF(
        [test "x${with_$2_root}" == "x"],
        [INCLUDE_DIR="-I${DefaultLinkDir}/include"]
    )

    ORIG_CXXFLAGS="${CXXFLAGS}"
    CXXFLAGS="${CXXFLAGS} ${CXX_STD_FLAG} ${INCLUDE_DIR}"

    AC_CHECK_HEADER(
        [$4],
        [
            AS_IF(
                [test "x${with_$2_root}" != "x"],
                [
                    AC_DEFINE([HAVE_$3], 1, [We have found $3 package])
                    $2_defined=1
                    AC_SUBST([$3_ROOT_DIR], [${with_$2_root}])
                    subconfigure="${subconfigure} --with-$1-root=${with_$2_root}"
                ]
            )
        ],
        [
            AS_IF(
                [test "$5" == "1"],
                [AC_MSG_ERROR([$6])]
            )
        ]
    )

    CXXFLAGS="${ORIG_CXXFLAGS}"
])

AC_DEFUN([AX_THOR_CHECK_TEMPLATE_LIBRARY_TEST_FOUND],
[
    AS_IF(
        [test "x${with_$2_root}" != "x"],
        [
            AC_DEFINE([HAVE_$7], 1, [We have found package $3])
            AC_SUBST([$8_ROOT_DIR], [${with_$2_root}])
            subconfigure="${subconfigure} --with-$1-root=${with_$2_root}"
        ]
    )
    echo "Setting: $8_ROOT_LIB TO $6"
    AC_SUBST([$8_ROOT_LIB], ["$6"])
])

AC_DEFUN([AX_THOR_CHECK_TEMPLATE_LIBRARY_TEST],
[
    dnl 1: =>  configure command line argument:  --with-$1-root=
    dnl 2: =>  underscore version of $1 to be used in variables
    dnl 3: =>  Human Readable Name. Used in strings to describe package.
    dnl 4: =>  Library we are checking for existance
    dnl 5: =>  Symbol we are checking for in library
    dnl 6: =>  The library (or list of libraries we will link against)
    dnl         Note (not the lib or -l or extension).
    dnl         eg. Fro Crypto:  "crypto ssl"  => will link against -lcrypto -lssl
    dnl 7: =>  HAVE_$7 macro defined for source.
    dnl 8: =>  Make Macro: $8_ROOT_DIR and $8_ROOT_LIB
    dnl         Should be the same as one of the values in $6
    dnl 9:     Name of standard checkout directory (Used for Thor Tools)
    dnl 10: => Extra Error Message.
    dnl
    dnl Note:
    dnl           eg:
    dnl               crypto_ROOT_DIR=/opt/homebrew/Cellar/@3/v1.1/
    dnl               crypto_ROOT_LIB="crypto ssl"
    AC_ARG_WITH(
        [$1-root],
        AS_HELP_STRING([--with-$1-root=<location>], [Define the root directory of package $3])
    )

    LIBRARY_DIR="-L ${with_$2_root}/lib"
    AS_IF(
        [test "x${with_$2_root}" == "x"],
        [LIBRARY_DIR="-L ${DefaultLinkDir}/lib"]
    )

    AS_IF(
        [test "x${$2_header_only_defined}" == "x"],
        [
            ORIG_LDFLAGS="${LDFLAGS}"
            LDFLAGS="$LDFLAGS ${LIBRARY_DIR}"

            echo "Building: $9"
            echo "Mark:     $BUILDING_$9"
            echo "Checking"
            AS_IF(
                [test "x$BUILDING_$9" == "x1" ],
                [
                    AX_THOR_CHECK_TEMPLATE_LIBRARY_TEST_FOUND([$1], [$2], [$3], [$4], [$5], [$6], [$7], [$8], [$9], [$10])
                ],
                [
                    AC_CHECK_LIB(
                        [$4],
                        [$5],
                        [
                            AX_THOR_CHECK_TEMPLATE_LIBRARY_TEST_FOUND([$1], [$2], [$3], [$4], [$5], [$6], [$7], [$8], [$9], [$10])
                        ],
                        [
                            echo "FAIL: Using: >${with_$2_root}<"
                            AC_MSG_ERROR([$10])
                            echo "FAIL DONE"
                        ]
                    )
                ]
            )
            echo "Checking DONE"

            LDFLAGS="${ORIG_LDFLAGS}"
        ]
    )
])
###################################################################################################


AC_DEFUN([AX_THOR_FEATURE_HEADER_ONLY_VARIANT],
[
    AC_DEFINE([$1_HEADER_ONLY], [0], [Enable to use header only libraries])
    AC_DEFINE([$1_HEADER_ONLY_INCLUDE], [], [For header only convert to inline])
])



###################################################################################################



AC_DEFUN([AX_THOR_CHECK_USE_SDL],
[
    AX_THOR_CHECK_USE_SDL_MAIN
    AX_THOR_CHECK_USE_SDL_TTF
    AX_THOR_CHECK_USE_SDL_Image
])


AC_DEFUN([AX_THOR_CHECK_USE_SDL_MAIN],
[
    SDL_VERSION=2.0.0
    AM_PATH_SDL($SDL_VERSION, :, AC_MSG_ERROR([
*** SDL version $SDL_VERSION not found!

Error: Count not find libSDL2

You can solve this in installing SDL2

        On the mac use:
            > brew install sdl2

    ]))
])

AC_DEFUN([AX_THOR_CHECK_USE_SDL_TTF],
[
    ORIG_LDFLAGS="${LDFLAGS}"
    LDFLAGS="${LDFLAGS} ${SDL_LIBS}"

    AC_CHECK_LIB(
        [SDL2_ttf],
        [TTF_Init],
        :,
        [AC_MSG_ERROR([

Error: Could not find libSDL2_ttf

You can solve this by installing SDL2_ttf

        On the mac use:
            > brew install sdl2_ttf

        ])]
    )

    LDFLAGS="${ORIG_LDFLAGS}"
    AC_SUBST([SDL_LIBS], ["${SDL_LIBS} -lSDL2_ttf"])
])

AC_DEFUN([AX_THOR_CHECK_USE_SDL_Image],
[
    ORIG_LDFLAGS="${LDFLAGS}"
    LDFLAGS="${LDFLAGS} ${SDL_LIBS}"

    AC_CHECK_LIB(
        [SDL2_image],
        [IMG_Init],
        :,
        [AC_MSG_ERROR([

Error: Could not find libSDL2_Image

You can solve this by installing SDL2_Image

        On the mac use:
            > brew install sdl2_image

        ])]
    )

    LDFLAGS="${ORIG_LDFLAGS}"
    AC_SUBST([SDL_LIBS], ["${SDL_LIBS} -lSDL2_image"])
])

AC_DEFUN([AX_THOR_CHECK_USE_CRYPTO],
[
    AX_THOR_CHECK_TEMPLATE_LIBRARY_TEST(
        [crypto],
        [crypto],
        [CRYPTO],
        [crypto], [SHA1_Init],
        [ssl crypto],
        [CRYPTO],
        [crypto],
        [NotThor],
        [

Error: Could not find libcrypto

        On a mac you will need to install openssl
        and define the crypto root directory to configuration.

            brew install openssl
            ./configure --with-crypto-root=/usr/local/Cellar/openssl/1.0.2j/

        On Linux you will need to install openssl

            sudo apt-get install openssl
            sudo apt-get install libssl-dev

        ]

    )
])

AC_DEFUN([AX_THOR_CHECK_USE_MAGIC_ENUM],
[
    AX_THOR_CHECK_USE_TEMPLATE_HEADER_TEST(
        [magicenum-header-only],
        [magicenum_header_only],
        [MagicEnumHeaderOnly],
        [magic_enum.hpp],
        [1],
        [
Could not find the header file <magic-enum.hpp>.
You can install this with

    brew install magic_enum

Alternately if you have manually installed magic_enum you can specify its location with
    --with-magicenum-root=<location of magic_enum installation>

            ])
        ]
    )
])

AC_DEFUN([AX_THOR_CHECK_USE_EVENT],
[
    AX_THOR_CHECK_TEMPLATE_LIBRARY_TEST(
        [event],
        [event],
        [Event],
        [event], [event_dispatch],
        [event],
        [EVENT],
        [event],
        [NotThor],
        [

Error: Could not find libevent

    You can solve this by installing libevent
    see http://libevent.org/

    If libevent is not installed in the default location (/usr/local or /opt/homebrew) then you will need to specify its location.
    --with-event-root=<location of event installation>


        ]

    )
])

AC_DEFUN([AX_THOR_CHECK_USE_BOOST],
[
    AX_BOOST_BASE([$1], [$2], [$3])
    AC_SUBST([BOOST_ROOT_DIR], [${_AX_BOOST_BASE_boost_path}])
    AC_SUBST([BOOST_ROOT_LIB], [])
])

AC_DEFUN([AX_THOR_CHECK_USE_YAML],
[
    AX_THOR_CHECK_TEMPLATE_LIBRARY_TEST(
        [yaml],
        [yaml],
        [YAML],
        [yaml], [yaml_parser_initialize],
        [yaml],
        [YAML],
        [yaml],
        [NotThor],
        [
Error: Could not find libyaml

You can solve this by installing libyaml
    see http://pyyaml.org/wiki/LibYAML

Alternately specify install location with:
    --with-yaml-root=<location of yaml installation>
        ]

    )
])

AC_DEFUN([AX_THOR_CHECK_USE_SNAPPY],
[
    AX_THOR_CHECK_TEMPLATE_LIBRARY_TEST(
        [snappy],
        [snappy],
        [SNAPPY],
        [snappy], [snappy_compress],
        [snappy],
        [SNAPPY],
        [snappy],
        [NotThor],
        [
Error: Could not find libsnappy

You can solve this by installing libsnappy
    brew install snappy

Alternately specify install location with:
    --with-snappy-root=<location of snappy installation>
        ]

    )
])

AC_DEFUN([AX_THOR_CHECK_USE_THORS_SERIALIZE_HEADER_ONLY],
[
    AX_THOR_CHECK_USE_TEMPLATE_HEADER_TEST(
        [thorserialize-header-only],
        [thorserialize_header_only],
        [ThorSerializeHeaderOnly],
        [ThorSerialize/ThorsSerializerUtil.h],
        [0],
        [
Could not find the header file <ThorSerialize/ThorsSerializerUtil.h>

    You can install this with:

        git clone --single-branch --branch header-only https://github.com/Loki-Astari/ThorsSerializer.git <Location>

        ./configure --with-thorserialize-header-only-root=<Location>

        ]
    )
])

AC_DEFUN([AX_THOR_CHECK_USE_THORS_SERIALIZE],
[
    AX_THOR_CHECK_TEMPLATE_LIBRARY_TEST(
        [thorserialize],
        [thorserialize],
        [Thors Serializer],
        [ThorSerialize17], [_ZN10ThorsAnvil9Serialize10JsonParser12getNextTokenEv],
        [ThorSerialize ThorsLogging],
        [THORSSERIALIZER],
        [ThorSerialize],
        [ThorsSerializer],
        [
Error: Could not find libThorSerialize17

You can solve this by installing Thors Serializer
    brew install thors-serializer

Alternately specify install location with:
    --with-thorserialize-root=<location of snappy installation>
        ]

    )
])

AC_DEFUN([AX_THOR_CHECK_USE_THORS_DB],
[
    AX_THOR_CHECK_TEMPLATE_LIBRARY_TEST(
        [thorsdb],
        [thorsdb],
        [Thors DB],
        [ThorsDB17], [_ZTSN10ThorsAnvil2DB6Access3Lib15ConnectionProxyE],
        [ThorsDB],
        [THORSDB],
        [ThorsDB],
        [ThorsDB],
        [
Error: Could not find libThorsDB17

You can solve this by building ThorsDB
    > git clone git@github.com:Loki-Astari/ThorsDB.git
    > cd ThorsDB
    > make
    > sudo make install

If you don't install in the default location (/use/local  (or /opt/homebrew on M1 mac))
Then you can specify the install location with:

    --with-thorsdb-root=<location of snappy installation>
        ]

    )
])

AC_DEFUN([AX_THOR_CHECK_USE_SMARTY],
[
    AC_CHECK_LIB(
        [smarty],
        [__ZN6snappy10UncompressEPNS_6SourceEPNS_4SinkE]
        [],
        [
            AC_MSG_ERROR([
Error: Could not find libsnappy

    On mac this can be installed with:
        brew install snappy

    On ubuntu this can be installed with:
        sudo apt-get install libsnappy-dev

            ])
        ]
    )
])

AC_DEFUN([AX_THOR_DISABLE_TEST],
[
    AC_ARG_ENABLE(
        [test-$1],
        AS_HELP_STRING([--disable-test-$1], [$5])
    )

    AS_IF(
        [test "x${enable_test_$2}" == "xno"],
        [
            AC_DEFINE([$3], [1], [$4])
            subconfigure="${subconfigure} --disable-test-$1";
        ],
        [
            AC_DEFINE([$3], [0], [$4])
        ]
    )
])

AC_DEFUN([AX_THOR_DISABLE_TEST_REQUIREING_LOCK_FILES],
[
    AX_THOR_DISABLE_TEST(
        [with-locked-file],
        [with_locked_file],
        [THOR_DISABLE_TEST_WITH_LOCKED_FILES],
        [Disable test that require files to be locked],
        [
Windows does not provide the same locking capabilities as Linux.
Thus during testing when we try and lock files, it does not work, so that an attempt to open them would fail.
Unfortunately we can't lock the files and thus the test pass.
Don't run these tests on Windows.
        ]
    )
])

AC_DEFUN([AX_THOR_DISABLE_TEST_REQUIREING_POSTGRES_AUTHENTICATION],
[
    AX_THOR_DISABLE_TEST(
        [with-postgres-auth],
        [with_postgres_auth],
        [THOR_DISABLE_TEST_WITH_POSTGRES_AUTH],
        [Disable test that require Authentication with Postgres server],
        [
The postgres functionality is still nacent (not much work completed here).
As a result the authentication protocol is not working and so no tests that connect to the server can complete
unless authentication has been completely turned off.

Disable tests on Postgres where authentication required.
        ]
    )
])

AC_DEFUN([AX_THOR_DISABLE_TEST_REQUIREING_MONGO_QUERY],
[
    AX_THOR_DISABLE_TEST(
        [with-mongo-query],
        [with_mongo_query],
        [THOR_DISABLE_TEST_WITH_MONGO_QUERY],
        [Disable test that require the Mongo server to support the OP_QUERY command],
        [
There are three versions of the mongo wire protocol.

Newer versions of Mongo do not support the older protocols.
This flags disables tests that use the older wire protocol and only performs tests that use
the now standard OP_MSG protocol.
        ]
    )
])

AC_DEFUN([AX_THOR_CHECK_DISABLE_TIMEGM],
[
    AC_ARG_WITH(
        [timegm],
        [AS_HELP_STRING([--without-timegm], [Disables tests that use the timegm functions])]
    )

    AS_IF([test "x$with_timegm" != xno],
    [
        AC_CHECK_FUNCS(
            [timegm],
            [],
            [
                AC_MSG_ERROR([

Error: Could not find `timegm()` function on your system.

    timegm() is only used for testing.
    If you are just building this package for usage (and trust that test will work) then you can safely disable this test.
    If you are using modifying this package you will need to fix this because you need to run all the tests before submitting a pull request.

    To disable these test by specifying --without-timegm

    PS: If you happen to know a valid alternative to timegm() that is POSIX standard I would be greatful for input.
                ])
            ]
        )
    ],
    [
        AC_DEFINE([THOR_USE_TIMEGM_FLASE], [1], [Disable tests that use timegm()])
    ])
])

AC_DEFUN([AX_THOR_CHECK_DISABLE_MODTEST],
[
    AC_ARG_WITH(
        [modtests],
        [AS_HELP_STRING([--without-modtests], [Disables tests that check that modifying the DB work])]
    )

    AS_IF([test "x$with_modtests" != xno],
    [
        thor_clt=good
        AC_CHECK_TOOL([echo], [], [thor_clt=bad])
        AC_CHECK_TOOL([wc],   [], [thor_clt=bad])
        AC_CHECK_TOOL([awk],  [], [thor_clt=bad])
        AS_IF([test "x$thor_clt" == xbad],
        [
            AC_MSG_ERROR([

Error: Could not find one or more of: echo wc awk

    echo/awk/ws are only used for testing.
    If you are just building this package for usage (and trust that test will work) then you can safely disable this test.
    If you are using modifying this package you will need to fix this because you need to run all the tests before submitting a pull request.

    To disable these test by specifying --without-modtests

            ])
        ])
    ],
    [
        AC_DEFINE([THOR_USE_MOD_TESTS_FLASE], [1], [Disable tests that use timegm()])
    ])
])


AC_DEFUN([AX_THOR_CHECK_USE_STATIC_LOAD],
[
    #
    # This function works in conjunction with the build/tools/Makefile
    # See the macro: THORSANVIL_STATICLOADALL
    #
    AX_CHECK_LINK_FLAG(
        [-Wl,-all_load],
        [AC_SUBST([THOR_STATIC_LOAD_FLAG],[-Wl,-all_load])]
    )
    AX_CHECK_LINK_FLAG(
        [-Wl,-noall_load],
        [AC_SUBST([THOR_STATIC_NOLOAD_FLAG],[])]
    )
    AX_CHECK_LINK_FLAG(
        [-Wl,--whole-archive -Wl,--no-whole-archive],
        [AC_SUBST([THOR_STATIC_LOAD_FLAG],[-Wl,--whole-archive])]
        [AC_SUBST([THOR_STATIC_NOLOAD_FLAG],[-Wl,--no-whole-archive])]
    )
])

###################################################################################################

AC_DEFUN([AX_THOR_CHECK_APP_LEX],
[
    AC_PROG_LEX
    if test "${LEX}" != "flex"; then
        AC_MSG_ERROR([

Error: This package uses flex (and is not compatible with lex).
Please make sure flex is installed.

If it is installed an autotools is picking the wrong lex you explicitly specify it via
the environment variable LEX.

Eg.
    LEX=<path to flex> ./configure <other flags>

            ]
        )
    fi
])

AC_DEFUN([AX_THOR_CHECK_APP_COV],
[
    AS_IF(
        [test "x${COV}x" = "xx"],
        [
            AS_IF(
                [test "${CXX}" = "g++"],
                [AC_SUBST([COV],[gcov])],
                [
                    AS_IF(
                        [test "${CXX}" = "clang++"],
                        [AC_SUBST([COV],[llvm-cov])],
                        [
                            AC_MSG_ERROR([

Could not determine the coverage tool.

For g++ we default to gcov
For clang++ we default to llvm-cov

The compiler currently defined is "${CXX}" and we do not know what coverage tool to use.

One alternatives is to specify a know compiler before calling configure.

    CXX=clang++ ./configure

Another alternative is to explicitly specify the coverage tool to use.

    COV=gcov ./confgiure

                            ])
                        ]
                    )
                ]
            )
        ]
    )
    ${COV} --version 2>&1 | grep -Eo '([[[:digit:]]]+\.)+[[[:digit:]]]+' || ${COV} --version 2>&1 | grep -Po '(\d+\.)+\d+' > /dev/null
    AS_IF(
        [test $? != 0],
        [
            AC_MSG_ERROR([

The coverage tool "${COV}" does not seem to be working.

            ])
        ]
    )
])


###################################################################################################

AC_DEFUN([AX_THOR_FUNC_TEST_BOOST_COROUTINE_VERSION],
[
    CXXFLAGS_SAVE=$CXXFLAGS
    CXXFLAGS+=" ${CXX_STD_FLAG} ${BOOST_CPPFLAGS}"

    thor_boost_coroutine_versoin=no
    AC_MSG_NOTICE([Checking Boost CoRoutine Version])
    AC_COMPILE_IFELSE(
        [AC_LANG_SOURCE([[@%:@include <boost/coroutine/all.hpp>]])],
        [
            thor_boost_coroutine_versoin=1
            AC_MSG_NOTICE([Checking Boost CoRoutine Version V1 OK])
        ]
    )
    AC_COMPILE_IFELSE(
        [AC_LANG_SOURCE([[@%:@include <boost/coroutine/all.hpp>]],[[ boost::context::asymmetric_coroutine<short>::pull_type x;]])],
        [
            thor_boost_coroutine_versoin=2
            AC_MSG_NOTICE([Checking Boost CoRoutine Version V2 OK])
        ]
    )
    AC_COMPILE_IFELSE(
        [AC_LANG_SOURCE([[@%:@include <boost/coroutine2/all.hpp>]])],
        [
            thor_boost_coroutine_versoin=3
            AC_MSG_NOTICE([Checking Boost CoRoutine Version V3 OK])
        ]
    )
    CXXFLAGS=$CXXFLAGS_SAVE

    AS_IF([test "x${thor_boost_coroutine_versoin}" == "xno"],
        [
            AC_MSG_ERROR([

Error: Can not tell the type of the boost coroutine library.

            ])
        ],
        [
	        AC_DEFINE_UNQUOTED([BOOST_COROUTINE_VERSION],[$thor_boost_coroutine_versoin],[Define which version of the boost co-routines we are using])
            AC_SUBST([BOOST_COROUTINE_VERSION], [$thor_boost_coroutine_versoin])
        ]
    )
])


AC_DEFUN([AX_THOR_FUNC_TEST_COMP],
[
    AS_IF(
        [test "$1" != ""],
        [
            AC_MSG_CHECKING([Checking Compiler Compatibility ${CXX} ${CXX_STD_FLAG}])
            AC_LANG(C++)
            CXXFLAGS_SAVE="${CXXFLAGS}"
            AC_SUBST([CXXFLAGS], [${CXX_STD_FLAG}])
            AC_COMPILE_IFELSE([AC_LANG_SOURCE([$1])],
                [
                    AC_MSG_RESULT([good])
                ],
                [
                    AC_MSG_ERROR([

Error: Your compiler does not seem to support the language features required.
       Try updating your compiler to use a more recent version.

       Compiler used: ${CXX} ${CXX_STD_FLAG}
                    ])
                ]
            )
            AC_SUBST([CXXFLAGS], [${CXXFLAGS_SAVE}])
        ]
    )
])

AC_DEFUN([AX_THOR_FUNC_TEST_BINARY],
[
    AC_ARG_WITH(
        [thors-network-byte-order],
        AS_HELP_STRING([--with-thors-network-byte-order], [Use internal tools to convert 64/128 bit values to network byte order])
    )
    AC_ARG_ENABLE(
        [binary],
        AS_HELP_STRING([--disable-binary], [Disable binary serialization])
    )
    AS_IF(
        [test "x$enable_binary" != "xno"],
        [
            networkbyteorderfunction=""
            AC_C_BIGENDIAN(
                [networkbyteorderfunction="identity"],
                [
                    AS_IF(
                        [test "${with_thors_network_byte_order}" == "yes"],
                        [networkbyteorderfunction="thorsNetworkByteOrder"],
                        [
                            AX_BSWAP64
                            networkbyteorderfunction = bswap64_function;
                        ]
                    )
                ]
            )
            AS_IF(
                [test "x$networkbyteorderfunction" != "x"],
                [
                    AC_DEFINE([NETWORK_BYTE_ORDER], 1, [We have functions to convert host to network byte order for 64/128 bit values])
                    AC_DEFINE_UNQUOTED([BSWAP64], [${bswap64_function}], [Name of the 64/128 bit endian swapping function])
                ],
                [
                    AC_MSG_ERROR([

Error: Could not find a way to convert 64 bit values to big endian for transport

You can ignore this error by disable binary serialization.

If you do not want to use binary serialization then it
can be disabled with:
    --disable-binary

Alternatively you can use some non standard functions implemented in ThorsSerializer
    --with-thors-network-byte-order

NOTE:
    When using binary format we need a consistent representation.
    Since the standard for 16/32 bit values is network byte order
    I want to be consistent and do the same for 64/128 bit values.

    There are standard libraries for 16/32 bit conversion between
    host and network byte order

        htonl() ntohl()     # 32 bit
        htons() ntohs()     # 16 bit

    But there is no standard way for larger values.
    So we use the configuration script to look for some semi-standard techniques
    The configuration script could not find any of these semi standard formats.

    If you want to use a non standard technique (implemented by Loki) you must
    explicitly ask for it with (though it is tested as correct it will not be
    faster than the semi standard ways as they rely on assembler while this code
    is standard C++ only).

        --with-thors-network-byte-order

                    ])
                ]
            )
        ]
    )
])

###################################################################################################

AC_DEFUN([AX_THOR_SERVICE_AVAILABLE_CHECK],
[
    dnl 1: =>   Name used for Macros:               ALL CAPS
    dnl 2: =>   Name for flags used by configure.   Camel Case
    dnl 3: =>   Application name                    application
    dnl 4: =>   File name extension for data.
    dnl 5: =>   Flags preceding host
    dnl 6: =>   statement to execute on 3
    dnl 7: =>   Value returned by 6
    dnl 8: =>   How many lines from the end of the output is the result.
    dnl 9: =>   Command to extract version from the command line tool 3
    dnl 10: =>  What Line the version info is on.
    dnl 11: =>  What column the version info is on.
    dnl 12: =>  After how many dots is the major version
    dnl 13: =>  Argument to specify user.
    dnl 14: =>  Argument to specify password
    dnl 15: =>  Environment variable to set
    dnl 16: =>  Command line tool used to interact with $3
    dnl 16: =>  NOT USED. But needed so 14 is not the last argument.

    AC_ARG_WITH([Test$2Host], AS_HELP_STRING([--with-Test$2Host=<Host>], [Use an alternative $3 host for testing with Default(127.0.0.1)]))
    AC_ARG_WITH([Test$2User], AS_HELP_STRING([--with-Test$2User=<User>], [Use an alternative $3 user for testing with (test)]))
    AC_ARG_WITH([Test$2Pass], AS_HELP_STRING([--with-Test$2Pass=<Pass>], [Use an alternative $3 password for testing with (testPassword)]))
    AC_ARG_WITH([Test$2Database], AS_HELP_STRING([--with-Test$2Database=<DB>], [Use an alternative $3 database for testing with (test)]))

    $3_test_host="127.0.0.1"
    $3_test_user="test"
    $3_test_pw="testPassword"
    $3_test_db="test"

    AS_IF([test "x$have_Test$2Host" = "xyes"], [$3_test_host=$with_Test$2Host])
    AS_IF([test "x$have_Test$2User" = "xyes"], [$3_test_user=$with_Test$2User])
    AS_IF([test "x$have_Test$2Pass" = "xyes"], [$3_test_pw=$with_Test$2Pass])
    AS_IF([test "x$have_Test$2Database" = "xyes"], [$3_test_db=$with_Test$2Database])

    AC_DEFINE_UNQUOTED([THOR_TESTING_$1_HOST], ["$$3_test_host"], [$3 DB host for testing])
    AC_DEFINE_UNQUOTED([THOR_TESTING_$1_USER], ["$$3_test_user"], [$3 DB user for testing])
    AC_DEFINE_UNQUOTED([THOR_TESTING_$1_PASS], ["$$3_test_pw"],   [$3 DB password for testing])
    AC_DEFINE_UNQUOTED([THOR_TESTING_$1_DB],   ["$$3_test_db"],   [$3 DB for testing])

    cli_tool=$3

    AC_ARG_WITH([$3-tool], AS_HELP_STRING([--with-$3-tool=<alternative cli>], [The default tool name is $3. But this can be overridden with this flag]))

    AS_IF([test "x${with_$3_tool}" != "x"], [cli_tool=${with_$3_tool}])


    echo "COMMAND: >$6<"
    echo "DB LINK: >${cli_tool} $5 $$3_test_host $13$$3_test_user $14$$3_test_pw $$3_test_db<" | sed -e 's/[Pp]ass/aasp/g'
    echo "$6" | $15 ${cli_tool} $5 $$3_test_host $13$$3_test_user $14$$3_test_pw $$3_test_db
    test_connect=`echo "$6" | $15 ${cli_tool} $5 $$3_test_host $13$$3_test_user $14$$3_test_pw $$3_test_db 2> /dev/null | tail -$8 | head -1 | sed -e 's/test>//' | xargs`
    echo "RESULT:  >${test_connect}<"
    AS_IF([test "x$test_connect" != "x$7"],
    [
            AC_MSG_ERROR([

    Error: Can not connect to server($1) using ${cli_tool} (Note: Default $3).

            This may be because the $3 server is not running or the test data has not been created.

            1: Install $2 server
            2: Make sure $2 is running
            3: Install the test data and users.
                    cat ./src/$2/test/data/init.$4 | ${cli_tool} $5 $$3_test_host $13root $14
                    cat ./src/$2/test/data/data.$4 | ${cli_tool} $5 $$3_test_host $13$$3_test_user $14$$3_test_pw $$3_test_db

            ])
    ])

    version=`$15 ${cli_tool} $5 $$3_test_host $13$$3_test_user $14$$3_test_pw $9 $$3_test_db | tail -$10 | awk '{print $$11}' | awk -F\. '{print $$12}'`
    AC_DEFINE_UNQUOTED([$1_MAJOR_VERSION], [${version}], ["Get $3 version into #define. That way we can turn off some tests"])
])

AC_DEFUN([AX_THOR_SERVICE_AVAILABLE_POSTGRES],
[
    AX_THOR_SERVICE_AVAILABLE_CHECK(
        [POSTGRES], [Postgres], [psql], [sql],
        [-h],
        [select 3+4], [7],
        [3],
        [--version],
        [2], [3], [1],
        [--username=], [--variable=NAME=],
        [PGPASSWORD=$psql_test_pw],
        [Word]
    )
])

AC_DEFUN([AX_THOR_SERVICE_AVAILABLE_MYSQL],
[
    AX_THOR_SERVICE_AVAILABLE_CHECK(
        [MYSQL], [MySQL], [mysql], [sql],
        [-B -h],
        [select 3+4 from dual], [7],
        [1],
        [-e 'SHOW VARIABLES LIKE "innodb_version"'],
        [1], [2], [1],
        [--user=], [--password=],
        [],
        [Word]
    )
])

AC_DEFUN([AX_THOR_SERVICE_AVAILABLE_MONGO],
[
    AX_THOR_SERVICE_AVAILABLE_CHECK(
        [MONGO], [Mongo], [mongosh], [mongo],
        [--host],
        [db.Blob.stats().nindexes], [1],
        [2],
        [--eval 'db.version()'],
        [1], [1], [1],
        [--username ], [--password ],
        [],
        [Word]
    )
])



###################################################################################################

AC_DEFUN([AX_THOR_DEPIRCATE],
[
    AC_MSG_FAILURE([Depricated: $1 => $2])
])

AC_DEFUN([AX_THOR_FUNC_BUILD],                  AX_THOR_DEPIRCATE([D_AX_THOR_FUNC_BUILD],                   [D_AX_THOR_FUNC_INIT_BUILD]))
AC_DEFUN([AX_THOR_LOCAL_DIR],                   AX_THOR_DEPIRCATE([D_AX_THOR_LOCAL_DIR],                    [D_AX_THOR_FUNC_BUILD_LOCAL_DIR]))
AC_DEFUN([AX_THOR_FUNC_USE_VERA_INIT],          AX_THOR_DEPIRCATE([D_AX_THOR_FUNC_USE_VERA_INIT],           [D_AX_THOR_FUNC_BUILD_VERA_INIT]))
AC_DEFUN([AX_THOR_LIB_SELECT],                  AX_THOR_DEPIRCATE([D_AX_THOR_LIB_SELECT],                   [D_AX_THOR_FUNC_BUILD_LIB_SELECT]))
AC_DEFUN([AX_THOR_USE_HOST_BUILD],              AX_THOR_DEPIRCATE([D_AX_THOR_USE_HOST_BUILD],               [D_AX_THOR_FUNC_BUILD_HOST_BUILD]))
AC_DEFUN([AX_THOR_COLOUR_MODE],                 AX_THOR_DEPIRCATE([D_AX_THOR_COLOUR_MODE],                  [D_AX_THOR_FUNC_BUILD_COLOUR_MODE]))
AC_DEFUN([AX_THOR_SET_HEADER_ONLY_VARIABLES],   AX_THOR_DEPIRCATE([D_AX_THOR_SET_HEADER_ONLY_VARIABLES],    [D_AX_THOR_FUNC_BUILD_HEADER_ONLY_VARIABLES]))
AC_DEFUN([AX_THOR_CHECK_FOR_SDL],               AX_THOR_DEPIRCATE([D_AX_THOR_CHECK_FOR_SDL],                [D_AX_THOR_CHECK_USE_SDL]))
AC_DEFUN([AX_THOR_FUNC_USE_CRYPTO],             AX_THOR_DEPIRCATE([D_AX_THOR_FUNC_USE_CRYPTO],              [D_AX_THOR_CHECK_USE_CRYPTO]))
AC_DEFUN([AX_THOR_FUNC_USE_THORS_LIB_DB],       AX_THOR_DEPIRCATE([D_AX_THOR_FUNC_USE_THORS_LIB_DB],        [D_AX_THOR_CHECK_USE_THORS_DB]))
AC_DEFUN([AX_THOR_FUNC_USE_THORS_LIB_SERIALIZE],AX_THOR_DEPIRCATE([D_AX_THOR_FUNC_USE_THORS_LIB_SERIALIZE], [D_AX_THOR_CHECK_USE_THORS_SERIALIZE]))
AC_DEFUN([AX_THOR_FUNC_USE_MAGIC_ENUM],         AX_THOR_DEPIRCATE([D_AX_THOR_FUNC_USE_MAGIC_ENUM],          [D_AX_THOR_CHECK_USE_MAGIC_ENUM]))
AC_DEFUN([AX_THOR_FUNC_USE_EVENT],              AX_THOR_DEPIRCATE([D_AX_THOR_FUNC_USE_EVENT],               [D_AX_THOR_CHECK_USE_EVENT]))
AC_DEFUN([AX_THOR_BOOST_BASE],                  AX_THOR_DEPIRCATE([D_AX_THOR_BOOST_BASE],                   [D_AX_THOR_CHECK_USE_BOOST]))
AC_DEFUN([AX_THOR_FUNC_USE_YAML],               AX_THOR_DEPIRCATE([D_AX_THOR_FUNC_USE_YAML],                [D_AX_THOR_CHECK_USE_YAML]))
AC_DEFUN([AX_THOR_PROG_LEX],                    AX_THOR_DEPIRCATE([D_AX_THOR_PROG_LEX],                     [D_AX_THOR_CHECK_APP_LEX]))
AC_DEFUN([AX_THOR_FUNC_USE_BINARY],             AX_THOR_DEPIRCATE([D_AX_THOR_FUNC_USE_BINARY],              [D_AX_THOR_FUNC_TEST_BINARY]))
AC_DEFUN([AX_THOR_TEST_CXX_FLAGS],              AX_THOR_DEPIRCATE([D_AX_THOR_TEST_CXX_FLAGS],               [D_AX_THOR_FUNC_LANG_CHECK_FLAGS]))
AC_DEFUN([AX_THOR_PROG_COV],                    AX_THOR_DEPIRCATE([D_AX_THOR_PROG_COV],                     [D_AX_THOR_CHECK_APP_COV]))
AC_DEFUN([AX_THOR_CHECK_THIRD_PARTY_LIBS],      AX_THOR_DEPIRCATE([D_AX_THOR_CHECK_THIRD_PARTY_LIBS],       [D_AX_THOR_FUNC_BUILD_THIRD_PARTY_LIBS]))
AC_DEFUN([AX_THOR_FIX_GIT_SYMLINKS_WINDOWS],    AX_THOR_DEPIRCATE([D_AX_THOR_FIX_GIT_SYMLINKS_WINDOWS],     [D_AX_THOR_FUNC_BUILD_FIX_GIT_SYMLINKS_WINDOWS]))
AC_DEFUN([AX_THOR_STATIC_LOAD_CHECK],           AX_THOR_DEPIRCATE([D_AX_THOR_STATIC_LOAD_CHECK],            [D_AX_THOR_CHECK_USE_STATIC_LOAD]))

