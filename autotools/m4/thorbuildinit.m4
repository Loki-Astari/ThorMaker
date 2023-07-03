AC_DEFUN([AX_THOR_CHECK_FOR_SDL],
[
    AX_THOR_CHECK_FOR_SDL_MAIN
    AX_THOR_CHECK_FOR_SDL_TTF
    AX_THOR_CHECK_FOR_SDL_Image
])


AC_DEFUN([AX_THOR_CHECK_FOR_SDL_MAIN],
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

AC_DEFUN([AX_THOR_CHECK_FOR_SDL_TTF],
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

        ], [1])]
    )

    LDFLAGS="${ORIG_LDFLAGS}"
    AC_SUBST([SDL_LIBS], ["${SDL_LIBS} -lSDL2_ttf"])
])

AC_DEFUN([AX_THOR_CHECK_FOR_SDL_Image],
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

        ], [1])]
    )

    LDFLAGS="${ORIG_LDFLAGS}"
    AC_SUBST([SDL_LIBS], ["${SDL_LIBS} -lSDL2_image"])
])

AC_DEFUN([AX_THOR_STATIC_LOAD_CHECK],
[
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

AC_DEFUN([AX_THOR_LOCAL_DIR],
[
    DefaultLinkDir="/usr/local"
    host=$(uname -p)
    AS_IF([test "${host}" == "arm" ],
    [
        DefaultLinkDir="/opt/homebrew"
        AS_IF([test "${prefix}" == "NONE"], [prefix=${DefaultLinkDir}])
        AC_SUBST([THOR_STD_INCLUDES], [-I${DefaultLinkDir}/include])
    ])
    AC_SUBST([DefaultLinkDir], [${DefaultLinkDir}])
])
AC_DEFUN([AX_THOR_FUNC_USE_CRYPTO],
[
    crypto_ROOT_LIB=""
    crypto_ROOT_DIR=""

    AC_ARG_WITH(
        [cryptoroot],
        AS_HELP_STRING([--with-cryptoroot=<location>], [Directory of CRYPTO_ROOT])
    )
    ORIG_LDFLAGS="${LDFLAGS}"
    LDFLAGS="$LDFLAGS -L$with_cryptoroot/lib"

    AC_CHECK_LIB(
        [crypto],
        [SHA1_Init],
        [
            AS_IF([test "$with_cryptoroot" != ""],
                  [
                    crypto_ROOT_DIR="$with_cryptoroot"
                    subconfigure="${subconfigure} --with-cryptoroot=$with_cryptoroot"
                  ])
        ],
        [AC_MSG_ERROR([
 
Error: Could not find libcrypto

        On a mac you will need to install openssl
        and define the crypto root directory to configuration.

            brew install openssl
            ./configure --with-cryptoroot=/usr/local/Cellar/openssl/1.0.2j/

        On Linux you will need to install openssl

            sudo apt-get install openssl
            sudo apt-get install libssl-dev

                ], [1])]
    )
    crypto_ROOT_LIB="ssl crypto"

    LDFLAGS="${ORIG_LDFLAGS}"
    AC_SUBST([crypto_ROOT_LIB], [${crypto_ROOT_LIB}])
    AC_SUBST([crypto_ROOT_DIR], [${crypto_ROOT_DIR}])
])
AC_DEFUN([AX_THOR_LIB_SELECT],
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

AC_DEFUN([AX_THOR_FUNC_USE_VERA_INIT],
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
                [
                ]
            )
            VERATOOL='vera++';
        ]
    )
    AC_SUBST([VERATOOL], [${VERATOOL}])
])

AC_DEFUN([AX_THOR_USE_HOST_BUILD],
[
    AC_ARG_WITH(
        [hostbuild],
        AS_HELP_STRING([--with-hostbuild=<dir>], [Use the build tools located at <dir>])
    )

    AS_IF(
        [test "x${with_hostbuild}" != "x"],
        [
            echo "Using Existing Host Build Tools: ${with_hostbuild}"
            rm build
            ln -s ${with_hostbuild} build
            ls -la build
        ]
    )
])

