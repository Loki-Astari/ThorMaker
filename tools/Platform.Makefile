

PLATFORM					= $(shell uname -s | sed 's/-.*//')
HARDWARE					= $(shell uname -m)
PLATHARD					= $(PLATFORM)_$(HARDWARE)
PLATFORMVER					= $(subst .,_,$(shell uname -r | sed 's/-.*//'))
SO							= $(SHARD_LIB_EXTENSOION_$(PLATFORM))
SONAME						= $(SHARD_LIB_NAME_FLAG_$(PLATFORM))
SHARED_LIB_FLAG				= $(SHARED_LIB_FLAG_$(PLATFORM))
ECHO						= $(ECHO_$(PLATFORM))
MKTEMP						= $(MKTEMP_$(PLATFORM))
CXX							= $(CXX_$(PLATFORM))
COV							= $(COV_$(PLATFORM))
COVERAGE_LIB				= $(COVERAGE_LIB_$(PLATFORM))
VERA						?= $(if $(VERATOOL),$(VERATOOL), $(VERA_$(PLATFORM)))

#
COMPILER_NAME				= $(basename $(basename $(basename $(subst -,.,$(subst +,p,$(CXX))))))
COMPILER_VERSION			= $(COMPILER_CXX_$(COMPILER_NAME)_VERSION)

# If we add different compilers we can expand this with how they fetch their version
# Currently we only use gcc so we have the technique for getting the gcc version
COMPILER_CXX_gpp_VERSION	= $(subst .,_,$(basename $(shell $(CXX) -dumpversion)))

CXX_Darwin					= g++
CXX_Linux					= g++
CXX_CYGWIN_NT				= g++

COV_Darwin					= gcov
COV_Linux					= gcov
COV_CYGWIN_NT				= gcov

COVERAGE_LIB_Darwin			=
COVERAGE_LIB_Linux			=
COVERAGE_LIB_CYGWIN_NT		= -lgcov


VERA_Darwin					= vera++
VERA_Linux					= vera++
VERA_CYGWIN_NT				= vera++

ECHO_Darwin					= echo -e
ECHO_Linux					= echo -e
ECHO_CYGWIN_NT				= echo -e

MKTEMP_Darwin				= mktemp -u /tmp/tmp.XXXXXXXXXX
MKTEMP_Linux				= mktemp -u
MKTEMP_CYGWIN_NT			= mktemp -u

SHARD_LIB_EXTENSOION_Darwin	= dylib
SHARD_LIB_EXTENSOION_Linux	= so
SHARD_LIB_EXTENSOION_CYGWIN_NT	= dll

SHARED_LIB_FLAG_Darwin		= -dynamiclib -install_name lib$*$(BUILD_EXTENSION).$(SO)
SHARED_LIB_FLAG_Linux		= -shared
SHARED_LIB_FLAG_CYGWIN_NT	= -shared

SHARD_LIB_NAME_FLAG_Darwin	= -install_name
SHARD_LIB_NAME_FLAG_Linux	= -soname

RUNTIME_SHARED_PATH_SET				= $(RUNTIME_SHARED_PATH_SET_$(PLATFORM))
RUNTIME_SHARED_PATH_SET_Darwin		= DYLD_LIBRARY_PATH
RUNTIME_SHARED_PATH_SET_Linux		= LD_LIBRARY_PATH
RUNTIME_SHARED_PATH_SET_CYGWIN_NT	= PATH

#STANDARD_LIB_DIR					= /usr/local/lib
#DARWIN_M1_LIB_DIR					= /opt/homebrew/lib
DARWIN_M1_TEST						= $(patsubst Darwin_arm64,,$(PLATHARD))
CHOICE_LIB_DIR						= $(if $(DARWIN_M1_TEST),STANDARD,M1)

DEFAULT_LIB_DIR1					= $($(CHOICE_LIB_DIR)_LIB_DIR)
DEFAULT_LIB_DIR						= $(DEFAULT_LIB_DIR_$(PLATFORM))
DEFAULT_LIB_DIR_Darwin				= $(DEFAULT_LIB_DIR_Darwin_$(CHOICE_LIB_DIR))
DEFAULT_LIB_DIR_Darwin_M1			= /opt/homebrew/lib
DEFAULT_LIB_DIR_Darwin_STANDARD		= /usr/local/lib
DEFAULT_LIB_DIR_Linux				= /usr/local/lib
DEFAULT_LIB_DIR_CYGWIN_NT			= /cygdrive/c/cygwin64/usr/x86_64-w64-mingw32/sys-root/mingw/bin/
RUNTIME_PATHS_USED_TO_LOAD			= $(RUNTIME_PATH):$(LDLIBS_EXTERN_PATH):$(DEFAULT_LIB_DIR)

