
# Generic Makefile for all building.
#
SHELL=/bin/bash
#
# To use set the variable TARGET
# Then include this file.
# The TARGET variable may include multiple things to build
#
#
# A name with a *.prog  extension is an executable			(the app will NOT be part of the final name)
# A name with a *.dir  extension builds a subdirectory
#
# Build a library.
# A name with a *.a    extension is a static library		(the lib prefix will automatically be added)
# A name with a *.slib extension is a shared library		(the lib prefix will automatically be added. And platform specific suffix will replace slib)
# A name with a *.head extension builds a header only library
# A name with a *.defer
# A name with a *.test
#
# A name with a *.lib  extension is static or shared depending THOR_TARGETLIBS (this is usually defined by the configure script)
#					   if THOR_TARGETLIBS is empty it defaults to shared.
#					   for each value in THOR_TARGETLIBS it will add a version of the library to the target.
#						TARGET=XXX.lib THOR_TARGETLIBS="slib a"
#						NEW_TARGET=XXX.slib XXX.a
#
#		Note: This will build a shared library with the appropriate platform specific extension
#			  In the directory TARGET_Mode (debug/release)
#		Note: You can build multiple *.dir or *.prog targets.
#				These will install an application in ${PREFIX_BIN}/<App-Name>
#			  But you can only build **ONE** lib
#			  A lib will consist of:
#					1) All the header files *.h *.tpp (in the current directory)
#					   Installed into ${PREFIX_INC}/<Lib-Name>/
#					2) A lib with the appropriate extension.
#					   Installed into ${PREFIX_LIB}/<Lib-Name><Type>.<Ext>
#					   It will be built from all the source files in the current directory.
#					   After removing any source files that match *.prog target names.
#					   i.e. If you have a TARGET=bob.prog glib.slib
#					   then glib.so will not include the source file bob.cpp
#
# A name with a *.defer	builds the object files and but does not build a library.
#						The header files are deployed as normal.
#						All the object files are saved to the build directory.
#
#						These object files can be used by a subsequent library by specifying the
#							DEFER_LIBS = <List of Projects that have been deferred>
#
#						Example:
#							Dir:	ThorsDB
#										Makfile:	TARGET = ThorsDB.defer
#							Dir:	ThorsDBCommon
#										Makefile:	TARGET = ThorsDBCommon.defer
#							Dir:	MySQL
#										Makefile:	TARGET = ThorsMySQL.defer
#							Dir:	ThorsDBBuild
#										Makefile:	TARGET = ThorsDB.lib
#													DEFER_LIBS = ThorsDB ThorsDBCommon ThorsMySQL
#													This will build the library: ThorsDB.lib
#													and use all the object files from the three
#													projects defined above
# A name with a *.test only builds and runs the test.
#						It does nothing for debug/release/install
#
#						This extension was added so that we could build a single library from multiple directories.
#						See the XXX
#
# Flags Help:
#	CXXSTDVER=03/11/14/17			Should be set to the appropriate value:		Default: CXXSTDVER		=03
#	CXX_STD_FLAG					Should be set to the appropriate value		Default: CXX_STD_FLAG	=-std=c++11
#	VERBOSE=On						Turn on verbose mode
#										This will print the full compile command rather than a summary
#
# Flags For Specific files:
#	NO_HEADER
#		Prevents header files from being installed when building a library
#	LDLIBS_EXTERN_BUILD
#		This is a magic flag.
#		If you define any any values in here they will cause several other flags to be added:
#		Example:
#			LDLIBS_EXTERN_BUILD		= yaml
#			Then internally this makefile check for the existence of $(yaml_ROOT_DIR) and modify
#			the following variables (only if it is defined)
#				LDLIBS				= $(LDLIBS)   -L$(yaml_ROOT_DIR)/lib      -lyaml
#				CXXFLAGS			= $(CXXFLAGS) -I$(yaml_ROOT_DIR)/include
#				RPATH				= $(RPATH):%(yaml_ROOT_DIR)/lib
#			Note: This is supposed to be used in conjunction with configuration file and
#				  you will probably see xxxx_ROOT_DIR defined in Makefile.config
#			UNITTEST_CXXFLAGS
#
#	<TARGET>_LDLIBS			= <Libs>
#		Adds libs for specific targets in the makefile.
#		Libs is used exactly as shown with no processing.
#
#	<TARGET>_LINK_LIBS		= <Libs>
#		Adds libs for specific targets in the makefile.
#		Each item in Libs will be expanded with -l<item><build-extension>
#		This this is used for libraries build with this project
#
#	UNITTEST_LDLIBS			= <Libs>
#	UNITTEST_LINK_LIBS		= <Libs>
#		Like the above two but specifically for unit tests
#
#	<SOURCE>_CXXFLAGS		= <Flags>
#		Adds specific flags for a file.
#		Usually used to suppress warnings.
#
#	FILE_WARNING_FLAGS
#		Extra project specific warning flags
#
#	COVERAGE_REQUIRED defaults to 80%
#		but if you want to reduce this you can set this in a specific project make file
#
#	Displaying coverage:
#		make coverage-file.h	=> Display the coverage for file.h
#
#	Run specific UNIT TEST
#		Note:	TestName	=> *
#							=> <ClassName>.*
#							=> <ClassName>.<TestMethod>
#
#		make test-<TestName>
#
#	Only Run specific test
#		make testrun.<TestName>
#	Run a specific unit test in the debugger
#		make debugrun.<TestName>

