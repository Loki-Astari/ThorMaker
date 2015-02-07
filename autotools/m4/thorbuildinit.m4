
AC_DEFUN([AX_FUNC_THORBUILD],
[
    git submodule init
    git submodule update
    pushd build/third
    ./setup
    popd

])

