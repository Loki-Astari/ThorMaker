
AC_DEFUN([AX_FUNC_THORBUILD],
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


AC_DEFUN([AX_FUNC_USE_YAML],
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


