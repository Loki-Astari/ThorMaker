# =============================================================================
# core/variables.mk — shared variables, flags and paths
#
# This is the heart of the per-build variable setup: install prefixes, the
# full CXXFLAGS / LDLIBS / LDFLAGS construction, the source-file wildcards
# (CPP_SRC, OBJ, DEP, GCOV_*), the mock-header plumbing, build-mode
# optimizer flags, and the TARGET_ALL expansion from the project's TARGET.
#
# Requires: THORSANVIL_ROOT BUILD_ROOT BASE                    (entry point)
#           PLATFORM SO ECHO MKTEMP CXX etc.                   (core/platform.mk)
#           ECHO MODE_TEXT_COLOR etc.                          (core/colour.mk)
#           <lib>_ISTHOR flags                                 (core/thors-anvil-libs.mk)
#           TARGET (set by project Makefile before include)
# Defines:  LOCAL_ROOT PATH INSTALL_ACTIVE PREFIX_*
#           TESTNAME COV_LONG_FLAG TEST_ONLY NOCOVERAGE
#           TARGET_ALL TARGET_ITEM APP_SRC APP_HEAD CPP_*
#           LEX_SRC GPERF_SRC YACC_SRC TMP_SRC TMP_HDR SRC DEP HEAD OBJ
#           VERA_SRC GCOV_* DEFER_OBJ*
#           LDLIBS CXXFLAGS CPPFLAGS LDFLAGS ALL_LDLIBS
#           VERBOSE CXXSTDVER TARGET_MODE COVERAGE_TARGET PARALLEL
#           WARNING_FLAGS ENVIRONMENT_FLAGS COMPILER_SPECIFIC_FLAGS
#           LANGUAGE_SPECIFIC_FLAGS THORSLINKDIRS findfullpath expand*
#           THORSANVIL_FLAGS THORSANVIL_LIBS THORSANVIL_STATICLOADALL
#           TEST_FLAGS TEST_LIBS TEST_PATH OPTIMIZER_FLAGS*
#           MOCK_HEADERS MOCK_FILES MOCK_OBJECT
#           BUILD_SUFFIX BUILD_EXTENSION RUNTIME_PATH DEFER_NAME
# Exports:  FILEDIR DISABLE_CONTROL_CODES THORSANVIL_ROOT CXXSTDVER PREFIX
#           BASE TARGET_MODE TEST_STATE LDLIBS_EXTERN_BUILD UNITTEST_CXXFLAGS
#           LDLIBS_FILTER LINK_LIBS EXLDLIBS LOADLIBES
# Goals:    (none)
# =============================================================================

LOCAL_ROOT		?= $(shell pwd)

export PATH := $(BUILD_ROOT)/bin:$(PATH)

INSTALL_ACTIVE	?= NO

PREFIX?=$(BUILD_ROOT)
PREFIX_BIN?=$(BUILD_ROOT)/bin
PREFIX_LIB?=$(BUILD_ROOT)/lib
PREFIX_INC?=$(BUILD_ROOT)/include
PREFIX_MAN?=$(BUILD_ROOT)/share/man
PREFIX_CONFIG?=$(BUILD_ROOT)/etc/
PREFIX_DEFER_OBJ?=$(BUILD_ROOT)/dobj
PREFIX_DEFER_LIB?=$(BUILD_ROOT)/dlib

ifeq ($(INSTALL_ACTIVE),YES)
PREFIX=${prefix}
PREFIX_BIN=${bindir}
PREFIX_LIB=${libdir}
PREFIX_INC=${includedir}
PREFIX_MAN=${mandir}
PREFIX_CONFIG=${prefix}/etc
endif

LINE_WIDTH			?= 110
COVERAGE_REQUIRED	?= 80
COVERAGE_REQUIRED_TEST = $(if $(filter-out MSYS_NT, $(filter-out MINGW64_NT, $(PLATFORM))), $(COVERAGE_REQUIRED), 0)

#
# Look in core/platform.mk
# These value may have platform specific values.
# They are defined here as a last resort (i.e. default values)
#
DISABLE_CONTROL_CODES	?= FALSE
FILEDIR					?=

YACC					?= bison
LEX						?= flex
GPERF					?= gperf --ignore-case
CP						?= cp
LNSOFT			?= ln -f -s
MKDIR			?= mkdir
RMDIR			?= rmdir

