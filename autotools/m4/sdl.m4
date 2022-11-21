# Configure paths for SDL
# Source: https://raw.githubusercontent.com/libsdl-org/SDL-1.2/main/sdl.m4
# Sam Lantinga 9/21/99
# stolen from Manish Singh
# stolen back from Frank Belew
# stolen from Manish Singh
# Shamelessly stolen from Owen Taylor

# serial 2

dnl AM_PATH_SDL([MINIMUM-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]]])
dnl Test for SDL, and define SDL_CFLAGS and SDL_LIBS
dnl
AC_DEFUN([AM_PATH_SDL],
[dnl
dnl Get the cflags and libraries from the sdl2-config script
dnl
AC_ARG_WITH(sdl2-prefix,[  --with-sdl2-prefix=PFX   Prefix where SDL is installed (optional)],
            sdl2_prefix="$withval", sdl2_prefix="")
AC_ARG_WITH(sdl2-exec-prefix,[  --with-sdl2-exec-prefix=PFX Exec prefix where SDL is installed (optional)],
            sdl2_exec_prefix="$withval", sdl2_exec_prefix="")
AC_ARG_ENABLE(sdl2test, [  --disable-sdl2test       Do not try to compile and run a test SDL program],
		    , enable_sdl2test=yes)

  min_sdl2_version=ifelse([$1], ,2.0.0,$1)

  if test "x$sdl2_prefix$sdl2_exec_prefix" = x ; then
    PKG_CHECK_MODULES([SDL], [sdl2 >= $min_sdl2_version],
           [sdl2_pc=yes],
           [sdl2_pc=no])
  else
    sdl2_pc=no
    if test x$sdl2_exec_prefix != x ; then
      sdl2_config_args="$sdl2_config_args --exec-prefix=$sdl2_exec_prefix"
      if test x${SDL_CONFIG+set} != xset ; then
        SDL_CONFIG=$sdl2_exec_prefix/bin/sdl2-config
      fi
    fi
    if test x$sdl2_prefix != x ; then
      sdl2_config_args="$sdl2_config_args --prefix=$sdl2_prefix"
      if test x${SDL_CONFIG+set} != xset ; then
        SDL_CONFIG=$sdl2_prefix/bin/sdl2-config
      fi
    fi
  fi

  if test "x$sdl2_pc" = xyes ; then
    no_sdl2=""
    SDL_CONFIG="pkg-config sdl2"
  else
    as_save_PATH="$PATH"
    if test "x$prefix" != xNONE && test "$cross_compiling" != yes; then
      PATH="$prefix/bin:$prefix/usr/bin:$PATH"
    fi
    AC_PATH_PROG(SDL_CONFIG, sdl2-config, no, [$PATH])
    PATH="$as_save_PATH"
    AC_MSG_CHECKING(for SDL - version >= $min_sdl2_version)
    no_sdl2=""

    if test "$SDL_CONFIG" = "no" ; then
      no_sdl2=yes
    else
      SDL_CFLAGS=`$SDL_CONFIG $sdl2_config_args --cflags`
      SDL_LIBS=`$SDL_CONFIG $sdl2_config_args --libs`

      sdl2_major_version=`$SDL_CONFIG $sdl2_config_args --version | \
             sed 's/\([[0-9]]*\).\([[0-9]]*\).\([[0-9]]*\)/\1/'`
      sdl2_minor_version=`$SDL_CONFIG $sdl2_config_args --version | \
             sed 's/\([[0-9]]*\).\([[0-9]]*\).\([[0-9]]*\)/\2/'`
      sdl2_micro_version=`$SDL_CONFIG $sdl2_config_args --version | \
             sed 's/\([[0-9]]*\).\([[0-9]]*\).\([[0-9]]*\)/\3/'`
      if test "x$enable_sdl2test" = "xyes" ; then
        ac_save_CFLAGS="$CFLAGS"
        ac_save_CXXFLAGS="$CXXFLAGS"
        ac_save_LIBS="$LIBS"
        CFLAGS="$CFLAGS $SDL_CFLAGS"
        CXXFLAGS="$CXXFLAGS $SDL_CFLAGS"
        LIBS="$LIBS $SDL_LIBS"
dnl
dnl Now check if the installed SDL is sufficiently new. (Also sanity
dnl checks the results of sdl2-config to some extent
dnl
      rm -f conf.sdl2test
      AC_RUN_IFELSE([AC_LANG_SOURCE([[
#include <stdio.h>
#include <stdlib.h>
#include "SDL.h"

int main (int argc, char *argv[])
{
  int major, minor, micro;
  FILE *fp = fopen("conf.sdl2test", "w");

  if (fp) fclose(fp);

  if (sscanf("$min_sdl2_version", "%d.%d.%d", &major, &minor, &micro) != 3) {
     printf("%s, bad version string\n", "$min_sdl2_version");
     exit(1);
   }

   if (($sdl2_major_version > major) ||
      (($sdl2_major_version == major) && ($sdl2_minor_version > minor)) ||
      (($sdl2_major_version == major) && ($sdl2_minor_version == minor) && ($sdl2_micro_version >= micro)))
    {
      return 0;
    }
  else
    {
      printf("\n*** 'sdl2-config --version' returned %d.%d.%d, but the minimum version\n", $sdl2_major_version, $sdl2_minor_version, $sdl2_micro_version);
      printf("*** of SDL required is %d.%d.%d. If sdl2-config is correct, then it is\n", major, minor, micro);
      printf("*** best to upgrade to the required version.\n");
      printf("*** If sdl2-config was wrong, set the environment variable SDL_CONFIG\n");
      printf("*** to point to the correct copy of sdl2-config, and remove the file\n");
      printf("*** config.cache before re-running configure\n");
      return 1;
    }
}

]])], [], [no_sdl2=yes], [echo $ac_n "cross compiling; assumed OK... $ac_c"])
        CFLAGS="$ac_save_CFLAGS"
        CXXFLAGS="$ac_save_CXXFLAGS"
        LIBS="$ac_save_LIBS"
      fi
    fi
    if test "x$no_sdl2" = x ; then
      AC_MSG_RESULT(yes)
    else
      AC_MSG_RESULT(no)
    fi
  fi
  if test "x$no_sdl2" = x ; then
     ifelse([$2], , :, [$2])
  else
     if test "$SDL_CONFIG" = "no" ; then
       echo "*** The sdl2-config script installed by SDL could not be found"
       echo "*** If SDL was installed in PREFIX, make sure PREFIX/bin is in"
       echo "*** your path, or set the SDL_CONFIG environment variable to the"
       echo "*** full path to sdl2-config."
     else
       if test -f conf.sdl2test ; then
        :
       else
          echo "*** Could not run SDL test program, checking why..."
          CFLAGS="$CFLAGS $SDL_CFLAGS"
          CXXFLAGS="$CXXFLAGS $SDL_CFLAGS"
          LIBS="$LIBS $SDL_LIBS"
          AC_LINK_IFELSE([AC_LANG_PROGRAM([[
#include <stdio.h>
#include "SDL.h"

int main(int argc, char *argv[])
{ return 0; }
#undef  main
#define main K_and_R_C_main
]], [[ return 0; ]])],
        [ echo "*** The test program compiled, but did not run. This usually means"
          echo "*** that the run-time linker is not finding SDL or finding the wrong"
          echo "*** version of SDL. If it is not finding SDL, you'll need to set your"
          echo "*** LD_LIBRARY_PATH environment variable, or edit /etc/ld.so.conf to point"
          echo "*** to the installed location  Also, make sure you have run ldconfig if that"
          echo "*** is required on your system"
	  echo "***"
          echo "*** If you have an old version installed, it is best to remove it, although"
          echo "*** you may also be able to get things to work by modifying LD_LIBRARY_PATH"],
        [ echo "*** The test program failed to compile or link. See the file config.log for the"
          echo "*** exact error that occured. This usually means SDL was incorrectly installed"
          echo "*** or that you have moved SDL since it was installed. In the latter case, you"
          echo "*** may want to edit the sdl2-config script: $SDL_CONFIG" ])
          CFLAGS="$ac_save_CFLAGS"
          CXXFLAGS="$ac_save_CXXFLAGS"
          LIBS="$ac_save_LIBS"
       fi
     fi
     SDL_CFLAGS=""
     SDL_LIBS=""
     ifelse([$3], , :, [$3])
  fi
  AC_SUBST(SDL_CFLAGS)
  AC_SUBST(SDL_LIBS)
  rm -f conf.sdl2test
])
