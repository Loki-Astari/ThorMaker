

PLATFORM							= $(shell uname -s | sed 's/-.*//')
HARDWARE							= $(shell uname -m)
PLATHARD							= $(PLATFORM)_$(HARDWARE)
PLATFORMVER							= $(subst .,_,$(shell uname -r | sed 's/-.*//'))
SO									= $(SHARD_LIB_EXTENSOION_$(PLATFORM))
SONAME								= $(SHARD_LIB_NAME_FLAG_$(PLATFORM))
SHARED_LIB_FLAG						= $(SHARED_LIB_FLAG_$(PLATFORM))
ECHO								= $(ECHO_$(PLATFORM))
MKTEMP								= $(MKTEMP_$(PLATFORM))
CXX									= $(CXX_$(PLATFORM))
COV									= $(COV_$(PLATFORM))
COVERAGE_LIB						= $(COVERAGE_LIB_$(PLATFORM))
VERA								= $(if $(VERATOOL),$(VERATOOL), $(VERA_$(PLATFORM)))

#
COMPILER_NAME						= $(basename $(basename $(basename $(subst -,.,$(subst +,p,$(CXX))))))
COMPILER_VERSION					= $(COMPILER_CXX_$(COMPILER_NAME)_VERSION)

# If we add different compilers we can expand this with how they fetch their version
# Currently we only use gcc so we have the technique for getting the gcc version
COMPILER_CXX_gpp_VERSION			= $(subst .,_,$(basename $(shell $(CXX) -dumpversion)))


CXX_Darwin							= g++
CXX_Linux							= g++
CXX_MSYS_NT							= g++
CXX_MINGW64_NT						= g++

COV_Darwin							= gcov
COV_Linux							= gcov
COV_MSYS_NT							= gcov
COV_MINGW64_NT						= gcov

COVERAGE_LIB_Darwin					=
COVERAGE_LIB_Linux					=
COVERAGE_LIB_MSYS_NT				=
COVERAGE_LIB_MINGW64_NT				=


VERA_Darwin							= vera++
VERA_Linux							= vera++
VERA_MSYS_NT						= echo
VERA_MINGW64_NT						= echo

ECHO_COLOUR							= $(ECHO_COLOUR_$(COLOUR_STATE))
ECHO_COLOUR_ON						= -e
ECHO_Darwin							= echo $(ECHO_COLOUR)
ECHO_Linux							= echo $(ECHO_COLOUR)
ECHO_MSYS_NT						= echo
ECHO_MINGW64_NT						= echo

MKTEMP_Darwin						= mktemp -u /tmp/tmp.XXXXXXXXXX
MKTEMP_Linux						= mktemp -u
MKTEMP_MSYS_NT						= mktemp -u
MKTEMP_MINGW64_NT					= mktemp -u

SHARD_LIB_EXTENSOION_Darwin			= dylib
SHARD_LIB_EXTENSOION_Linux			= so
SHARD_LIB_EXTENSOION_MSYS_NT		= dll
SHARD_LIB_EXTENSOION_MINGW64_NT		= dll

SHARED_LIB_FLAG_Darwin				= -dynamiclib -install_name lib$*$(BUILD_EXTENSION).$(SO)
SHARED_LIB_FLAG_Linux				= -shared
SHARED_LIB_FLAG_MSYS_NT				= -shared
SHARED_LIB_FLAG_MINGW64_NT			= -shared

SHARD_LIB_NAME_FLAG_Darwin			= -install_name
SHARD_LIB_NAME_FLAG_Linux			= -soname
SHARD_LIB_NAME_FLAG_MSYS_NT			= -soname
SHARD_LIB_NAME_FLAG_MINGW64_NT		= -soname

RUNTIME_SHARED_PATH_SET				= $(RUNTIME_SHARED_PATH_SET_$(PLATFORM))
RUNTIME_SHARED_PATH_SET_Darwin		= DYLD_LIBRARY_PATH
RUNTIME_SHARED_PATH_SET_Linux		= LD_LIBRARY_PATH
RUNTIME_SHARED_PATH_SET_MSYS_NT		= LD_LIBRARY_PATH
RUNTIME_SHARED_PATH_SET_MINGW64_NT	= LD_LIBRARY_PATH

DARWIN_M1_TEST						= $(patsubst Darwin_arm64,,$(PLATHARD))
CHOICE_LIB_DIR						= $(if $(DARWIN_M1_TEST),STANDARD,M1)

DEFAULT_LIB_DIR						= $(DEFAULT_LIB_DIR_$(PLATFORM))
DEFAULT_LIB_DIR_Darwin				= $(DEFAULT_LIB_DIR_Darwin_$(CHOICE_LIB_DIR))
DEFAULT_LIB_DIR_Darwin_M1			= /opt/homebrew/lib
DEFAULT_LIB_DIR_Darwin_STANDARD		= /usr/local/lib
DEFAULT_LIB_DIR_Linux				= /usr/local/lib
DEFAULT_LIB_DIR_MSYS_NT				= /usr/local/lib
DEFAULT_LIB_DIR_MINGW64_NT			= /usr/local/lib
RUNTIME_PATHS_USED_TO_LOAD			= $(RUNTIME_PATH):$(LDLIBS_EXTERN_PATH):$(DEFAULT_LIB_DIR)