AC_DEFUN([AX_THOR_CHECK_THIRD_PARTY_LIBS],
[
    export cwd=$(pwd)

    pushd third
    if [[ $? == 0 ]]; then
        for third in $(ls); do
            pushd ${third}
            if [[ -e ./configure ]]; then
                echo "${third}:  ./configure ${subconfigure} --prefix=${prefix} --with-hostbuild=${cwd}/build"
                ./configure ${subconfigure} --prefix=${prefix} --with-hostbuild=${cwd}/build
                if [[ $? != 0 ]]; then
                    "Failed to configure: ${third}"
                    exit 1
                fi
            fi
            echo "================ DONE ================="
            popd
        done
        popd
    fi
])

AC_DEFUN([AX_THOR_FUNC_BUILD],
[
    AX_THOR_LOCAL_DIR
    AC_CHECK_PROGS([UNZIP], [bzip2], [:])
    if test "$UNZIP" = :; then
        AC_MSG_ERROR([The build tools needs bzip2. Please install it.])
    fi

    AC_PROG_CXX

    subconfigure=""
    git submodule update --init --recursive
    AX_THOR_FUNC_USE_VERA_INIT
    AX_THOR_LIB_SELECT
    AX_THOR_USE_HOST_BUILD
    AX_THOR_COLOUR_MODE

    AS_IF(
        [test "x${with_hostbuild}" == "x"],
        [
            pushd build/third
            ./setup "$CXX" || AC_MSG_ERROR([Failed to set up the test utilities], [1])
            popd
        ]
    )
])

AC_DEFUN([AX_THOR_PROG_LEX],
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

    ])
    fi
])