VERA_ROOT		= --root=$(THORSANVIL_ROOT)/build/vera-plusplus
MAKEFLAGS 		+= --silent

TESTNAME		?= *

#
# Pass-through variables for recursive $(MAKE) invocations.
# Listing them here avoids having to repeat them on every sub-make command line.
# Per-call overrides (TARGET_MODE, BASE, TEST_STATE, INSTALL_ACTIVE, LINK_LIBS,
# EXLDLIBS, LOADLIBES, NAME, TARGET_DST, TARGET_OVERRIDE, PARALLEL_BUILD, Ignore)
# still go on the command line — command-line values outrank env, so they win
# over the exported value where the child needs a different value.
export FILEDIR DISABLE_CONTROL_CODES THORSANVIL_ROOT CXXSTDVER PREFIX
export BASE TARGET_MODE TEST_STATE
export LDLIBS_EXTERN_BUILD UNITTEST_CXXFLAGS LDLIBS_FILTER
export LINK_LIBS EXLDLIBS LOADLIBES

#
# This is obviously not working
# Need to look at this
COV_LONG_FLAG					= $(COV_LONG_FLAG_$(PLATFORM))
COV_LONG_FLAG_Linux				= --long-file-names
COV_LONG_FLAG_Darwin			= -l

#
# Define in project file to "YES" to prevent any installation work
# These projects will be built locally only and not pushed $(BUILD_ROOT)
TEST_ONLY		?= NO

#
# Add Files(without extension) that you do not want coverage metrics for
NOCOVERAGE		+= %.lex %.tab

THOR_TARGETLIBS				?= slib
TARGET_GENERIC_LIB			= $(patsubst %.lib, %, $(filter %.lib, $(TARGET)))
TARGET_GENERIC_EXPAND		= $(foreach exp, $(THOR_TARGETLIBS), $(foreach lib, $(TARGET_GENERIC_LIB), $(lib).$(exp)))
TARGET_ALL					= $(filter-out %.lib, $(TARGET)) $(TARGET_GENERIC_EXPAND)
TARGET_ITEM					= $(if $(TARGET_OVERRIDE), $(TARGET_OVERRIDE), $(TARGET_ALL))

