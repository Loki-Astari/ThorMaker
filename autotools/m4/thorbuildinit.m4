
AC_DEFUN([AX_THOR_FUNC_BUILD],
[
    AC_CHECK_PROGS([WGET], [wget], [:])
    if test "$WGET" = :; then
        AC_MSG_ERROR([This package needs wget.])
    fi
    AC_CHECK_PROGS([UNZIP], [unzip], [:])
    if test "$UNZIP" = :; then
        AC_MSG_ERROR([This package needs unzip.])
    fi

    AC_PROG_CXX

    git submodule init
    git submodule update
    pushd build/third
    ./setup "$CXX" || AC_MSG_ERROR([Failed to set up the test utilities], [1])
    popd

])


AC_DEFUN([AX_THOR_FUNC_USE_YAML],
[
    AC_ARG_WITH(
        [yamlroot],
        AS_HELP_STRING([--with-yamlroot=<location>], [Directory of YAML_ROOT])
    )
    AC_ARG_ENABLE(
        [yaml],
        AS_HELP_STRING([--disable-yaml], [Disable yaml serializsation])
    )
    AS_IF(
        [test "x$enable_yaml" != "xno"],

        ORIG_LDFLAGS="${LDFLAGS}"
        if test "${with_yamlroot}" != ""; then
            LDFLAGS="$LDFLAGS -L$with_yamlroot/lib"
        fi

        AC_CHECK_LIB(
            [yaml],
            [yaml_parser_initialize],
            [
                AC_DEFINE([HAVE_YAML], 1, [When on Yaml Serialization code will be compiled])
                with_yamllib=-lyaml
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

AC_DEFUN(
    [AX_THOR_FUNC_LANG_FLAG],
    [
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
    ${COV} --version 2>&1 > /dev/null
    AS_IF(
        [test $? != 0],
        [AC_MSG_ERROR([

The coverage tool "${COV}" does not seem to be working.

         ])
        ]
    )]
)