AC_DEFUN([AX_THOR_FUNC_USE_THORS_LIB],
[
    local_ROOT_DIR=""
    local_ROOT_LIB=""
    AC_SUBST(HAVE_Thors$1)
    AC_ARG_WITH(
        [Thors$1root],
        AS_HELP_STRING([--with-Thors$1root=<location>], [Directory of Thors$1_ROOT])
    )
    AC_ARG_ENABLE(
        [Thors$1],
        AS_HELP_STRING([--disable-Thors$1], [Don't use Thors$1. This means features that use Thors$1 will be disabled.])
    )
    AS_IF(
        flag=enable_Thors$1
        [test "x${!flag}" != "xno"],

        AC_LANG_PUSH([C++])
        AC_MSG_NOTICE([Got HERE])
        AC_MSG_NOTICE([Name: $1])
        AC_MSG_NOTICE([With: ${with_Thors$1root}])

        if test "${with_Thors$1root}" == ""; then
            declare with_Thors$1root="${DefaultLinkDir}"
        fi
        ORIG_LDFLAGS="${LDFLAGS}"
        LDFLAGS="-std=c++17 $LDFLAGS -L${with_Thors$1root}/lib"
        AC_MSG_NOTICE([LDFLAGS: ${LDFLAGS}])
        AC_MSG_NOTICE([LIB: $4])
        AC_MSG_NOTICE([Meth: $5])

        AC_CHECK_LIB(
            [$4],
            [$5],
            [
                AC_DEFINE([HAVE_Thors$1], 1, [When on code that uses Thors$1 will be compiled.])
                local_ROOT_DIR="${with_Thors$1root}"
                local_ROOT_LIB="$3"
                HAVE_Thors$1=yes
            ],
            [AC_MSG_ERROR([
 
Error: Could not find lib$4

You can solve this by installing lib$3
    $6

Alternately specify install location with:
    --with-Thors$1root=<location of Thors$1 installation>

If you do not want to use features that need Thor$1 then it
can be disabled with:
    --disable-Thors$1

                ], [1])],
                [$7]
        )
        LDFLAGS="${ORIG_LDFLAGS}"
        AC_LANG_POP([C++])
    )
    AC_SUBST(Thors$1_ROOT_DIR, [${local_ROOT_DIR}])
    AC_SUBST(Thors$1_ROOT_LIB, [${local_ROOT_LIB}])
])
AC_DEFUN([AX_THOR_FUNC_USE_THORS_LIB_DB],
[
    AX_THOR_FUNC_USE_THORS_LIB(DB, $1, ThorsDB, [ThorsDB$1], [_ZN10ThorsAnvil2DB6Access3Lib15ConnectionProxyD2Ev], [https://github.com/Loki-Astari/ThorsDB], [])
])
AC_DEFUN([AX_THOR_FUNC_USE_THORS_LIB_SERIALIZE],
[
    AX_THOR_FUNC_USE_THORS_LIB(Serialize, $1, ThorSerialize, [ThorSerialize$1], [_ZN10ThorsAnvil9Serialize10JsonParser12getNextTokenEv], [https://github.com/Loki-Astari/ThorsSerializer], [-ldl])
])
AC_DEFUN([AX_THOR_FUNC_USE_YAML],
[
    yaml_ROOT_DIR=""
    yaml_ROOT_LIB=""
    ORIG_LDFLAGS="${LDFLAGS}"
    AC_ARG_WITH(
        [yamlroot],
        AS_HELP_STRING([--with-yamlroot=<location>], [Directory of YAML_ROOT])
    )
    if test "${with_yamlroot}" == ""; then
        with_yamlroot="${DefaultLinkDir}"
    fi
    LDFLAGS="$LDFLAGS -L$with_yamlroot/lib"

    AC_CHECK_LIB(
        [yaml],
        [yaml_parser_initialize],
        [
            yaml_ROOT_DIR="${with_yamlroot}"
            yaml_ROOT_LIB="yaml"
        ],
        [AC_MSG_ERROR([

Error: Could not find libyaml

You can solve this by installing libyaml
    see http://pyyaml.org/wiki/LibYAML

Alternately specify install location with:
    --with-yamlroot=<location of yaml installation>

        ], [1])]
    )

    LDFLAGS="${ORIG_LDFLAGS}"
    AC_SUBST([yaml_ROOT_DIR], [${yaml_ROOT_DIR}])
    AC_SUBST([yaml_ROOT_LIB], [${yaml_ROOT_LIB}])
])
AC_DEFUN([AX_THOR_FUNC_USE_MAGIC_ENUM],
[
    magic_enum_ROOT_DIR=""
    ORIG_CXXFLAGS="${CXXFLAGS}"
    AC_ARG_WITH(
        [magicenumroot],
        AS_HELP_STRING([--with-magicenumroot=<location>], [Directory of YAML_ROOT])
    )
    if test "${with_magicenumroot}" == ""; then
        with_magicenumroot="${DefaultLinkDir}"
    fi
    CXXFLAGS="$CXXFLAGS -std=c++17 -I$with_magicenumroot/include"

    AC_LANG_PUSH([C++])
    AC_CHECK_HEADER(magic_enum.hpp,
        [
            magic_enum_ROOT_DIR="${with_magicenumroot}"
            subconfigure="${subconfigure} --with-magicenumroot=${with_magicenumroot}"
        ],
        [AC_MSG_ERROR(

${CXXFLAGS}

Could not find the header file <magic-enum.hpp>.
You can install this with

    brew install magic_enum

Alternately if you have manually installed magic_enum you can specify its location with
    --with-magicenumroot=<location of magic_enum installation>

        )]
    )
    AC_LANG_POP([C++])

    CXXFLAGS="${ORIG_CXXFLAGS}"
    AC_SUBST([magic_enum_ROOT_DIR], [${magic_enum_ROOT_DIR}])
])
AC_DEFUN([AX_THOR_COLOUR_MODE],
[
    COLOUR_STATE="ON"
    DARK_MODE=""
    AC_ARG_ENABLE(
        [colour],
        AS_HELP_STRING([--disable-colour], [Turns off text colouring in the makefile output])
    )
    AS_IF(
        [test "x$enable_colour" == "xno"],
        [
            COLOUR_STATE="OFF"
            subconfigure="${subconfigure} --disable-colour"
        ]
    )
    AC_SUBST([COLOUR_STATE], [${COLOUR_STATE}])
])

AC_DEFUN([AX_THOR_FUNC_USE_EVENT],
[
    event_ROOT_DIR=""
    event_ROOT_LIB=""
    AC_ARG_WITH(
        [eventroot],
        AS_HELP_STRING([--with-eventroot=<location>], [Directory of EVENT_ROOT])
    )
    if test "${with_eventroot}" == ""; then
        with_eventroot="${DefaultLinkDir}"
    fi
    ORIG_LDFLAGS="${LDFLAGS}"
    LDFLAGS="$LDFLAGS -L$with_eventroot/lib"

    AC_CHECK_LIB(
        [event],
        [event_dispatch],
        [
            AC_DEFINE([HAVE_EVENT], 1, [We have found libevent library])
            event_ROOT_DIR="${with_eventroot}"
            event_ROOT_LIB="event"
        ],
        [AC_MSG_ERROR([

Error: Could not find libevent

You can solve this by installing libevent
see http://libevent.org/

If libevent is not installed in the default location (/usr/local or /opt/homebrew) then you will need to specify its location.
--with-eventroot=<location of event installation>

            ], [1])]
    )

    LDFLAGS="${ORIG_LDFLAGS}"
    AC_SUBST([event_ROOT_DIR], [${event_ROOT_DIR}])
    AC_SUBST([event_ROOT_LIB], [${event_ROOT_LIB}])
])

AC_DEFUN(
    [AX_THOR_BOOST_BASE],
    [
        AC_ARG_WITH(
            [boost],
            AS_HELP_STRING([--with-boost=<dir>], [Directory of Boost Headers])
        )
        BOOST_CPPFLAGS="-I$with_boost"
        AC_SUBST([BOOST_CPPFLAGS], [${BOOST_CPPFLAGS}])
    ]
)

AC_DEFUN(
    [AX_THOR_FUNC_TEST_BOOST_COROUTINE_VERSION],
    [
        AC_LANG_PUSH([C++])
        CXXFLAGS_SAVE=$CXXFLAGS
        CXXFLAGS+=" -std=c++11 ${BOOST_CPPFLAGS}"

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
        AC_LANG_POP([C++])

        AS_IF([test "x${thor_boost_coroutine_versoin}" == "xno"],
              [AC_MSG_ERROR([

Error: Can not tell the type of the boost coroutine library.

                            ])
              ],
              [
	            AC_DEFINE_UNQUOTED([BOOST_COROUTINE_VERSION],[$thor_boost_coroutine_versoin],[Define which version of the boost co-routines we are using])
                AC_SUBST([BOOST_COROUTINE_VERSION], [$thor_boost_coroutine_versoin])
              ]
        )
    ]
)
AC_DEFUN(
    [AX_THOR_FUNC_TEST_COMP],
    [
        AS_IF([test "$1" != ""],
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
                ])
                AC_SUBST([CXXFLAGS], [${CXXFLAGS_SAVE}])
            ])
    ]
)

AC_DEFUN(
    [AX_THOR_TEST_CXX_FLAGS],
    [

AX_CHECK_COMPILE_FLAG(
    [-Wno-unused-private-field],
    [AC_SUBST([NO_UNUSED_PRIVATE_FIELD_TEST], [-Wno-unused-private-field])]
)
AX_CHECK_COMPILE_FLAG(
    [-Wno-deprecated-register],
    [AC_SUBST([NO_DEPRECATED_REGISTER_TEST], [-Wno-deprecated-register])]
)


    ]
)

AC_DEFUN(
    [AX_THOR_FUNC_LANG_FLAG],
    [
        AX_THOR_TEST_CXX_FLAGS()

        AC_ARG_WITH(
            [standard],
            AS_HELP_STRING([--with-standard=<version>], [Use the specified version <version> of the C++ standard])
        )

        minLangFeature=$1
        askedLangFeature=${minLangFeature}
        AS_IF(
            [test "x${with_standard}" != "x"],
            [
                askedLangFeature=${with_standard}
            ]
        )

        AS_IF([test "$2" = ""], [maxLangFeature=$1], [maxLangFeature=$askedLangFeature])
        AS_IF([test $minLangFeature -gt $askedLangFeature], AC_MSG_ERROR([Invalid Language requested: ${askedLangFeature}. Minimum: ${minLangFeature}],[1]))
        AS_IF([test $askedLangFeature -gt $maxLangFeature], AC_MSG_ERROR([Invalid Language requested: ${askedLangFeature}. Maximum: ${maxLangFeature}],[1]))
        AS_IF([test $minLangFeature -gt $maxLangFeature],   AC_MSG_ERROR([Invalid Language max: ${maxLangFeature} can not be less ${minLangFeature}],[1]))
        
        AC_LANG(C++)
        CXXMaxLanguage=03
        CXXExpLanguage=03
        AX_CHECK_COMPILE_FLAG([-std=c++11], [AC_SUBST([CXXMaxLanguage],11) AC_SUBST([StdFlag11],[-std=c++11])])
        AX_CHECK_COMPILE_FLAG([-std=c++14], [AC_SUBST([CXXMaxLanguage],14) AC_SUBST([StdFlag14],[-std=c++14])])
        AX_CHECK_COMPILE_FLAG([-std=c++17], [AC_SUBST([CXXMaxLanguage],17) AC_SUBST([StdFlag17],[-std=c++17])])
        AX_CHECK_COMPILE_FLAG([-std=c++20], [AC_SUBST([CXXMaxLanguage],20) AC_SUBST([StdFlag20],[-std=c++20])])
        AX_CHECK_COMPILE_FLAG([-std=c++23], [AC_SUBST([CXXMaxLanguage],20) AC_SUBST([StdFlag20],[-std=c++20])])
        AX_CHECK_COMPILE_FLAG([-std=c++1x], [AC_SUBST([CXXExpLanguage],11) AC_SUBST([ExpFlag11],[-std=c++1x])])
        AX_CHECK_COMPILE_FLAG([-std=c++1y], [AC_SUBST([CXXExpLanguage],14) AC_SUBST([ExpFlag14],[-std=c++1y])])
        AX_CHECK_COMPILE_FLAG([-std=c++1z], [AC_SUBST([CXXExpLanguage],17) AC_SUBST([ExpFlag17],[-std=c++1z])])
        AX_CHECK_COMPILE_FLAG([-std=c++2a], [AC_SUBST([CXXExpLanguage],20) AC_SUBST([ExpFlag20],[-std=c++2a])])
        AX_CHECK_COMPILE_FLAG([-std=c++2b], [AC_SUBST([CXXExpLanguage],23) AC_SUBST([ExpFlag20],[-std=c++2b])])

        #CXX_STD_FLAG
        #CXXSTDVER

        AS_IF(
            [test $askedLangFeature -le $CXXMaxLanguage],
            [
                AC_SUBST([CXXSTDVER], [$askedLangFeature])
                AC_SUBST([CXX_STD_FLAG], [$(eval echo "\${StdFlag${CXXSTDVER}}")])
            ],
            [AS_IF(
                [test $askedLangFeature -le $CXXExpLanguage],
                [
                    AC_SUBST([CXXSTDVER], [$askedLangFeature])
                    AC_SUBST([CXX_STD_FLAG], [$(eval echo "\${ExpFlag${CXXSTDVER}}")])
                ],
                [AC_MSG_ERROR([

Error: Need C++${askedLangFeature} but the compiler only supports ${CXXMaxLanguage} (Experimental ${CXXExpLanguage})

                    ], [1])]
            )]
        )
    ]
)
AC_DEFUN([AX_THOR_PROG_COV],
    [AS_IF(
        [test "x${COV}x" = "xx"],
        [AS_IF(
            [test "${CXX}" = "g++"],
            [AC_SUBST([COV],[gcov])],
            [AS_IF(
                [test "${CXX}" = "clang++"],
                [AC_SUBST([COV],[llvm-cov])],
                [AC_MSG_ERROR([

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
            )]
        )]
    )
    ${COV} --version 2>&1 | grep -Eo '(\d+\.)+\d+' || ${COV} --version 2>&1 | grep -Po '(\d+\.)+\d+' > /dev/null
    AS_IF(
        [test $? != 0],
        [AC_MSG_ERROR([

The coverage tool "${COV}" does not seem to be working.

         ])
        ]
    )]
)

dnl
dnl

AC_DEFUN([AX_THOR_FUNC_USE_BINARY],
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
                [AC_MSG_ERROR([

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

                ])]
            )
        ]
    )
])


