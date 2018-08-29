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
AC_DEFUN([AX_THOR_FUNC_USE_VERA],
[
    AC_ARG_ENABLE(
        [vera],
        AS_HELP_STRING([--disable-vera], [Disable vera. Disable Static analysis of source.])
    )

    VERATOOL="";
    AS_IF(
        [test "x$enable_vera" == "xno"],
        [
            VERATOOL='echo "Disabled Static Analysis" ||';
        ],
        [
            VERATOOL='vera++';
            ./build/third/vera-install
            AC_CHECK_PROGS([TestVera], [vera++], [:], ${PATH}:./build/bin)
            AS_IF(
                [test "$TestVera" == ":"],
                [
                    AC_MSG_ERROR([

By default the build tools use vera++ for static analysis of C++ code to ensure the project
maintains a consistent style when people add pull requests. The configuration tests have
detected that "vera++" (the static analysis tool) is not currently installed.


])
                ],
                [
                ]
            )
        ]
    )
    AC_SUBST([VERATOOL], [${VERATOOL}])
    AX_THOR_LIB_SELECT
])

AC_DEFUN([AX_THOR_FUNC_BUILD],
[
    AC_CHECK_PROGS([UNZIP], [unzip], [:])
    if test "$UNZIP" = :; then
        AC_MSG_ERROR([The build tools needs unzip. Please install it.])
    fi
    AS_IF(
        [test "x${enable_vera}" != "xno"],
        [
            AC_CHECK_PROGS([CMAKE], [cmake], [:])
            if test "$CMAKE" = :; then
                AC_MSG_ERROR([The build tools needs cmake. Please install it.])
            fi
            AC_CHECK_LIB([tcl],    [Tcl_Init], [], [AC_MSG_ERROR([The build tools needs libtcl. Please install it.])])
            AC_CHECK_LIB([tk],     [Tk_Init],  [], [AC_MSG_ERROR([The build tools needs libtk. Please install it.])])
            AX_BOOST_BASE([1.54], [], [AC_MSG_ERROR([The build tools needs libboost. Please install it.])])
            AX_BOOST_PYTHON
            if test "x$BOOST_PYTHON_LIB" = "x"; then
                AC_MSG_ERROR([The build tools needs boost-python. Please install it.])
            fi
        ]
    )

    AC_PROG_CXX


    git submodule update --init --recursive

    AX_THOR_FUNC_USE_VERA

    pushd build/third
    ./setup "$CXX" || AC_MSG_ERROR([Failed to set up the test utilities], [1])
    popd

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
    AC_SUBST(thors$1_ROOT_LIBDIR)
    AC_SUBST(thors$1_ROOT_INCDIR)
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

        AC_MSG_NOTICE([Got HERE])
        AC_MSG_NOTICE([Name: $1])
        AC_MSG_NOTICE([With: ${with_Thors$1root}])

        if test "${with_Thors$1root}" == ""; then
            declare with_Thors$1root="/usr/local"
        fi
        ORIG_LDFLAGS="${LDFLAGS}"
        LDFLAGS="$LDFLAGS -L${with_Thors$1root}/lib"
        AC_MSG_NOTICE([LDFLAGS: ${LDFLAGS}])
        AC_MSG_NOTICE([LIB: $4])
        AC_MSG_NOTICE([Meth: $5])

        AC_CHECK_LIB(
            [$4],
            [$5],
            [
                AC_DEFINE([HAVE_Thors$1], 1, [When on code that uses Thors$1 will be compiled.])
                thors$1_ROOT_LIBDIR=-L${with_Thors$1root}/lib
                thors$1_ROOT_INCDIR=-I${with_Thors$1root}/include
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

                ], [1])]
        )

        LDFLAGS="${ORIG_LDFLAGS}"
    )
])
AC_DEFUN([AX_THOR_FUNC_USE_THORS_LIB_SQL],
[
    AX_THOR_FUNC_USE_THORS_LIB(SQL, $1, ThorSQL, [ThorSQL$1D], [_ZN10ThorsAnvil3SQL3Lib15ConnectionProxyD2Ev], [https://github.com/Loki-Astari/ThorsSQL])
])
AC_DEFUN([AX_THOR_FUC_USE_THORS_LIB_SERIALIZE],
[
    AX_THOR_FUNC_USE_THORS_LIB(Serialize, $1, ThorSerialize, [ThorSerialize$1D], [_ZN10ThorsAnvil9Serialize10JsonParser12getNextTokenEv], [https://github.com/Loki-Astari/ThorsSerializer])
])
AC_DEFUN([AX_THOR_FUNC_USE_YAML],
[
    AC_ARG_WITH(
        [yamlroot],
        AS_HELP_STRING([--with-yamlroot=<location>], [Directory of YAML_ROOT])
    )
    AC_ARG_ENABLE(
        [yaml],
        AS_HELP_STRING([--disable-yaml], [Disable yaml serialization])
    )
    AS_IF(
        [test "x$enable_yaml" != "xno"],

        if test "${with_yamlroot}" == ""; then
            with_yamlroot="/usr/local"
        fi
        ORIG_LDFLAGS="${LDFLAGS}"
        LDFLAGS="$LDFLAGS -L$with_yamlroot/lib"

        AC_CHECK_LIB(
            [yaml],
            [yaml_parser_initialize],
            [
                AC_DEFINE([HAVE_YAML], 1, [When on Yaml Serialization code will be compiled])
                AC_SUBST([yaml_ROOT_DIR], [$with_yamlroot])
                AC_SUBST([yaml_ROOT_LIB], [yaml])
            ],
            [AC_MSG_ERROR([
 
Error: Could not find libyaml

You can solve this by installing libyaml
    see http://pyyaml.org/wiki/LibYAML

Alternately specify install location with:
    --with-yamlroot=<location of yaml installation>

If you do not want to use yaml serialization then it
can be disabled with:
    --disable-yaml

                ], [1])]
        )

        LDFLAGS="${ORIG_LDFLAGS}"
    )
])

AC_DEFUN([AX_THOR_FUNC_USE_EVENT],
[
    AC_ARG_WITH(
        [eventroot],
        AS_HELP_STRING([--with-eventroot=<location>], [Directory of EVENT_ROOT])
    )
    if test "${with_eventroot}" == ""; then
        with_eventroot="/usr/local"
    fi
    ORIG_LDFLAGS="${LDFLAGS}"
    LDFLAGS="$LDFLAGS -L$with_eventroot/lib"

    AC_CHECK_LIB(
        [event],
        [event_dispatch],
        [
            AC_DEFINE([HAVE_EVENT], 1, [We have found libevent library])
            AC_SUBST([event_ROOT_DIR], [$with_eventroot])
            AC_SUBST([event_ROOT_LIB], [event])
        ],
        [AC_MSG_ERROR([

Error: Could not find libevent

You can solve this by installing libevent
see http://libevent.org/

If libevent is not installed in the default location (/usr/local) then you will need to specify its location.
--with-eventroot=<location of event installation>

            ], [1])]
    )

    LDFLAGS="${ORIG_LDFLAGS}"
])

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
        minLangFeature=$1
        AS_IF([test "$2" = ""], [maxLangFeature=17], [maxLangFeature=$2])
        AS_IF([test $minLangFeature -gt $maxLangFeature], AC_MSG_ERROR([Invalid Language Value],[1]))
        
        AC_LANG(C++)
        CXXMaxLanguage=03
        CXXExpLanguage=03
        AX_CHECK_COMPILE_FLAG([-std=c++11], [AC_SUBST([CXXMaxLanguage],11) AC_SUBST([StdFlag11],[-std=c++11])])
        AX_CHECK_COMPILE_FLAG([-std=c++14], [AC_SUBST([CXXMaxLanguage],14) AC_SUBST([StdFlag14],[-std=c++14])])
        AX_CHECK_COMPILE_FLAG([-std=c++17], [AC_SUBST([CXXMaxLanguage],17) AC_SUBST([StdFlag17],[-std=c++17])])
        AX_CHECK_COMPILE_FLAG([-std=c++1x], [AC_SUBST([CXXExpLanguage],11) AC_SUBST([ExpFlag11],[-std=c++1x])])
        AX_CHECK_COMPILE_FLAG([-std=c++1y], [AC_SUBST([CXXExpLanguage],14) AC_SUBST([ExpFlag14],[-std=c++1y])])
        AX_CHECK_COMPILE_FLAG([-std=c++1z], [AC_SUBST([CXXExpLanguage],17) AC_SUBST([ExpFlag17],[-std=c++1z])])

        #CXX_STD_FLAG
        #CXXSTDVER

        AS_IF(
            [test $minLangFeature -le $CXXMaxLanguage],
            [
                AS_IF(
                    [test $maxLangFeature -le $CXXMaxLanguage],
                    [AC_SUBST([CXXSTDVER], [$maxLangFeature])],
                    [AC_SUBST([CXXSTDVER], [$CXXMaxLanguage])]
                )
                AC_SUBST([CXX_STD_FLAG], [$(eval echo "\${StdFlag${CXXSTDVER}}")])
            ],
            [AS_IF(
                [test $minLangFeature -le $CXXExpLanguage],
                [
                    AS_IF(
                        [test $maxLangFeature -le $CXXExpLanguage],
                        [AC_SUBST([CXXSTDVER], [$maxLangFeature])],
                        [AC_SUBST([CXXSTDVER], [$CXXExpLanguage])]
                    )
                    AC_SUBST([CXX_STD_FLAG], [$(eval echo "\${ExpFlag${CXXSTDVER}}")])
                ],
                [AC_MSG_ERROR([

Error: Need C++${minLangFeature} but the compiler only supports ${CXXMaxLanguage} (Experimental ${CXXExpLanguage})

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


