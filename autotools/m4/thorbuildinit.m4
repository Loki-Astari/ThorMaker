
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
    ./setup "$CXX" || echo "Failed to set up the test utilities" && exit 1
    popd

])