-include $(THORSANVIL_ROOT)/Makefile.config
BUILD_ROOT		?= $(THORSANVIL_ROOT)/build
BASE			?= .
include $(BUILD_ROOT)/tools/Colour.Makefile
include $(BUILD_ROOT)/tools/Platform.Makefile
include $(BUILD_ROOT)/tools/ThorsAnvilLibs.Makefile

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
# Look in Platform.Makefile
# These value may have platform specific values.
# They are defined here as a last resort (i.e. default values)
YACC			?= bison
LEX				?= flex
GPERF			?= gperf --ignore-case
CP				?= cp
LNSOFT			?= ln -f -s
MKDIR			?= mkdir
RMDIR			?= rmdir

VERA_ROOT		= --root=$(THORSANVIL_ROOT)/build/vera-plusplus
MAKE			= make --silent

TESTNAME		?= *
	
#
# This is obviously not working
# Need to look at this
COV_LONG_FLAG					= $(COV_LONG_FLAG_$(PLATFORM))
COV_LONG_FLAG_Linux				= --long-file-names
COV_LONG_FLAG_Darwin			= -l


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
CPP_SRC						= $(filter-out %.lex.cpp %.tab.cpp %.gperf.cpp $(APP_SRC),$(wildcard *.cpp))
CPP_HDR						= $(filter-out %.lex.h   %.tab.h %.tab.hpp  %.gperf.h             ,$(wildcard *.h *.hpp))
LEX_SRC						= $(wildcard *.l)
GPERF_SRC					= $(wildcard *.gperf)
YACC_SRC					= $(wildcard *.y)
TMP_SRC						= $(patsubst %.y,%.tab.cpp,$(YACC_SRC)) $(patsubst %.l,%.lex.cpp,$(LEX_SRC))
TMP_HDR						= $(patsubst %.y,%.tab.h,$(YACC_SRC)) $(patsubst %.l,%.lex.h,$(LEX_SRC)) $(patsubst %.y,%.tab.hpp,$(YACC_SRC)) $(patsubst %.l,%.lex.hpp,$(LEX_SRC))
SRC							= $(TMP_SRC) $(patsubst %.gperf,%.gperf.cpp,$(GPERF_SRC)) $(CPP_SRC)
DEP							= $(patsubst %.cpp, makedependency/%.d, $(SRC))
HEAD						= $(filter-out $(EXCLUDE_HEADERS), $(wildcard *.h *.tpp *.hpp)) $(EXTRA_HEADERS)
OBJ							= $(patsubst %.cpp,$(TARGET_MODE)/%.o,$(SRC))
VERA_SRC					= $(filter-out $(TEST_IGNORE) $(TMP_SRC), $(CPP_SRC) $(APP_SRC)) $(filter-out %Config.h $(TEST_IGNORE) $(TMP_HDR), $(CPP_HDR)) $(wildcard *.tpp)
GCOV_OBJ					= $(filter-out coverage/main.o,$(OBJ)) $(MOCK_OBJECT)
GCOV_BASIC_SRC				= $(patsubst coverage/%.o, coverage/%.cpp.gcov, $(filter-out $(MOCK_OBJECT) $(TMP_SRC) $(TMP_HDR) $(APP_SRC) ,$(GCOV_OBJ))) $(patsubst %.tpp,coverage/%.tpp.gcov, $(wildcard *.tpp))
GCOV_BASIC_HEAD				= $(patsubst %, coverage/%.gcov, $(filter-out $(APP_HEAD) %Config.h,$(wildcard *.h *.hpp)))
GCOV_SRC					= $(filter-out $(foreach nocoverage,$(TEST_IGNORE),coverage/$(nocoverage).gcov), $(GCOV_BASIC_SRC))
GCOV_HEAD					= $(filter-out $(foreach nocoverage,$(TEST_IGNORE),coverage/$(nocoverage).gcov), $(GCOV_BASIC_HEAD))
GCOV_LIBOBJ					= $(if $(GCOV_OBJ),-lobject)
DEFER_OBJDIR				= $(foreach lib, $(DEFER_LIBS), $(PREFIX_DEFER_OBJ)/$(lib)/$(TARGET_MODE))
DEFER_OBJ					= $(foreach dir, $(DEFER_OBJDIR), $(wildcard $(dir)/*.o))


NOTHING						:=
SPACE						:=$(NOTHING) $(NOTHING)
LDLIBS_EXTERN_BUILD_USE		= $(filter-out $(LDLIBS_FILTER), $(LDLIBS_EXTERN_BUILD))
CXX_EXTERN_HEADER_ONLY		= $(foreach lib, $(LDLIBS_EXTERN_BUILD_USE), $(if $($(lib)HeaderOnly_ROOT_DIR), -I$($(lib)HeaderOnly_ROOT_DIR)))
LDLIBS_EXTERN_LIB_LOC		= $(foreach lib, $(LDLIBS_EXTERN_BUILD_USE), $(if $($(lib)_ROOT_DIR), -L$($(lib)_ROOT_DIR)/lib))
LDLIBS_EXTERN_INC_LOC		= $(foreach lib, $(LDLIBS_EXTERN_BUILD_USE), $(if $($(lib)_ROOT_DIR), -I$($(lib)_ROOT_DIR)/include))
LDLIBS_EXTERN_SHARE			= $(foreach lib, $(LDLIBS_EXTERN_BUILD_USE), $(foreach alib, $($(lib)_ROOT_LIB), -l$(alib)$(if $($(lib)_ISTHOR),$(BUILD_EXTENSION))))
LDLIBS_EXTERN_PATH			= $(subst $(SPACE),:,$(strip $(foreach lib, $(LDLIBS_EXTERN_BUILD_USE), $(if $($(lib)_ROOT_DIR),$($(lib)_ROOT_DIR)/lib))))
LDLIBS_EXTERN_RPATH			+=$(if $(LDLIBS_EXTERN_PATH),export RPATH=$(LDLIBS_EXTERN_PATH);)
LDLIBS						+= $(LDLIBS_EXTERN_LIB_LOC) $(LDLIBS_EXTERN_SHARE) $(EXLDLIBS)
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

PLATFORM_SPECIFIC_FLAGS		=	$(PLATFORM_$(PLATFORM)_FLAGS)
PLATFORM_Darwin_FLAGS		=
PLATFORM_Linux_FLAGS		=


#
# Having problems with unreachable code being reported in the system header files
# Had to turn this on to make the code compile with no errors.
COMPILER_SPECIFIC_FLAGS		= -Wno-unreachable-code


#
# Bug in gcc
# The macro __cplusplus is always 1 so you can detect the language version at the pre-processor level.
# So we defined the flag THOR_USE_CPLUSPLUS11 to be used instead
LANGUAGE_SPECIFIC_FLAGS		= -DTHOR_USE_CPLUSPLUS$(CXXSTDVER)


WARNING_FLAGS				=	$(WARNING_FLAGS_$(TEST_STATE)) $(WARNING_FLAGS_$(TARGET_MODE)) $(FILE_WARNING_FLAGS)
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
TEST_LIBS_on				=	-L../coverage -L$(PREFIX_DEFER_LIB) -L$(THORSANVIL_ROOT)/build/lib $(GCOV_LIBOBJ_PASS) -lgtest
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

CC							=	$(CXX)
CXXFLAGS					+=	-fPIC $(WARNING_FLAGS) $(THORSANVIL_FLAGS) -isystem $(PREFIX_INC3RD) $(TEST_FLAGS) $(OPTIMIZER_FLAGS) $(ENVIRONMENT_FLAGS) $(CXX_STD_FLAG)

ALL_LDLIBS					+=	$(TEST_LIBS) $(OPTIMIZER_LIBS) $(THORSANVIL_LIBS)

MOCK_HEADER_INCLUDES_FILES	=	$(strip $(wildcard MockHeaderInclude.h) $(wildcard test/MockHeaderInclude.h))
MOCK_HEADER_INCLUDES		=   $(if $(MOCK_HEADER_INCLUDES_FILES), -include $(MOCK_HEADER_INCLUDES_FILES))
MOCK_HEADERS_coverage		=	$(MOCK_HEADER_INCLUDES) -include coverage/MockHeaders.h
MOCK_HEADERS_release		=   -DMOCK_FUNC\(x\)=::x -DMOCK_TFUNC\(x\)=::x
MOCK_HEADERS_debug			=   -DMOCK_FUNC\(x\)=::x -DMOCK_TFUNC\(x\)=::x
MOCK_FILES_coverage			=	$(BASE)/coverage/MockHeaders.h $(BASE)/coverage/MockHeaders.cpp $(BASE)/coverage/MockHeaders2.h $(BASE)/coverage/MockHeaders2.cpp
MOCK_OBJECT_coverage		=	$(BASE)/coverage/MockHeaders.o $(BASE)/coverage/MockHeaders2.o
MOCK_HEADERS				=	$(MOCK_HEADERS_$(TARGET_MODE))
MOCK_FILES					=	$(MOCK_FILES_$(TARGET_MODE))
MOCK_OBJECT					=	$(MOCK_OBJECT_$(TARGET_MODE))


PREFIX						?=	$(BUILD_ROOT)
PREFIX_BIN					?=	$(PREFIX)/bin
PREFIX_LIB					?=	$(PREFIX)/lib
PREFIX_INC					?=	$(PREFIX)/include
PREFIX_INC3RD				?=	$(THORSANVIL_ROOT)/build/include3rd
BUILD_SUFFIX				=	$(BUILD_EXTENSION_TYPE_$(TARGET_MODE))
BUILD_EXTENSION				=	$(CXXSTDVER)$(BUILD_SUFFIX)
BUILD_EXTENSION_TYPE_debug		=	D
BUILD_EXTENSION_TYPE_coverage	=	D
BUILD_EXTENSION_TYPE_profile	=	P

RUNTIME_PATH				= $(shell $(ECHO) $(PREFIX_LIB) $(UNITTEST_RUNTIME_PATH) $($(RUNTIME_SHARED_PATH_SET))| sed '-e s/ /:/')

DEFER_NAME					= $(strip $(patsubst %.defer, %, $(filter %.defer, $(TARGET_ALL))))

#
# For reference the default rules are
#	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS)
#	$(CC) $(LDFLAGS) N.o $(LOADLIBES) $(LDLIBS)

.PHONY:	all install uninstall build veryclean debug release lint item
.PHONY: buildDir
.PHONY:	testonly covonly
.PHONY:	test
.PHONY:	tools
.PHONY:	coverage coveragetest veraonly
.PHONY:	makedependency


.PRECIOUS: %.Dir


all:					build
install:				test debug release
	@$(MAKE) INSTALL_ACTIVE=YES		ActionInstall
uninstall:
	@$(MAKE) INSTALL_ACTIVE=YES		ActionUInstall
build:					test debug release
	@$(MAKE) INSTALL_ACTIVE=NO		ActionInstall
veryclean:				clean
	@$(MAKE) INSTALL_ACTIVE=NO		ActionUInstall
debug:					makedependency
	@$(MAKE) TARGET_MODE=debug		item
release:				makedependency
	@$(MAKE) TARGET_MODE=release	item
lint:					doLint
item:					PrintDebug buildDir Note_Building_$(TARGET_MODE) $(TARGET_ITEM)
buildDir:	| $(TARGET_MODE).Dir coverage.Dir
%.Dir:
	@$(MKDIR) -p $*
testonly:				ActionRunUnitTest
covonly:				ActionRunCoverage
veraonly:				ActionRunVera
test:					makedependency ActionRunUnitTest ActionRunCoverage ActionRunVera

HEADER_ONLY_PACKAGE		= $(basename $(firstword $(TARGET)))
build-honly:
	@$(BUILD_ROOT)/headeronly/convert_project $(PREFIX) $(HEADER_ONLY_PACKAGE) $(NAMESPACE)
	@echo "CWD=$$(pwd);cd $(PREFIX);HEADER_ONLY=1 THORSANVIL_ROOT=$${CWD} CXXFLAGS=-I$(PREFIX) LDLIBS_FILTER="$(patsubst $(PREFIX)/%,%,$(wildcard $(PREFIX)/*))" $(MAKE) test"
	@CWD="$$(pwd)";	\
	cd "$(PREFIX)/$(HEADER_ONLY_PACKAGE)";	\
	HEADER_ONLY=1 THORSANVIL_ROOT="$${CWD}" CXXFLAGS="-I$(PREFIX)" LDLIBS_FILTER="$(patsubst $(PREFIX)/%,%,$(wildcard $(PREFIX)/*))" $(MAKE) test
	@$(BUILD_ROOT)/headeronly/commit_project $(PREFIX) $(HEADER_ONLY_PACKAGE) $(NAMESPACE)


clean:
	$(RM) -rf debug release coverage report makedependency test/coverage test/dependency $(TMP_SRC) $(TMP_HDR) location.hh  makefile_tmp position.hh  stack.hh *.gcov test/*.gcov

makedependency:				$(DEP)

.SECONDARY: makedependency/%.d


include $(BUILD_ROOT)/tools/Build/install.Makefile
include $(BUILD_ROOT)/tools/Build/test.Makefile
include $(BUILD_ROOT)/tools/Build/coverage.Makefile
include $(BUILD_ROOT)/tools/Build/vera.Makefile
include $(BUILD_ROOT)/tools/lint.Makefile
include $(BUILD_ROOT)/tools/Doc.Makefile
ifndef NODEP
-include makedependency/*
endif


Note_%:
	@$(ECHO) $(call section_title, $(subst _, ,$*))

.PRECIOUS:	$(OBJ)
.PRECIOUS:	$(GCOV_OBJ)
.PRECIOUS:	$(TARGET_MODE)/%.prog
.PRECIOUS:	$(TARGET_MODE)/lib%.$(SO)
.PRECIOUS:  $(TARGET_MODE)/lib%.a
.PRECIOUS:	%.tab.cpp
.PRECIOUS:	%.lex.cpp
.PRECIOUS:	%.gperf.cpp
.PRECIOUS:	%.cpp.gcov
.PRECIOUS:	%.tpp.gcov
.PRECIOUS:	%.vera


.PHONY:	%.prog %.slib %.head %.defer %.test
.PHONY:	run_test vera vera_head vera_body

%.head:
	@$(ECHO) $(call subsection_title, Nothing to build for $*)

%.test:
	@$(ECHO) $(call subsection_title, Nothing to build for $*)

%.prog:		buildDir $(TARGET_MODE)/%.prog
	@$(ECHO) $(call subsection_title, Done Building $(TARGET_MODE)/$*)

%.a:		buildDir $(TARGET_MODE)/lib%.a
	@$(ECHO) $(call subsection_title, Done Building $(shell basename `pwd`) $(TARGET_MODE)/lib$*.a)

%.slib:		buildDir $(TARGET_MODE)/lib%.$(SO)
	@$(ECHO) $(call subsection_title, Done Building $(shell basename `pwd`) $(TARGET_MODE)/lib$*.$(SO))

#
# The defer mode builds a static lib
# This library is used for unit testing but never installed.
# This also has the side affect of building the required object files.
# That we will copy into the build directory for later use when building a library
%.defer:	buildDir  $(TARGET_MODE)/lib%$(BUILD_EXTENSION).a
	@$(ECHO) $(call subsection_title, Done Building $(TARGET_MODE)/defer)


$(TARGET_MODE)/%.prog:	$(OBJ) $(DEFER_OBJ) $(TARGET_MODE)/%.o | $(TARGET_MODE).Dir
	@if ( test "$(VERBOSE)" = "On" ); then \
		$(ECHO) '$(CXX) -o $@ $(LDFLAGS) $(OBJ) $(DEFER_OBJ) $(CXXFLAGS) $(call expandFlag,$($*_CXXFLAGS)) $(TARGET_MODE)/$*.o $(LOADLIBES) $(ALL_LDLIBS) $(LDLIBS) $($*_LDLIBS) $(call expand,$($*_LINK_LIBS))' ; \
	else $(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), "$(CC) -o $@ $(OPTIMIZER_FLAGS_DISP)  $(call expandFlag,$($*_CXXFLAGS))")	| awk '{printf "%-$(LINE_WIDTH)s", $$0}' ;	fi
	@$(LDLIBS_EXTERN_RPATH) $(CXX) -o $@ $(LDFLAGS) $(OBJ) $(DEFER_OBJ) $(CXXFLAGS) $(call expandFlag,$($*_CXXFLAGS)) $(TARGET_MODE)/$*.o $(LOADLIBES) $(ALL_LDLIBS) $(LDLIBS) $($*_LDLIBS) $(call expand,$($*_LINK_LIBS)) 2>makefile_tmp; \
	if [ $$? != 0 ];									\
	then												\
		$(ECHO) $(RED_ERROR);							\
		$(ECHO) "$(LDLIBS_EXTERN_RPATH)";				\
		$(ECHO) $(CXX) -o $@ $(LDFLAGS) $(OBJ) $(DEFER_OBJ) $(TARGET_MODE)/$*.o $(LOADLIBES) $(ALL_LDLIBS) $(LDLIBS) $($*_LDLIBS) $(call expand,$($*_LINK_LIBS)); \
		$(ECHO) "==================================================="; \
		cat makefile_tmp;								\
		exit 1;											\
	else 												\
		$(ECHO) $(GREEN_OK);							\
		$(RM) makefile_tmp;								\
	fi

$(TARGET_MODE)/lib%.a:	$(GCOV_OBJ) $(DEFER_OBJ) | $(TARGET_MODE).Dir
	@if ( test "$(VERBOSE)" = "On" ); then				\
		$(ECHO) '$(AR) $(ARFLAGS) $@ $(GCOV_OBJ) $(DEFER_OBJ)';\
	else $(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), "$(AR) $(ARFLAGS) $@")	| awk '{printf "%-$(LINE_WIDTH)s", $$0}' ; fi
	@$(AR) $(ARFLAGS) $@ $(GCOV_OBJ) $(DEFER_OBJ) > makefile_tmp 2>&1;	\
	ranlib $@ 2> /dev/null;								\
	if [ $$? != 0 ];									\
	then												\
		$(ECHO) $(RED_ERROR);							\
		$(ECHO) $(AR) $(ARFLAGS) $@ $(GCOV_OBJ) $(DEFER_OBJ);\
		$(ECHO) "==================================================="; \
		cat makefile_tmp;								\
		exit 1;											\
	else 												\
		$(ECHO) $(GREEN_OK);							\
		$(RM) makefile_tmp;								\
	fi

$(TARGET_MODE)/lib%.$(SO):	$(GCOV_OBJ) $(DEFER_OBJ) | $(TARGET_MODE).Dir
	@if ( test "$(VERBOSE)" = "On" ); then				\
		$(ECHO) '$(CXX) $(SHARED_LIB_FLAG_$(PLATFORM)) -o $@ $(LDFLAGS) $(GCOV_OBJ) $(DEFER_OBJ) $(CXXFLAGS)  $(call expandFlag,$($*_CXXFLAGS)) $(LOADLIBES) $(ALL_LDLIBS) $(LDLIBS) $(THORSANVIL_STATICLOADALL)' ; \
	else $(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), "$(CC) $(SHARED_LIB_FLAG_$(PLATFORM)) -o $@ $(OPTIMIZER_FLAGS_DISP)  $(call expandFlag,$($*_CXXFLAGS))")	| awk '{printf "%-$(LINE_WIDTH)s", $$0}' ; fi
	@$(LDLIBS_EXTERN_RPATH) $(CXX) $(SHARED_LIB_FLAG_$(PLATFORM)) -o $@ $(LDFLAGS) $(GCOV_OBJ) $(DEFER_OBJ) $(CXXFLAGS)  $(call expandFlag,$($*_CXXFLAGS)) $(LOADLIBES) $(ALL_LDLIBS) $(LDLIBS) $(THORSANVIL_STATICLOADALL) 2>makefile_tmp; \
	if [ $$? != 0 ];									\
	then												\
		$(ECHO) "";										\
		$(ECHO) $(RED_ERROR);							\
		$(ECHO) "$(LDLIBS_EXTERN_RPATH) $(CXX) $(SHARED_LIB_FLAG_$(PLATFORM)) -o $@ $(LDFLAGS) $(GCOV_OBJ) $(DEFER_OBJ) $(CXXFLAGS)  $(call expandFlag,$($*_CXXFLAGS)) $(LOADLIBES) $(ALL_LDLIBS) $(LDLIBS) $(THORSANVIL_STATICLOADALL)"; \
		$(ECHO) "==================================================="; \
		cat makefile_tmp;								\
		exit 1;											\
	else 												\
		$(ECHO) $(GREEN_OK);							\
		$(RM) makefile_tmp;								\
	fi

makedependency/%.d:		%.cpp | makedependency.Dir
	@if ( test "$(VERBOSE)" = "On" ); then				\
		$(ECHO) '$(CXX) -MM -MT"coverage/$(<:.cpp=.o)" "$<"';\
	fi
	@export tmpfile=$(shell $(MKTEMP));					\
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(call expandFlag,$($*_CXXFLAGS))  -MF"$@" -MM -MP -MT"$@" -MT"debug/$(<:.cpp=.o)" -MT"release/$(<:.cpp=.o)" -MT"coverage/$(<:.cpp=.o)" "$<" 2> $${tmpfile}; \
	if [ $$? != 0 ];									\
	then												\
		$(ECHO) $(RED_ERROR);							\
		$(ECHO) '$(CXX) $(CXXFLAGS) -MF"$@" -MM -MP -MT"$@" -MT"debug/$(<:.cpp=.o)" -MT"release/$(<:.cpp=.o)" -MT"coverage/$(<:.cpp=.o)" "$<"'; \
		$(ECHO) "========================================";\
		cat $${tmpfile};								\
		exit 1;											\
	fi

$(BASE)/coverage/MockHeaders.o: $(BASE)/coverage/MockHeaders.cpp
	@if ( test "$(VERBOSE)" = "Off" ); then				\
		$(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), "$(CXX) -c $< $(OPTIMIZER_FLAGS_DISP)  $(call expandFlag,$($*_CXXFLAGS))") | awk '{printf "%-$(LINE_WIDTH)s", $$0}' ; \
	elif ( test "$(VERBOSE)" = "On" ); then				\
		$(ECHO) '$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(call expandFlag,$($*_CXXFLAGS))' ;		\
	fi
	@export tmpfile=$(shell $(MKTEMP));					\
	$(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), "$(CXX) -c $(OPTIMIZER_FLAGS_DISP)  $(call expandFlag,$($*_CXXFLAGS))") $< | awk '{printf "%-$(LINE_WIDTH)s", $$0}' ; \
	$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(MOCK_HEADERS) $(call expandFlag,$($*_CXXFLAGS)) 2>$${tmpfile};	\
	if [ $$? != 0 ];									\
	then												\
		$(ECHO) $(RED_ERROR);							\
		$(ECHO) $(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(MOCK_HEADERS) $(call expandFlag,$($*_CXXFLAGS));\
		$(ECHO) "========================================";\
		cat $${tmpfile};								\
		exit 1;											\
	else 												\
		$(ECHO) $(GREEN_OK);							\
		$(RM) $${tmpfile};								\
	fi

$(BASE)/coverage/MockHeaders2.o: $(BASE)/coverage/MockHeaders2.cpp
	@if ( test "$(VERBOSE)" = "Off" ); then				\
		$(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), "$(CXX) -c $< $(OPTIMIZER_FLAGS_DISP)  $(call expandFlag,$($*_CXXFLAGS))") | awk '{printf "%-$(LINE_WIDTH)s", $$0}' ; \
	elif ( test "$(VERBOSE)" = "On" ); then				\
		$(ECHO) '$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(call expandFlag,$($*_CXXFLAGS))' ;		\
	fi
	@export tmpfile=$(shell $(MKTEMP));					\
	$(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), "$(CXX) -c $(OPTIMIZER_FLAGS_DISP)  $(call expandFlag,$($*_CXXFLAGS))") $< | awk '{printf "%-$(LINE_WIDTH)s", $$0}' ; \
	$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(MOCK_HEADERS) $(call expandFlag,$($*_CXXFLAGS)) 2>$${tmpfile};	\
	if [ $$? != 0 ];									\
	then												\
		$(ECHO) $(RED_ERROR);							\
		$(ECHO) $(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(MOCK_HEADERS) $(call expandFlag,$($*_CXXFLAGS));\
		$(ECHO) "========================================";\
		cat $${tmpfile};								\
		exit 1;											\
	else 												\
		$(ECHO) $(GREEN_OK);							\
		$(RM) $${tmpfile};								\
	fi

$(TARGET_MODE)/%.o: %.cpp | $(TARGET_MODE).Dir
	@if ( test "$(VERBOSE)" = "Off" ); then				\
		$(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), "$(CXX) -c $< $(OPTIMIZER_FLAGS_DISP)  $(call expandFlag,$($*_CXXFLAGS))") | awk '{printf "%-$(LINE_WIDTH)s", $$0}' ; \
	elif ( test "$(VERBOSE)" = "On" ); then				\
		$(ECHO) '$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(call expandFlag,$($*_CXXFLAGS))' ;		\
	fi
	@export tmpfile=$(shell $(MKTEMP));					\
	$(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), "$(CXX) -c $(OPTIMIZER_FLAGS_DISP)  $(call expandFlag,$($*_CXXFLAGS))") $< | awk '{printf "%-$(LINE_WIDTH)s", $$0}' ; \
	$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(MOCK_HEADERS) $(call expandFlag,$($*_CXXFLAGS)) 2>$${tmpfile};	\
	if [ $$? != 0 ];									\
	then												\
		$(ECHO) $(RED_ERROR);							\
		$(ECHO) $(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(MOCK_HEADERS) $(call expandFlag,$($*_CXXFLAGS));\
		$(ECHO) "========================================";\
		cat $${tmpfile};								\
		exit 1;											\
	else 												\
		$(ECHO) $(GREEN_OK);							\
		$(RM) $${tmpfile};								\
	fi

%.tab.cpp: %.y
	@if ( test "$(VERBOSE)" = "Off" ); then				\
		$(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), "$(YACC) $^") | awk '{printf "%-$(LINE_WIDTH)s", $$0}' ; \
	elif ( test "$(VERBOSE)" = "On" ); then				\
		$(ECHO) '$(YACC) -o $@ -d $<' ;					\
	fi
	@export tmpfile=$(shell $(MKTEMP));					\
	export errorFile=$(shell $(MKTEMP));				\
	$(YACC) -o $@ -d $< 2>$${errorFile};			    \
	if [ $$? != 0 ];									\
	then												\
		$(ECHO) "Failed in Parser Generator";			\
		$(ECHO) $(RED_ERROR);							\
		$(ECHO) $(YACC) -o $@ -d $<;					\
		$(ECHO) "========================================";\
		cat $${errorFile};								\
		exit 1;											\
	else 												\
		mv $@ $${tmpfile};								\
		sed -e 's/semantic_type yylval;/semantic_type yylval{};/'	\
			$${tmpfile} > $@;							\
		if ( test "$(VERBOSE)" = "NONE" ); then			\
			$(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), "$(YACC) $^") | awk '{printf "%-$(LINE_WIDTH)s", $$0}' ; \
		fi;												\
		$(ECHO) $(GREEN_OK);							\
		$(RM) $${errorFile} $${tmpfile};				\
	fi

%.lex.cpp: %.l
	@if ( test "$(VERBOSE)" = "Off" ); then				\
		$(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), "$(LEX) $^") | awk '{printf "%-$(LINE_WIDTH)s", $$0}' ; \
	elif ( test "$(VERBOSE)" = "On" ); then				\
		$(ECHO) '$(LEX) -t $< > $@' ;					\
	fi
	@export tmpfile=$(shell $(MKTEMP));					\
	export errorFile=$(shell $(MKTEMP));				\
	$(LEX) -t --c++ --header-file=$*.lex.h $< > $${tmpfile} 2> $${errorFile};	\
	if [ $$? != 0 ];									\
	then												\
		$(ECHO) "Failed in Lexer Generator";			\
		$(ECHO) $(RED_ERROR);							\
		$(ECHO) $(LEX) -t $< > $@;						\
		$(ECHO) "========================================";\
		cat $${errorFile};								\
		exit 1;											\
	else 												\
		cat $${tmpfile} |								\
			sed -e 's/<stdout>/$*.lex.cpp/'				\
				-e 's/extern "C" int isatty/\/\/ Removed extern "C" int isatty/' -e 's/max_size )) < 0 )/max_size )) == std::size_t(-1) )/'	\
				-e 's/(int)(result = LexerInput/(std::size_t)(result = LexerInput/'	\
				-e 's/int yy_buf_size;/std::size_t yy_buf_size;/'	\
				> $@;									\
		if ( test "$(VERBOSE)" = "NONE" ); then			\
			$(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), "$(LEX) $^") | awk '{printf "%-$(LINE_WIDTH)s", $$0}' ; \
		fi;												\
		$(ECHO) $(GREEN_OK);							\
		$(RM) $${errorFile} $${tmpFile};				\
	fi

%.gperf.cpp: %.gperf
	@if ( test "$(VERBOSE)" = "Off" ); then				\
		$(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), "$(GPERF) --class-name=$*_Hash $^") | awk '{printf "%-$(LINE_WIDTH)s", $$0}' ; \
	elif ( test "$(VERBOSE)" = "On" ); then				\
		$(ECHO) '$(GPERF) -l -L C++ --class-name=$*_Hash $^ > $@'	;	\
	fi
	@export tmpfile=$(shell $(MKTEMP));					\
	$(GPERF) -l -L C++ --class-name=$*_Hash $^ > $@ 2>$${tmpfile}; \
	if [ $$? != 0 ];									\
	then												\
		$(ECHO) "Failed in Lexer Generator";			\
		$(ECHO) $(RED_ERROR);							\
		$(ECHO) "$(GPERF) -l -L C++ --class-name=$@_Hash $^ > $@"; \
		$(ECHO) "========================================";\
		cat $@;											\
		exit 1;											\
	else 												\
		if ( test "$(VERBOSE)" = "NONE" ); then			\
			$(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), "$(GPERF) --class-name=$*_Hash $^") | awk '{printf "%-$(LINE_WIDTH)s", $$0}' ; \
		fi;												\
		$(ECHO) $(GREEN_OK);							\
	fi

.PHONY:	PrintDebug Print_NONE Print_Off Print_On
PrintDebug:	Print_$(VERBOSE)
Print_Off:
Print_NONE:
Print_On:
	@$(ECHO) "TARGET:               $(TARGET)"
	@$(ECHO) "TARGET_ITEM:          $(TARGET_ITEM)"
	@$(ECHO) "TARGET_ALL:           $(TARGET_ALL)"
	@$(ECHO) "TARGET_MODE:          $(TARGET_MODE)"
	@$(ECHO) "CPP_SRC:              $(CPP_SRC)"
	@$(ECHO) "APP_SRC:              $(APP_SRC)"
	@$(ECHO) "HEAD:                 $(HEAD)"
	@$(ECHO) "SRC:                  $(SRC)"
	@$(ECHO) "OBJ:                  $(OBJ)"
	@$(ECHO) "DEFER_OBJ:            $(DEFER_OBJ)"
	@$(ECHO) "GCOV_SRC              $(GCOV_SRC)"
	@$(ECHO) "GCOV_HEAD:            $(GCOV_HEAD)"
	@$(ECHO) "GCOV_OBJ:             $(GCOV_OBJ)"
	@$(ECHO) "GPERF_SRC:            $(GPERF_SRC)"
	@$(ECHO) "GCOV_REPORT:          $(GCOV_REPORT)"
	@$(ECHO) "TEST_IGNORE:          $(TEST_IGNORE)"
	@$(ECHO) "VERA_SRC:             $(VERA_SRC)"
	@$(ECHO) "VERA_OBJ:             $(VERA_OBJ)"
	@$(ECHO) "BOOST_CPPFLAGS:       $(BOOST_CPPFLAGS)"
	@$(ECHO) "RUNTIME_PATH:         $(RUNTIME_PATH)"
	@$(ECHO) "RUNTIME_SHARED_PATH_SET: $(RUNTIME_SHARED_PATH_SET)"
	@$(ECHO) "RUNTIME_SHARED_PATH_SET EXPAND: $($(RUNTIME_SHARED_PATH_SET))"
	@$(ECHO) "libdir:               $(libdir)"
	@$(ECHO) "libdir:               ${libdir}"
	@$(ECHO) "THORSLINKDIRS:        $(THORSLINKDIRS)"
	@$(ECHO) "THORSANVIL_STATICLOADALL: $(THORSANVIL_STATICLOADALL)"
	@$(ECHO) "MAN_SRC:              $(MAN_SRC)"
	@$(ECHO) "MAN_DIR:              $(MAN_DIR)"
	@$(ECHO) "MAN_PAGE:             $(MAN_PAGE)"
	@$(ECHO) "INSTALL_APP:          $(INSTALL_APP)"
	@$(ECHO) "INSTALL_SHARED_LIB:   $(INSTALL_SHARED_LIB)"
	@$(ECHO) "INSTALL_STATIC_LIB:   $(INSTALL_STATIC_LIB)"
	@$(ECHO) "INSTALL_HEADER:       $(INSTALL_HEADER)"
	@$(ECHO) "DEFER_NAME:           $(DEFER_NAME)"
	@$(ECHO) "INSTALL_DEFER:        $(INSTALL_DEFER)"
	@$(ECHO) "DEFER_NAME:           $(DEFER_NAME)"
	@$(ECHO) "DEFER_LIBS:           $(DEFER_LIBS)"
	@$(ECHO) "DEFER_OBJDIR:         $(DEFER_OBJDIR)"
	@$(ECHO) "DEFER_OBJ:            $(DEFER_OBJ)"
	@$(ECHO) "CXXSTDVER:			$(CXXSTDVER)"
	@$(ECHO) "CXX_STD_FLAG:			$(CXX_STD_FLAG)"
	@$(ECHO) "LDLIBS_EXTERN_BUILD:	$(LDLIBS_EXTERN_BUILD)"
	@$(ECHO) "LDLIBS:				$(LDLIBS)"
	@$(ECHO) "LINK_LIBS:			$(LINK_LIBS)"
	@$(ECHO) "CXXFLAGS:				$(CXXFLAGS)"
	@$(ECHO) "RPATH:				$(RPATH)"
	@$(ECHO) "FILE_WARNING_FLAGS:	$(FILE_WARNING_FLAGS)"
	@$(ECHO) "UNITTEST_LDLIBS:		$(UNITTEST_LDLIBS)"
	@$(ECHO) "UNITTEST_LINK_LIBS:	$(UNITTEST_LINK_LIBS)"
	@$(ECHO) "UNITTEST_CXXFLAGS:	$(UNITTEST_CXXFLAGS)"
	@$(ECHO) "LDLIBS_EXTERN_BUILD:	$(LDLIBS_EXTERN_BUILD)"
	@$(ECHO) "LDLIBS_EXTERN_SHARE:	$(LDLIBS_EXTERN_SHARE)"
	@$(ECHO) "INSTALL_CONFIG:		$(INSTALL_CONFIG)"
	@$(ECHO) "MODE_TEXT_COLOR		$(MODE_TEXT_COLOR)"
	@$(ECHO) "MOCK_HEADERS:			$(MOCK_HEADERS)"
	@$(ECHO) "MOCK_HEADER_INCLUDES_FILES: $(MOCK_HEADER_INCLUDES_FILES)"
	@echo    "ECHO:                 $(ECHO)"

tools:
	@$(ECHO) "PLATFORM:         $(PLATFORM)  $(PLATFORMVER)"
	@$(ECHO) "PLATFORM FLAGS:   $(PLATFORM_SPECIFIC_FLAGS)"
	@$(ECHO) "COMPILER FLAGS:   $(COMPILER_SPECIFIC_FLAGS)"
	@$(ECHO) "LANGUAGE FLAGS:   $(LANGUAGE_SPECIFIC_FLAGS)"
	@$(ECHO) "YACC:             $(YACC)"
	@$(ECHO) "LEX:              $(LEX)"
	@$(ECHO) "GPERF:            $(GPERF)"
	@$(ECHO) "CP:               $(CP)"
	@$(ECHO) "CXX:              $(CXX)   :  Name: $(COMPILER_NAME) Version:$(COMPILER_VERSION) Language:$(CXXSTDVER)"
	@$(ECHO) "COV:              $(COV)"