APP_SRC						= $(filter %.cpp,$(patsubst %.prog,%.cpp,$(TARGET_ALL)))
APP_HEAD					= $(filter %.h,$(patsubst %.prog,%.h,$(TARGET_ALL)))
CPP_SRC						:= $(filter-out %.lex.cpp %.tab.cpp %.gperf.cpp $(APP_SRC),$(wildcard *.cpp))
CPP_HDR						:= $(filter-out %.lex.h   %.tab.h %.tab.hpp  %.gperf.h             ,$(wildcard *.h *.hpp))
CPP_TDR						:= $(wildcard *.tpp)
CPP_SOURCE					:= $(wildcard *.source)
CPP_FILES					= $(CPP_SRC) $(CPP_HDR) $(CPP_TDR) $(CPP_SOURCE)
LEX_SRC						:= $(wildcard *.l)
GPERF_SRC					:= $(wildcard *.gperf)
YACC_SRC					:= $(wildcard *.y)
TMP_SRC						= $(patsubst %.y,%.tab.cpp,$(YACC_SRC)) $(patsubst %.l,%.lex.cpp,$(LEX_SRC))
TMP_HDR						= $(patsubst %.y,%.tab.h,$(YACC_SRC)) $(patsubst %.l,%.lex.h,$(LEX_SRC)) $(patsubst %.y,%.tab.hpp,$(YACC_SRC)) $(patsubst %.l,%.lex.hpp,$(LEX_SRC))
SRC							= $(TMP_SRC) $(patsubst %.gperf,%.gperf.cpp,$(GPERF_SRC)) $(CPP_SRC)
DEP							= $(patsubst %.cpp, makedependency/%.d, $(filter-out unittest.cpp,$(SRC)))
HEAD						:= $(filter-out $(EXCLUDE_HEADERS), $(wildcard *.h *.tpp *.hpp)) $(EXTRA_HEADERS)
OBJ							= $(patsubst %.cpp,$(TARGET_MODE)/%.o,$(SRC))
VERA_SRC					:= $(filter-out $(TEST_IGNORE) $(TMP_SRC), $(CPP_SRC) $(APP_SRC)) $(filter-out %Config.h $(TEST_IGNORE) $(TMP_HDR), $(CPP_HDR)) $(wildcard *.tpp)
GCOV_OBJ					= $(filter-out coverage/main.o,$(OBJ)) $(MOCK_OBJECT)
GCOV_BASIC_SRC				:= $(patsubst coverage/%.o, coverage/%.cpp.gcov, $(filter-out $(MOCK_OBJECT) $(TMP_SRC) $(TMP_HDR) $(APP_SRC) ,$(GCOV_OBJ))) $(patsubst %.tpp,coverage/%.tpp.gcov, $(wildcard *.tpp))
GCOV_BASIC_HEAD				:= $(patsubst %, coverage/%.gcov, $(filter-out $(APP_HEAD) %Config.h,$(wildcard *.h *.hpp)))
GCOV_SRC					= $(filter-out $(foreach nocoverage,$(TEST_IGNORE),coverage/$(nocoverage).gcov), $(GCOV_BASIC_SRC))
GCOV_HEAD					= $(filter-out $(foreach nocoverage,$(TEST_IGNORE),coverage/$(nocoverage).gcov), $(GCOV_BASIC_HEAD))
GCOV_LIBOBJ					= $(if $(GCOV_OBJ),-lobject)
DEFER_OBJDIR				= $(foreach lib, $(DEFER_LIBS), $(PREFIX_DEFER_OBJ)/$(lib)/$(TARGET_MODE))
DEFER_OBJ					:= $(foreach dir, $(DEFER_OBJDIR), $(wildcard $(dir)/*.o))

CONAN_LDLIBS				= -ldl
EXTRA_LDLIBS				= $($(THOR_CONAN_ENABLE)_LDLIBS)


NOTHING						:=
SPACE						:=$(NOTHING) $(NOTHING)
LDLIBS_EXTERN_BUILD_USE		= $(filter-out $(LDLIBS_FILTER), $(LDLIBS_EXTERN_BUILD))
HEADERONLY_LIBS_1			= $(UNITTEST_LDLIBS_HEADERONLY)
HEADERONLY_LIBS				= $(HEADERONLY_LIBS_$(HEADER_ONLY))
CXX_EXTERN_HEADER_ONLY		= $(foreach lib, $(LDLIBS_EXTERN_BUILD_USE), $(if $($(lib)HeaderOnly_ROOT_DIR), -I$($(lib)HeaderOnly_ROOT_DIR)))
LDLIBS_EXTERN_LIB_LOC		= $(foreach lib, $(LDLIBS_EXTERN_BUILD_USE), $(if $($(lib)_ROOT_DIR), -L$($(lib)_ROOT_DIR)/lib))
LDLIBS_EXTERN_INC_LOC		= $(foreach lib, $(LDLIBS_EXTERN_BUILD_USE), $(if $($(lib)_ROOT_DIR), -I$($(lib)_ROOT_DIR)/include))
LDLIBS_EXTERN_SHARE			= $(foreach lib, $(LDLIBS_EXTERN_BUILD_USE), $(foreach alib, $($(lib)_ROOT_LIB), -l$(alib)$(if $($(lib)_ISTHOR),$(BUILD_EXTENSION))))
LDLIBS_EXTERN_PATH			= $(subst $(SPACE),:,$(strip $(foreach lib, $(LDLIBS_EXTERN_BUILD_USE), $(if $($(lib)_ROOT_DIR),$($(lib)_ROOT_DIR)/lib))))
LDLIBS_EXTERN_RPATH			+=$(if $(LDLIBS_EXTERN_PATH),export RPATH=$(LDLIBS_EXTERN_PATH);)
LDLIBS						+= $(LDLIBS_EXTERN_LIB_LOC) $(LDLIBS_EXTERN_SHARE) $(EXLDLIBS) $(EXTRA_LDLIBS) $(HEADERONLY_LIBS)
CXXFLAGS					+= $(LDLIBS_EXTERN_INC_LOC) $(CXX_EXTERN_HEADER_ONLY) $(BOOST_CPPFLAGS) $(TEST_PATH) $(UNITTEST_CXXFLAGS)
CPPFLAGS					+= $(BOOST_CPPFLAGS)
LDFLAGS						+= $(BOOST_LDFLAGS)
LDLIBS_EXTERN_BUILD_FILT	= $(foreach lib, $(1), $(patsubst -l%, %, $(lib)))

GCOV_REPORT					= $(patsubst coverage/%.gcov, %_report_coverage, $(GCOV_SRC)) $(patsubst coverage/%.gcov, %_report_coverage, $(GCOV_HEAD))

#
# Set to On to see debug output
# On:		Full message all the time
# Off:		Nice messages easy to read
# NONE:		Turn of messages and build in parallel
VERBOSE						?=	NONE
#
# Set to 03 for old C++
CXXSTDVER					?=  11
#
# By default build debug when in a directory
TARGET_MODE					?=	debug
COVERAGE_TARGET				?= COVERAGE_$(subst -,,$(notdir $(shell pwd)))
PARALLEL					= $(PARALLEL_$(VERBOSE))
PARALLEL_NONE				=

#
# Warning flags turned off for test suite.
# As long as the main code compiles without warnings


ENVIRONMENT_FLAGS			=	$(PLATFORM_SPECIFIC_FLAGS) $(COMPILER_SPECIFIC_FLAGS)  $(LANGUAGE_SPECIFIC_FLAGS)


#
# Having problems with unreachable code being reported in the system header files
# Had to turn this on to make the code compile with no errors.
COMPILER_SPECIFIC_FLAGS		= -Wno-unreachable-code


#
# Bug in gcc
# The macro __cplusplus is always 1 so you can detect the language version at the pre-processor level.
# So we defined the flag THOR_USE_CPLUSPLUS11 to be used instead
LANGUAGE_SPECIFIC_FLAGS		= -DTHOR_USE_CPLUSPLUS$(CXXSTDVER)


EXTRA_FILE_WARNING_FLAGS	=   $($(THOR_CONAN_ENABLE)_FILE_WARNING_FLAGS)
WARNING_FLAGS				=	$(WARNING_FLAGS_$(TEST_STATE)) $(WARNING_FLAGS_$(TARGET_MODE)) $(FILE_WARNING_FLAGS) $(EXTRA_FILE_WARNING_FLAGS)
WARNING_FLAGS_				=	-Wall -Wextra -Werror -Wstrict-aliasing $(THORSANVIL_ANSI) -pedantic -Wunreachable-code -Wno-long-long -Wdeprecated -Wdeprecated-declarations
WARNING_FLAGS_				+=	-Wmissing-braces -Wmissing-field-initializers -Wunused-variable
WARNING_FLAGS_				+= $(INCONSISTENT_MISSING_OVERRIDE) $(DELETE_NON_ABSTRACT_NON_VIRTUAL_DTOR) $(DELETE_NON_VIRTUAL_DTOR) $(NO_DEPRECATED_REGISTER_TEST) $(LITERAL_WARNING)

THORSLINKDIRS				=	$(PREFIX_LIB) $(filter -L%, %, $(LDFLAGS)) ${libdir}
findfullpath				=	$(firstword $(foreach dir, $(1), $(realpath $(dir)/$(2))))
expand						=	$(foreach lib, $(1), -l$(lib)$(BUILD_EXTENSION))
expandStatic				=	$(foreach lib, $(1), $(call findfullpath, $(THORSLINKDIRS),lib$(lib)$(BUILD_EXTENSION).a))
expandFlag					=   $(foreach flag, $(1), $(flag))
THORSANVIL_FLAGS			=	$(THOR_STD_INCLUDES) -I$(PREFIX_INC)
THORSANVIL_LIBS				=	-L$(PREFIX_LIB) $(call expand,$(LINK_LIBS))
THORSANVIL_STATICLOADALL	=   $(if $(LINK_SLIBS), $(THOR_STATIC_LOAD_FLAG) $(call expandStatic,$(LINK_SLIBS)) $(THOR_STATIC_NOLOAD_FLAG))


TEST_FLAGS					=	$(TEST_FLAGS_$(TEST_STATE))
TEST_LIBS					=	$(TEST_LIBS_$(TEST_STATE)) -fprofile-arcs -ftest-coverage -lpthread
TEST_FLAGS_on				=	-I..
TEST_LIBS_on				=	-L../coverage -L$(PREFIX_DEFER_LIB) -L$(THORSANVIL_ROOT)/build/lib $(GCOV_LIBOBJ_PASS) -lgtest -lgtest_main
TEST_PATH_coverage			=	-I$(LOCAL_ROOT)
TEST_PATH					=	$(TEST_PATH_$(TARGET_MODE))


OPTIMIZER_FLAGS				=	$(OPTIMIZER_FLAGS_DISP) $(OPTIMIZER_FLAGS_HIDE)
OPTIMIZER_FLAGS_DISP		=	$(OPTIMIZER_FLAGS_DISP_$(TARGET_MODE))
OPTIMIZER_FLAGS_HIDE		=	$(OPTIMIZER_FLAGS_HIDE_$(TARGET_MODE))
OPTIMIZER_LIBS				=	$(OPTIMIZER_LIBS_$(TARGET_MODE))
OPTIMIZER_FLAGS_DISP_debug		=	-g
OPTIMIZER_FLAGS_DISP_release	=	-O3
OPTIMIZER_FLAGS_DISP_coverage	=	-D$(COVERAGE_TARGET) -DTHOR_COVERAGE
OPTIMIZER_FLAGS_HIDE_coverage	=	-g -fprofile-arcs -ftest-coverage -DCOVERAGE_TEST $(NO_UNUSED_PRIVATE_FIELD_TEST)
OPTIMIZER_FLAGS_HIDE_test		=	-g -fprofile-arcs -ftest-coverage -DCOVERAGE_TEST $(NO_UNUSED_PRIVATE_FIELD_TEST)
OPTIMIZER_FLAGS_HIDE_profile	=	-g -pg -DPROFILE_TEST


#
# Deliberately use C++ compiler for all compilation.
CC							=	$(CXX)
CXXFLAGS					+=	-fPIC $(WARNING_FLAGS) $(THORSANVIL_FLAGS) -isystem $(PREFIX_INC3RD) $(TEST_FLAGS) $(OPTIMIZER_FLAGS) $(ENVIRONMENT_FLAGS) $(CXX_STD_FLAG)

ALL_LDLIBS					+=	-L $(PREFIX_LIB3RD) $(TEST_LIBS) $(OPTIMIZER_LIBS) $(THORSANVIL_LIBS)

MOCK_HEADER_INCLUDES_FILES	:=	$(strip $(wildcard MockHeaderInclude.h) $(wildcard test/MockHeaderInclude.h))
MOCK_HEADER_INCLUDES		=   $(if $(MOCK_HEADER_INCLUDES_FILES), -include $(MOCK_HEADER_INCLUDES_FILES))
MOCK_HEADERS_coverage		=	$(MOCK_HEADER_INCLUDES) -include $(BASE)/coverage/MockHeaders.h
MOCK_HEADERS_release		=   -DMOCK_FUNC\(x\)=::x -DMOCK_TFUNC\(x\)=::x
MOCK_HEADERS_debug			=   -DMOCK_FUNC\(x\)=::x -DMOCK_TFUNC\(x\)=::x
MOCK_FILES_coverage			=	$(BASE)/coverage/MockHeaders.h $(BASE)/coverage/MockHeaders.cpp
MOCK_OBJECT_coverage		=	$(BASE)/coverage/MockHeaders.o
MOCK_HEADERS				=	$(MOCK_HEADERS_$(TARGET_MODE))
MOCK_FILES					=	$(MOCK_FILES_$(TARGET_MODE))
MOCK_OBJECT					=	$(MOCK_OBJECT_$(TARGET_MODE))


PREFIX						?=	$(BUILD_ROOT)
PREFIX_BIN					?=	$(PREFIX)/bin
PREFIX_LIB					?=	$(PREFIX)/lib
PREFIX_INC					?=	$(PREFIX)/include
PREFIX_INC3RD				?=	$(THORSANVIL_ROOT)/build/3rd/include
PREFIX_LIB3RD				?=	$(THORSANVIL_ROOT)/build/3rd/lib
PREFIX_BIN3RD				?=	$(THORSANVIL_ROOT)/build/3rd/bin
BUILD_SUFFIX				=	$(BUILD_EXTENSION_TYPE_$(TARGET_MODE))
BUILD_EXTENSION				=	$(CXXSTDVER)$(BUILD_SUFFIX)
BUILD_EXTENSION_TYPE_debug		=	D
BUILD_EXTENSION_TYPE_coverage	=	D
BUILD_EXTENSION_TYPE_profile	=	P

RUNTIME_PATH				= $(shell $(ECHO) $(PREFIX_LIB) $(UNITTEST_RUNTIME_PATH) $($(RUNTIME_SHARED_PATH_SET))| sed '-e s/ /:/')

DEFER_NAME					= $(strip $(patsubst %.defer, %, $(filter %.defer, $(TARGET_ALL))))
