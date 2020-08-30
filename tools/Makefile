
# Generic Makefile for all building.
#
SHELL=/bin/bash
#
# To use set the variable TARGET
# Then include this file.
# The TARGET variable may include multiple things to build
#
#
# A name with a *.app  extension is an executable			(the app will NOT be part of the final name)
# A name with a *.dir  extension builds a subdirectory
#
# Build a library.
# A name with a *.a    extension is a static library		(the lib prefix will automatically be added)
# A name with a *.slib extension is a shared library		(the lib prefix will automatically be added. And platform specific suffix will replace slib)
# A name with a *.head extension builds a header only library
#
# A name with a *.lib  extension is static or shared depending THOR_TARGETLIBS (this is usually defined by the configure script)
#					   if THOR_TARGETLIBS is empty it defaults to shared.
#					   for each value in THOR_TARGETLIBS it will add a version of the library to the target.
#						TARGET=XXX.lib THOR_TARGETLIBS="slib a"
#						NEW_TARGET=XXX.slib XXX.a
#
#		Note: This will build a shared library with the appropriate platform specific extension
#			  In the directory TARGET_Mode (debug/release)
#		Note: You can build multiple *.dir or *.app targets.
#				These will install an application in ${PREFIX_BIN}/<App-Name>
#			  But you can only build **ONE** lib
#			  A lib will consist of:
#					1) All the header files *.h *.tpp (in the current directory)
#					   Installed into ${PREFIX_INC}/<Lib-Name>/
#					2) A lib with the appropriate extension.
#					   Installed into ${PREFIX_LIB}/<Lib-Name><Type>.<Ext>
#					   It will be built from all the source files in the current directory.
#					   After removing any source files that match *.app target names.
#					   i.e. If you have a TARGET=bob.app glib.slib
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
#		make test COVERAGE=file.h	=> Display the coverage for file.h
#		make test COVERAGE=On		=> Display the coverage for ALL files
#
#	Run specific UNIT TEST
#		Note:	TestName	=> *
#							=> <ClassName>.*
#							=> <ClassName>.<TestMethod>
#
#		make test TESTNAME=<TestName>
#
#	Run Test and see coverage for that test on file:
#		make test TESTNAME=<TestName> COVERAGE=<FileName or On>
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

LOCAL_ROOT		?= $(shell pwd)

export PATH := $(BUILD_ROOT)/bin:$(PATH)

INSTALL_ACTIVE	?= NO

PREFIX?=$(BUILD_ROOT)
PREFIX_BIN?=$(BUILD_ROOT)/bin
PREFIX_LIB?=$(BUILD_ROOT)/lib
PREFIX_OBJ?=$(BUILD_ROOT)/obj
PREFIX_INC?=$(BUILD_ROOT)/include
PREFIX_MAN?=$(BUILD_ROOT)/share/man

ifeq ($(INSTALL_ACTIVE),YES)
PREFIX=${prefix}
PREFIX_BIN=${bindir}
PREFIX_LIB=${libdir}
PREFIX_INC=${includedir}
PREFIX_MAN=${mandir}
endif

COVERAGE_REQUIRED	?= 80

YACC			= bison
LEX				= flex
GPERF			= gperf --ignore-case
CP				= cp
MKDIR			= mkdir
RMDIR			= rmdir

CXX				?= g++
COV				?= gcov
VERA			?= $(if $(VERATOOL),$(VERATOOL), vera++)
MKTEMP			= $(MKTEMP_$(PLATFORM))
MAKE			= make --silent

TESTNAME		?= *
	
#
# This is obviously not working
# Need to look at this
COV_LONG_FLAG			= $(COV_LONG_FLAG_$(PLATFORM))
COV_LONG_FLAG_Linux		= --long-file-names
COV_LONG_FLAG_Darwin	= -p

MKTEMP_Darwin					= mktemp -u /tmp/tmp.XXXXXXXXXX
MKTEMP_Linux					= mktemp -u


#
# Add Files(without extension) that you do not want coverage metrics for
NOCOVERAGE		+= %.lex %.tab

THOR_TARGETLIBS				?= slib
TARGET_GENERIC_LIB			= $(patsubst %.lib, %, $(filter %.lib, $(TARGET)))
TARGET_GENERIC_EXPAND		= $(foreach exp, $(THOR_TARGETLIBS), $(foreach lib, $(TARGET_GENERIC_LIB), $(lib).$(exp)))
TARGET_ALL					= $(filter-out %.lib, $(TARGET)) $(TARGET_GENERIC_EXPAND)

APP_SRC						= $(filter %.cpp,$(patsubst %.app,%.cpp,$(TARGET_ALL)))
APP_HEAD					= $(filter %.h,$(patsubst %.app,%.h,$(TARGET_ALL)))
CPP_SRC						= $(filter-out %.lex.cpp %.tab.cpp %.gperf.cpp $(APP_SRC),$(wildcard *.cpp))
CPP_HDR						= $(filter-out %.lex.h   %.tab.h   %.gperf.h             ,$(wildcard *.h))
LEX_SRC						= $(wildcard *.l)
GPERF_SRC					= $(wildcard *.gperf)
YACC_SRC					= $(wildcard *.y)
TMP_SRC						= $(patsubst %.y,%.tab.cpp,$(YACC_SRC)) $(patsubst %.l,%.lex.cpp,$(LEX_SRC))
TMP_HDR						= $(patsubst %.y,%.tab.h,$(YACC_SRC)) $(patsubst %.l,%.lex.h,$(LEX_SRC))
SRC							= $(TMP_SRC) $(patsubst %.gperf,%.gperf.cpp,$(GPERF_SRC)) $(CPP_SRC)
HEAD						= $(filter-out $(EXCLUDE_HEADERS), $(wildcard *.h *.tpp)) $(EXTRA_HEADERS)
OBJ							= $(patsubst %.cpp,$(TARGET_MODE)/%.o,$(SRC))
VERA_SRC					= $(filter-out $(TEST_IGNORE), $(CPP_SRC) $(APP_SRC) $(filter-out %Config.h, $(CPP_HDR)) $(wildcard *.tpp))
VERA_OBJ					= $(patsubst %,vera/%.vera, $(VERA_SRC))
GCOV_OBJ					= $(filter-out coverage/main.o,$(OBJ)) $(MOCK_OBJECT)
GCOV_BASIC_SRC				= $(patsubst coverage/%.o, coverage/%.cpp.gcov, $(filter-out $(MOCK_OBJECT) $(APP_SRC) ,$(GCOV_OBJ))) $(patsubst %.tpp,coverage/%.tpp.gcov, $(wildcard *.tpp))
GCOV_BASIC_HEAD				= $(patsubst %, coverage/%.gcov, $(filter-out $(APP_HEAD) %Config.h,$(wildcard *.h)))
GCOV_SRC					= $(filter-out $(foreach nocoverage,$(TEST_IGNORE),coverage/$(nocoverage).gcov), $(GCOV_BASIC_SRC))
GCOV_HEAD					= $(filter-out $(foreach nocoverage,$(TEST_IGNORE),coverage/$(nocoverage).gcov), $(GCOV_BASIC_HEAD))
GCOV_LIB					= $(if $(GCOV_OBJ),objectarch)
GCOV_LIBOBJ					= $(if $(GCOV_OBJ),-lobject)
MAN_SRC						= $(wildcard man/man*/*)
MAN_DIR						= $(patsubst man/%, $(PREFIX_MAN)/%.Dir, $(sort $(dir $(MAN_SRC))))
MAN_PAGE					= $(patsubst man/%, $(PREFIX_MAN)/%.man, $(MAN_SRC))
DEFER_OBJX					= $(foreach lib, $(wildcard $(PREFIX_OBJ)/$(lib)/$(TARGET_MODE)/*.o), $(DEFER_LIBS))
DEFER_OBJDIR				= $(foreach lib, $(DEFER_LIBS), $(PREFIX_OBJ)/$(lib)/$(TARGET_MODE))
DEFER_OBJ					= $(foreach dir, $(DEFER_OBJDIR), $(wildcard $(dir)/*.o))


NOTHING						:=
SPACE						:=$(NOTHING) $(NOTHING)
LDLIBS_EXTERN_LIB_LOC		= $(foreach lib, $(LDLIBS_EXTERN_BUILD), $(if $($(lib)_ROOT_DIR), -L$($(lib)_ROOT_DIR)/lib))
LDLIBS_EXTERN_INC_LOC		= $(foreach lib, $(LDLIBS_EXTERN_BUILD), $(if $($(lib)_ROOT_DIR), -I$($(lib)_ROOT_DIR)/include))
LDLIBS_EXTERN_SHARE			= $(foreach lib, $(LDLIBS_EXTERN_BUILD), -l${lib})
LDLIBS_EXTERN_PATH			= $(subst $(SPACE),:,$(strip $(foreach lib, $(LDLIBS_EXTERN_BUILD), $(if $($(lib)_ROOT_DIR),$($(lib)_ROOT_DIR)/lib))))
LDLIBS_EXTERN_RPATH			+=$(if $(LDLIBS_EXTERN_PATH),export RPATH=$(LDLIBS_EXTERN_PATH);)
LDLIBS						+= $(LDLIBS_EXTERN_LIB_LOC) $(LDLIBS_EXTERN_SHARE)
CXXFLAGS					+= $(LDLIBS_EXTERN_INC_LOC) $(BOOST_CPPFLAGS) $(TEST_PATH) $(UNITTEST_CXXFLAGS)
CPPFLAGS					+= $(BOOST_CPPFLAGS)
LDFLAGS						+= $(BOOST_LDFLAGS)

GCOV_REPORT					= $(patsubst coverage/%.gcov, %_report_coverage, $(GCOV_SRC)) $(patsubst coverage/%.gcov, %_report_coverage, $(GCOV_HEAD))
LIBBASENAME_ONE_OF			= $(patsubst %.a,    %, $(filter %.a,    $(TARGET)))	\
							  $(patsubst %.slib, %, $(filter %.slib, $(TARGET)))	\
							  $(patsubst %.lib,  %, $(filter %.lib,  $(TARGET)))	\
							  $(patsubst %.head, %, $(filter %.head, $(TARGET)))	\
							  $(patsubst %.defer,%, $(filter %.defer,$(TARGET)))
LIBBASENAME_ACTUAL			= $(strip $(firstword $(LIBBASENAME_ONE_OF)))
USE_HEADER					= $(if $(NO_HEADER),NO,YES)
LIBBASENAME_NO_NO			= $(LIBBASENAME_ACTUAL)
LIBBASENAME_YES_NO			= $(LIBBASENAME_ACTUAL)
LIBBASENAME_YES_YES			= $(LIBBASENAME_ACTUAL)
#
# If we don't want headers and this is a full install
# Then don't do any work with the headers (ie. don't install into /usr/local/include)
# All other situations above we make a copy locally.
LIBBASENAME_NO_YES			= 
LIBBASENAME					= $(LIBBASENAME_$(USE_HEADER)_$(INSTALL_ACTIVE))

INSTALL_APP					= $(patsubst %.app,   install_app_%, $(filter %.app,  $(TARGET_ALL)))
INSTALL_SHARED_LIB			= $(patsubst %.slib,  install_shared_lib_%, $(filter %.slib, $(TARGET_ALL)))
INSTALL_STATIC_LIB			= $(patsubst %.a,     install_static_lib_%, $(filter %.a,    $(TARGET_ALL)))
INSTALL_HEADER				= $(patsubst %, install_head_%, $(LIBBASENAME))
DEFER_NAME					= $(patsubst %.defer, %, $(filter %.defer, $(TARGET_ALL)))
INSTALL_DEFER_OBJ			= $(patsubst %, install_defer_$(INSTALL_ACTIVE)_%, $(DEFER_NAME))
INSTALL_DEFER				= $(INSTALL_DEFER_OBJ) $(patsubst %, install_lib_defer_$(INSTALL_ACTIVE)_%, $(DEFER_NAME))

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
WARNING_FLAGS_				=	-Wall -Wextra -Wstrict-aliasing $(THORSANVIL_ANSI) -pedantic -Werror -Wunreachable-code -Wno-long-long -Wdeprecated -Wdeprecated-declarations

THORSLINKDIRS				=	$(PREFIX_LIB) $(filter -L%, %, $(LDFLAGS)) ${libdir}
findfullpath				=	$(firstword $(foreach dir, $(1), $(realpath $(dir)/$(2))))
expand						=	$(foreach lib, $(1), -l$(lib)$(BUILD_EXTENSION))
expandStatic				=	$(foreach lib, $(1), $(call findfullpath, $(THORSLINKDIRS),lib$(lib)$(BUILD_EXTENSION).a))
expandFlag					=   $(foreach flag, $(1), $(flag))
THORSANVIL_FLAGS			=	-I$(PREFIX_INC)
THORSANVIL_LIBS				=	-L$(PREFIX_LIB) $(call expand,$(LINK_LIBS))
THORSANVIL_STATICLOADALL	=   $(if $(LINK_SLIBS), $(THOR_STATIC_LOAD_FLAG) $(call expandStatic,$(LINK_SLIBS)) $(THOR_STATIC_NOLOAD_FLAG))


TEST_FLAGS					=	$(TEST_FLAGS_$(TEST_STATE))
TEST_LIBS					=	$(TEST_LIBS_$(TEST_STATE)) -fprofile-arcs -ftest-coverage -lpthread
TEST_FLAGS_on				=	-I..
TEST_LIBS_on				=	-L../coverage -L$(THORSANVIL_ROOT)/build/lib $(GCOV_LIBOBJ_PASS) -lgtest
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
OPTIMIZER_FLAGS_HIDE_profile	=	-g -pg -DPROFILE_TEST

CC							=	$(CXX)
CXXFLAGS					+=	-fPIC $(WARNING_FLAGS) $(THORSANVIL_FLAGS) -isystem $(PREFIX_INC3RD) $(TEST_FLAGS) $(OPTIMIZER_FLAGS) $(ENVIRONMENT_FLAGS) $(CXX_STD_FLAG)
ALL_LDLIBS					+=	$(TEST_LIBS) $(OPTIMIZER_LIBS) $(THORSANVIL_LIBS)

MOCK_HEADERS_coverage		=	-include coverage/MockHeaders.h
MOCK_FILES_coverage			=	$(BASE)/coverage/MockHeaders.h $(BASE)/coverage/MockHeaders.cpp
MOCK_OBJECT_coverage		=	$(BASE)/coverage/MockHeaders.o
MOCK_HEADERS				=	$(MOCK_HEADERS_$(TARGET_MODE))
MOCK_FILES					=	$(MOCK_FILES_$(TARGET_MODE))
MOCK_OBJECT					=	$(MOCK_OBJECT_$(TARGET_MODE))

PREFIX						?=	$(BUILD_ROOT)
PREFIX_BIN					?=	$(PREFIX)/bin
PREFIX_LIB					?=	$(PREFIX)/lib
PREFIX_INC					?=	$(PREFIX)/include
PREFIX_INC3RD				?=	$(THORSANVIL_ROOT)/build/include3rd
BUILD_EXTENSION				=	$(CXXSTDVER)$(BUILD_EXTENSION_TYPE_$(TARGET_MODE))
BUILD_EXTENSION_TYPE_debug		=	D
BUILD_EXTENSION_TYPE_coverage	=	D
BUILD_EXTENSION_TYPE_profile	=	P

RUNTIME_PATH				= $(shell $(ECHO) $(PREFIX_LIB) $(UNITTEST_RUNTIME_PATH) $($(RUNTIME_SHARED_PATH_SET))| sed '-e s/ /:/')


#
# For reference the default rules are
#	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS)
#	$(CC) $(LDFLAGS) N.o $(LOADLIBES) $(LDLIBS)

.PHONY:	all validate install lint objectarch gcovarch clean veryclean test mock coverage coveragetest debug release profile header_only install_dir
.PHONY:	installAction install_app install_shared_lib install_static_lib install_head try_install_app try_install_shared_lib try_install_static_lib try_install_head
.PHONY:	doInstall install_Dodebug install_Dorelease install_Doprofile install_Dohead
.PHONY:	cleanAction clean_app clean_shared_lib clean_static_lib clean_head try_clean_app try_clean_shared_lib try_clean_static_lib try_clean_head
.PHONY:	doClean clean_Dodebug clean_Dorelease clean_Doprofile clean_Dohead


all:	PrintDebug buildDir Note_Building_$(TARGET_MODE) $(TARGET_ALL)
	@$(ECHO) $(call colour_text, BLUE, "Done")
validate:		test
install:		test
	$(MAKE)             BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=$(TARGET_MODE) INSTALL_ACTIVE=YES  installAction
installAction:	Print_On install_Dohead install_Dodebug install_Dorelease man
cleanAction:	clean_Dohead clean_Dodebug clean_Dorelease clean_Dodefer clean_man
install_debug:	test install_Dohead install_Dodebug
install_release:test install_Dohead install_Dorelease
install_profile:     install_Dohead install_Doprofile
header_only:	test install_Dohead
build:			test install_Dohead install_Dodebug install_Dorelease
lint:			doLint

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

	
install_Dodebug:
	$(MAKE) $(PARALLEL) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=debug INSTALL_ACTIVE=$(INSTALL_ACTIVE) all
	$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=debug doInstall
install_Dorelease:
	$(MAKE) $(PARALLEL) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=release INSTALL_ACTIVE=$(INSTALL_ACTIVE) all
	$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=release doInstall
install_Doprofile:
	$(MAKE) $(PARALLEL) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=profile INSTALL_ACTIVE=$(INSTALL_ACTIVE) all
	$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=profile doInstall
install_Dohead:
	$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=profile INSTALL_ACTIVE=$(INSTALL_ACTIVE) try_install_head

doInstall:	try_install_app try_install_shared_lib try_install_static_lib try_install_defer

clean_Dodebug:
	$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=debug doClean
clean_Dorelease:
	$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=release doClean
clean_Doprofile:
	$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=profile doClean
clean_Dodefer:
	$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=profile try_clean_defer_root
clean_Dohead:
	$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=profile INSTALL_ACTIVE=$(INSTALL_ACTIVE) try_clean_head

doClean:	try_clean_app try_clean_shared_lib try_clean_static_lib try_clean_defer

try_install_app:		$(if $(INSTALL_APP), install_app)
try_install_shared_lib:	$(if $(INSTALL_SHARED_LIB), install_shared_lib)
try_install_static_lib:	$(if $(INSTALL_STATIC_LIB), install_static_lib)
try_install_head:		$(if $(INSTALL_HEADER), install_head)
try_install_defer:		$(if $(INSTALL_DEFER), install_defer)
try_clean_app:			$(if $(INSTALL_APP), clean_app)
try_clean_shared_lib:	$(if $(INSTALL_SHARED_LIB), clean_shared_lib)
try_clean_static_lib:	$(if $(INSTALL_STATIC_LIB), clean_static_lib)
try_clean_head:			$(if $(INSTALL_HEADER), clean_head)
try_clean_defer:		$(if $(INSTALL_DEFER), clean_defer)
try_clean_defer_root:	$(if $(INSTALL_DEFER), clean_defer_root)

install_app:		Note_Start_Installing_Applications $(INSTALL_APP)           Note_End_Installing_Applications
install_shared_lib:	Note_Start_Installing_Libraries    $(INSTALL_SHARED_LIB)    Note_End_Installing_Libraries
install_static_lib:	Note_Start_Installing_Libraries    $(INSTALL_STATIC_LIB)    Note_End_Installing_Libraries
install_head:		Note_Start_Installing_Headers      $(INSTALL_HEADER)        Note_End_Installing_Headers
install_defer:		Note_Start_Installing_DeferLib     $(INSTALL_DEFER)         Note_End_Installing_DeferLib
clean_app:			Note_Start_Clean_Applications      $(patsubst install_%, clean_%, $(INSTALL_APP))           Note_End_Clean_Applications
clean_shared_lib:	Note_Start_Clean_Libraries         $(patsubst install_%, clean_%, $(INSTALL_SHARED_LIB))    Note_End_Clean_Libraries
clean_static_lib:	Note_Start_Clean_Libraries         $(patsubst install_%, clean_%, $(INSTALL_STATIC_LIB))    Note_End_Clean_Libraries
clean_head:			Note_Start_Clean_Headers           $(patsubst install_%, clean_%, $(INSTALL_HEADER))        Note_End_Clean_Headers
clean_defer:		Note_Start_Clean_Defer_$(TARGET_MODE) $(patsubst install_%, clean_%, $(INSTALL_DEFER))      Note_End_Clean_Defer_$(TARGET_MODE)
clean_defer_root:	Note_Start_Clean_Defer_Root        $(patsubst install_%, root_clean_%, $(INSTALL_DEFER_OBJ))    Note_End_Clean_Defer_Root

Note_%:
	@$(ECHO) $(call section_title, $(subst _, ,$*))

%.cpp:	%.h
	
objectarch:	buildDir $(GCOV_OBJ) $(TARGET_MODE)/libobject.a
	@$(ECHO) $(call colour_text, BLUE, "Done")
gcovarch:	$(GCOV_LIB)
clean:
	$(RM) $(GCOV_OBJ) $(GCOV_SRC) $(GCOV_HEAD) $(TMP_SRC) $(TMP_HDR) makefile_tmp
	$(RM) $(patsubst %.y,%.tab.cpp,$(YACC_SRC)) $(patsubst %.y,%.tab.hpp,$(YACC_SRC)) $(patsubst %.l,%.lex.cpp,$(LEX_SRC)) $(patsubst %.gperf,%.gperf.cpp,$(GPERF_SRC)) $(CLEAN_EXTRA)
	$(RM) $(TARGET_ALL) $(patsubst %.app,%,$(filter %.app,$(TARGET_ALL))) $(patsubst %,$(TARGET_MODE)/%,$(filter %.app,$(TARGET_ALL)))
	$(RM) $(LIBBASENAME_ACTUAL)TestMarker.cpp
	$(RM) -rf debug release coverage profile test/coverage $(TMP_SRC) $(TMP_HDR)
	$(RM) -rf *.gcov test/*.gcov
veryclean: clean cleanAction

man:		$(MAN_PAGE)
clean_man:

$(PREFIX_MAN)/%.man:	man/%	$(MAN_DIR)
	cp man/$* $(PREFIX_MAN)/$*
test:	pre_test build_unit_test run_unit_test static_test
testonly:
	make pre_test build_unit_test run_unit_test_only
test-%:
	TESTNAME=$* make pre_test build_unit_test run_unit_test_only

testrun.%:	pre_test build_unit_test
	DYLD_LIBRARY_PATH=$(PREFIX_LIB)/lib:/usr/local/lib test/coverage/unittest.app --gtest_filter=$*

debugrun.%: pre_test build_unit_test
	DYLD_LIBRARY_PATH=$(PREFIX_LIB)/lib:/usr/local/lib lldb -- test/coverage/unittest.app --gtest_filter=$*

pre_test:	$(PRETEST)

static_test:
	@if [[ "$(TESTNAME)" == "*" ]]; then					\
		make vera;											\
	fi
vera:	vera.Dir vera_head vera_body
vera_head:
	@$(ECHO) $(call section_title,Static Analysis)
vera_body:	$(VERA_OBJ)
build_unit_test:
	@-$(RM) -rf coverage/libobject.a coverage/*gcov coverage/*.gcda test/coverage/unittest.app test/coverage/*gcov test/coverage/*gcda
	@$(ECHO) $(call section_title,Building Objects for Testing and Coverage)
	@echo "int ThorsAnvilUnitTestMarker = 1;" > ThorsAnvilUnitTestMarker.cpp
	@$(MAKE) $(PARALLEL) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=coverage INSTALL_ACTIVE=$(INSTALL_ACTIVE) gcovarch
	@rm ThorsAnvilUnitTestMarker.cpp
	@$(ECHO) $(call section_title,Building Unit Tests)
	@result=0;												\
	if ( test -d test ); then								\
		touch test/unittest.cpp;							\
		$(MAKE) $(PARALLEL) BASE=.. VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=coverage INSTALL_ACTIVE=$(INSTALL_ACTIVE) -C test -f ../Makefile THORSANVIL_ROOT=$(THORSANVIL_ROOT) BUILD_ROOT=$(BUILD_ROOT) LOCAL_ROOT=$(LOCAL_ROOT) TEST_STATE=on TARGET=unittest.app LINK_LIBS="$(UNITTEST_LINK_LIBS)" LDLIBS="$(UNITTEST_LDLIBS)" COVERAGE_TARGET="$(COVERAGE_TARGET)" GCOV_LIBOBJ_PASS="$(GCOV_LIBOBJ)";	\
		result=$$?;											\
		$(RM)    test/unittest.cpp;							\
	fi;														\
	exit $${result}

run_unit_test_only:
	@if ( test -d test ); then								\
		$(ECHO) $(call section_title,Running Unit Tests);	\
		$(ECHO) "$(RUNTIME_SHARED_PATH_SET)=$(RUNTIME_PATH):$(LDLIBS_EXTERN_PATH) test/coverage/unittest.app --gtest_filter=$(TESTNAME)";	\
		$(RUNTIME_SHARED_PATH_SET)=$(RUNTIME_PATH):$(LDLIBS_EXTERN_PATH) test/coverage/unittest.app --gtest_filter=$(TESTNAME) ||	\
							($(ECHO) "$(RUNTIME_SHARED_PATH_SET)=$(RUNTIME_PATH):$(LDLIBS_EXTERN_PATH) lldb test/coverage/unittest.app" && exit 1);\
	fi

run_unit_test:
	@if ( test -d test ); then								\
		$(ECHO) $(call section_title,Running Unit Tests);	\
		$(ECHO) "$(RUNTIME_SHARED_PATH_SET)=$(RUNTIME_PATH):$(LDLIBS_EXTERN_PATH) test/coverage/unittest.app --gtest_filter=$(TESTNAME)";	\
		$(RUNTIME_SHARED_PATH_SET)=$(RUNTIME_PATH):$(LDLIBS_EXTERN_PATH) test/coverage/unittest.app --gtest_filter=$(TESTNAME) ||	\
							($(ECHO) "$(RUNTIME_SHARED_PATH_SET)=$(RUNTIME_PATH):$(LDLIBS_EXTERN_PATH) lldb test/coverage/unittest.app" && exit 1);	\
		if [[ "$(TESTNAME)" == "*" ]]; then					\
			$(MAKE) BASE=.. VERBOSE=Min PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=coverage INSTALL_ACTIVE=$(INSTALL_ACTIVE) -C test -f ../Makefile coveragetest THORSANVIL_ROOT=$(THORSANVIL_ROOT) COVERAGE=$(COVERAGE);	\
			$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=coverage INSTALL_ACTIVE=$(INSTALL_ACTIVE) coverage COVERAGE=$(COVERAGE);	\
		fi													\
	fi

install_app_%:
	@$(MKDIR) -p $(PREFIX_BIN)
	@$(CP) $(TARGET_MODE)/$*.app $(PREFIX_BIN)/$*$(BUILD_EXTENSION)
	@$(ECHO) $(call subsection_title, Install - $(TARGET_MODE) - $*$(BUILD_EXTENSION))

install_shared_lib_%:
	@$(MKDIR) -p $(PREFIX_LIB)
	@$(CP) $(TARGET_MODE)/lib$*.$(SO) $(PREFIX_LIB)/lib$*$(BUILD_EXTENSION).$(SO)
	@$(ECHO) $(call subsection_title, Install - $(TARGET_MODE) - lib$*$(BUILD_EXTENSION).$(SO))

install_static_lib_%:
	@$(MKDIR) -p $(PREFIX_LIB)
	@$(CP) $(TARGET_MODE)/lib$*.a $(PREFIX_LIB)/lib$*$(BUILD_EXTENSION).a
	@$(ECHO) $(call subsection_title, Install - $(TARGET_MODE) - lib$*$(BUILD_EXTENSION).a)

install_defer_YES_%:
	# Do nothng
#
# Deferred objects are not installed into the main system.
# They are only installed when INSTALL_ACTIVE is not set and thus built into the build directory
# When the deferred library is then build it will use these object to build the appropriate
# library object.

install_defer_NO_%:
	@$(MKDIR) -p $(PREFIX_OBJ)/$*/$(TARGET_MODE)
	@for obj in $(OBJ); do base=$$(basename $${obj});$(CP) $${obj} $(PREFIX_OBJ)/$*/$(TARGET_MODE)/$${base}; done
	@$(ECHO) $(call subsection_title, Install Defer $*)

install_lib_defer_YES_%:
	# Do nothng
install_lib_defer_NO_%:
	$(CP) $(TARGET_MODE)/lib$*$(BUILD_EXTENSION).a $(PREFIX_LIB)/

install_head_%:
	@$(MKDIR) -p $(PREFIX_INC)/$*
	for head in $(HEAD); do $(CP) $${head} $(PREFIX_INC)/$*/;done
	@$(ECHO) $(call subsection_title, Install Header $*)

clean_app_%:
	@$(ECHO) $(call subsection_title, Clean - $(TARGET_MODE) - $*$(BUILD_EXTENSION))
	@$(RM) $(PREFIX_BIN)/$*$(BUILD_EXTENSION)

clean_shared_lib_%:
	@$(ECHO) $(call subsection_title, Clean - $(TARGET_MODE) - lib$*$(BUILD_EXTENSION).$(SO))
	@$(RM) $(PREFIX_LIB)/lib$*$(BUILD_EXTENSION).$(SO)

clean_static_lib_%:
	@$(ECHO) $(call subsection_title, Clean - $(TARGET_MODE) - lib$*$(BUILD_EXTENSION).a)
	@$(RM) $(PREFIX_LIB)/lib$*$(BUILD_EXTENSION).a

clean_head_%:
	@$(ECHO) $(call subsection_title, Clean Header $*)
	@for head in $(HEAD); do $(RM) -f $(PREFIX_INC)/$*/$${head};done
	@if [[ -e $(PREFIX_INC)/$*/ ]]; then $(RMDIR) $(PREFIX_INC)/$*/; fi

clean_defer_YES_%:
	@# nothing to do
clean_defer_NO_%:
	@$(ECHO) $(call subsection_title, Clean Defer $(TARGET_MODE) $*)
	@for obj in $(OBJ); do base=$$(basename $${obj});$(RM) -f $(PREFIX_OBJ)/$*/$(TARGET_MODE)/$${base}; done
	@if [[ -e $(PREFIX_OBJ)/$*/$(TARGET_MODE) ]]; then $(RMDIR) $(PREFIX_OBJ)/$*/$(TARGET_MODE); fi
clean_lib_defer_YES_%:
	@# nothing to do
clean_lib_defer_NO_%:
	@$(RM) $(PREFIX_LIB)/lib$*$(BUILD_EXTENSION).a
root_clean_defer_YES_%:
	@# nothing to do
root_clean_defer_NO_%:
	@$(ECHO) $(call subsection_title, Clean Defer $* ROOT)
	@if [[ -e $(PREFIX_OBJ)/$*/ ]]; then $(RMDIR) $(PREFIX_OBJ)/$*/; fi


test_%:
	@if [ -d test ]; then $(MAKE) -C test -f ../Makefile BASE=.. THORSANVIL_ROOT=$(THORSANVIL_ROOT) BUILD_ROOT=$(BUILD_ROOT) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) INSTALL_ACTIVE=$(INSTALL_ACTIVE) TEST_STATE=on TARGET=unittest.app TESTNAME=$*; fi

mock:	coverage.Dir $(MOCK_FILES)
	$(ECHO) "MOCKING: $(TARGET_MODE) $(MOCK_FILES)"

$(BASE)/coverage/Mock.built:
$(BASE)/coverage/MockHeaders.h: $(BASE)/coverage/Mock.built | $(BASE)/coverage.Dir
	@touch $(BASE)/coverage/Mock.built
	@cp $(THORSANVIL_ROOT)/build/mock/MockHeaders.h.prefix $(BASE)/coverage/MockHeaders.h
	@if [[ -e $(BASE)/test/Mock.def ]]; then \
		perl -ne '/(#include .*)/ and print "$$1\n"' $(BASE)/test/Mock.def >> $(BASE)/coverage/MockHeaders.h; \
		cat $(THORSANVIL_ROOT)/build/mock/MockHeaders.h.preamb >> $(BASE)/coverage/MockHeaders.h; \
		perl -ne '/MOCK_SYSTEM_FUNC\(([^)]*)\)/ and print "extern std::function<RemoveNoExceptType<decltype(::$$1)>> mock$$1;\n"' $(BASE)/test/Mock.def >> $(BASE)/coverage/MockHeaders.h; \
		cat $(THORSANVIL_ROOT)/build/mock/MockHeaders.h.median >> $(BASE)/coverage/MockHeaders.h; \
		perl -ne '/MOCK_SYSTEM_FUNC\(([^)]*)\)/ and print "#define $$1 ThorsAnvil::BuildTools::Mock::mock$$1\n"' $(BASE)/test/Mock.def >> $(BASE)/coverage/MockHeaders.h;\
	fi
	@cat $(THORSANVIL_ROOT)/build/mock/MockHeaders.h.suffix >> $(BASE)/coverage/MockHeaders.h

$(BASE)/coverage/ThorMock.h: $(BASE)/coverage/MockHeaders.h | $(BASE)/coverage.Dir
	@cp $(THORSANVIL_ROOT)/build/mock/ThorMock.h.prefix $(BASE)/coverage/ThorMock.h
	@cat $(THORSANVIL_ROOT)/build/mock/ThorMock.h.preamb >> $(BASE)/coverage/ThorMock.h
	@if [ -e $(BASE)/test/Mock.def ]; then		\
		perl -ne '/MOCK_SYSTEM_FUNC\(([^)]*)\)/ and print "#undef $$1\n"' $(BASE)/test/Mock.def >> $(BASE)/coverage/ThorMock.h; \
	fi
	@cat $(THORSANVIL_ROOT)/build/mock/ThorMock.h.median >> $(BASE)/coverage/ThorMock.h
	@cat $(THORSANVIL_ROOT)/build/mock/ThorMock.h.suffix >> $(BASE)/coverage/ThorMock.h

$(BASE)/coverage/MockHeaders.cpp:: $(BASE)/coverage/MockHeaders.h | $(BASE)/coverage.Dir
	@cp $(THORSANVIL_ROOT)/build/mock/MockHeaders.cpp.prefix $(BASE)/coverage/MockHeaders.cpp
	@cat $(THORSANVIL_ROOT)/build/mock/MockHeaders.cpp.preamb >> $(BASE)/coverage/MockHeaders.cpp
	@if [ -e $(BASE)/test/Mock.def ]; then		\
		perl -ne '/MOCK_SYSTEM_FUNC\(([^)]*)\)/ and print "#undef $$1\n"' $(BASE)/test/Mock.def >> $(BASE)/coverage/MockHeaders.cpp; \
	fi
	@cat $(THORSANVIL_ROOT)/build/mock/MockHeaders.cpp.median >> $(BASE)/coverage/MockHeaders.cpp
	@if [ -e $(BASE)/test/Mock.def ]; then		\
		perl -ne '/MOCK_SYSTEM_FUNC\(([^)]*)\)/ and print "std::function<RemoveNoExceptType<decltype(::$$1)>> mock$$1 = $$1;\n"' $(BASE)/test/Mock.def >> $(BASE)/coverage/MockHeaders.cpp; \
	fi
	@cat $(THORSANVIL_ROOT)/build/mock/MockHeaders.cpp.suffix >> $(BASE)/coverage/MockHeaders.cpp

cleanCoverage: always
	rm -f coverage/*.gcov

coveragetest: cleanCoverage $(GCOV_SRC)
coverage: cleanCoverage $(GCOV_REPORT)
	linesNotTested=`echo | cat $(GCOV_SRC) $(GCOV_HEAD) - | grep '####' | wc -l`;		\
	linesTestable=`echo | cat $(GCOV_SRC) $(GCOV_HEAD) - | grep -v '\-:' | wc -l`;		\
	linesTested=$$(($${linesTestable}-$${linesNotTested}));			\
	if [ $${linesTestable} == 0 ]; then								\
		coverage=100;												\
	else															\
		linesTested100=$$(($${linesTested}*100));					\
		coverage=$$(($${linesTested100}/$${linesTestable}));		\
	fi;																\
	res=`$(ECHO) "scale=2;$${linesNotTested} > ($${linesTestable} * ((100-$(COVERAGE_REQUIRED))/100))" | bc`;				\
	$(ECHO) "Use: '$(MAKE) test BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) INSTALL_ACTIVE=$(INSTALL_ACTIVE) COVERAGE=On' to get details about coverage";		\
	if [ $${res} -ne 0 ]; then										\
		$(ECHO) $(RED_ERROR) $(call colour_text, PURPLE, Code Coverage $${coverage}% does not exceed $(COVERAGE_REQUIRED)% of total);	\
		$(ECHO) "Use: '$(MAKE) test BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) INSTALL_ACTIVE=$(INSTALL_ACTIVE) COVERAGE=On' to get details about coverage";		\
		exit 1;														\
	else															\
		$(ECHO) $(GREEN_OK) $(call colour_text, PURPLE, Code Coverage) $${coverage}% $(call colour_text, PURPLE, exceed $(COVERAGE_REQUIRED)% of total);	\
	fi
	@$(RM) *.gcov test/*.gcov

coverage/%.cpp.gcov: always
	@if ( test "$(VERBOSE)" = "Min" ); then					\
		$(ECHO) "Generating Coverage for $*.cpp";			\
	fi
	@if ( test "$(VERBOSE)" = "On" ); then					\
		$(ECHO) "Generating Coverage for $*.cpp";			\
		$(ECHO) '$(COV) --preserve-paths --object-directory coverage $*.cpp' ;	\
	fi
	@if [ -e $*.cpp ]; then									\
		tmpfile=$(shell $(MKTEMP));							\
		tmpSed=$(shell $(MKTEMP));							\
		touch coverage/$*.cpp.gcov;							\
		if ( test "$(VERBOSE)" = "On" ); then				\
			$(ECHO) $(COV) $(COV_LONG_FLAG) --object-directory coverage $*.cpp ;	\
		fi;													\
		$(COV) $(COV_LONG_FLAG) --object-directory coverage $*.cpp 2>$${tmpfile}	> coverage/$*.cpp.out ;	\
		if [[ -e $*.cpp.gcov ]]; then						\
			sed 's/#####\(.*\)}$$/    -\1}/' $*.cpp.gcov > $${tmpSed};\
			sed 's/#####\(.*\)\(throw std::domain_error\)/    -\1\2/' $${tmpSed} > $*.cpp.gcov;\
		fi;													\
		if [ $$? != 0 ];									\
		then												\
			$(ECHO) $(RED_ERROR);							\
			$(ECHO) $(COV) $(COV_LONG_FLAG) --object-directory coverage $*.cpp ;	\
			$(ECHO) "====================================";	\
			cat $${tmpfile};								\
			exit 1;											\
		else 												\
			if ( test "$(VERBOSE)" = "On" ); then			\
				$(ECHO) $(call colour_text, GRAY, "$(COV) coverage $*.cpp") | awk '{printf "%-80s", $$0}' ; \
				$(ECHO) $(GREEN_OK);						\
			fi;												\
			$(RM) -f $${tmpfilea} $${tmpSed};				\
		fi													\
	fi
	@if ( test "$(VERBOSE)" = "On" ); then					\
		$(ECHO) "Done";										\
	fi
	@if [ -e $*.tpp.gcov ]; then mv $*.tpp.gcov coverage/; fi;
	@if [ -e $*.cpp.gcov ]; then mv $*.cpp.gcov coverage/; fi;
	@tmpHead=$(shell $(MKTEMP));							\
	for h in $$(ls *.h.gcov 2> /dev/null); do				\
		touch coverage/$$h;									\
		cat $$h coverage/$$h | sort -n -k 2 | awk 'BEGIN {id=0;count=0;used=0;line=""} {if ($$2 != id){print line;id=$$2;count=0;used=0;line="";}} /^ *#####:/ {if (used == 0) {line=$$0}next} /^ * -:/ {if (used == 0){line=$$0}next} {used=1;line=$$0;}' > $${tmpHead}; \
		mv $${tmpHead} coverage/$$h;						\
	done



coverage/%.tpp.gcov: coverage/%.cpp.gcov
	@if ( test "$(VERBOSE)" = "On" ); then					\
		$(ECHO) Do Nothing;									\
	fi
	touch coverage/$*.tpp.gcov
coverage/%.h.gcov:
	@if ( test "$(VERBOSE)" = "On" ); then					\
		$(ECHO) "Generating Coverage for $*.h";				\
	fi
	@if [ -e $*.h ]; then									\
		tmpSed=$(shell $(MKTEMP));							\
		tmpHead=$(shell $(MKTEMP));							\
		touch coverage/$*.h.gcov;							\
		input1=$$(ls coverage/*$*.h.gcov 2> /dev/null);		\
		input2=$$(ls test/coverage/*$*.h.gcov 2> /dev/null);\
		cat coverage/$*.h.gcov $${input1} $${input2} | sort -n -k 2 | awk 'BEGIN {id=0;used=0;line=""} {if ($$2 != id){print line;id=$$2;used=0;line="";}} /^ *#####:/ {if (used == 0) {line=$$0}next} /^ * -:/ {if (used == 0){line=$$0}next} {used=1;line=$$0;}' > $${tmpHead}; \
		sed 's/#####\(.*\)}$$/    -\1}/' $${tmpHead} > $${tmpSed};\
		sed 's/#####\(.*\)\(throw std::domain_error\)/    -\1\2/' $${tmpSed} > coverage/$*.h.gcov;\
		grep -v '^ *-:' coverage/$*.h.gcov | awk -F: 'BEGIN {id=0;used=0;count=0;exe=0} {if ($$2 != id){id=$$2;count++;if (used == 1){used=0;exe++;}}} /#####/ {next} {used=1} END {if (used == 1){exe++;}if (count != 0){printf("Lines executed: %.2f%% of %d\n", exe * 100 / count, count);}else{}printf("Lines executed: 00.00%%\n");}' > coverage/$*.h.out; \
		if ( test "$(VERBOSE)" = "On" ); then				\
			$(ECHO) $(call colour_text, GRAY, "$(COV) coverage $*.h") | awk '{printf "%-80s", $$0}' ; \
			$(ECHO) $(GREEN_OK);							\
		fi;													\
		$(RM) -f $${tmpHead} $${tmpSed};					\
	fi
	@if ( test "$(VERBOSE)" = "On" ); then					\
		$(ECHO) "Done";										\
	fi

coverage/%*.h.out: coverage/%.h.gcov
	@if ( test "$(VERBOSE)" = "On" ); then					\
		$(ECHO) "Generating Coverage Output for $*.h";		\
	fi
	@if [ -e $*.h ]; then									\
		tmpSed=$(shell $(MKTEMP));							\
		tmpHead=$(shell $(MKTEMP));							\
		touch coverage/$*.h.gcov;							\
		input1=$$(ls coverage/*$*.h.gcov 2> /dev/null);		\
		input2=$$(ls test/coverage/*$*.h.gcov 2> /dev/null);\
		cat coverage/$*.h.gcov $${input1} $${input2} | sort -n -k 2 | awk 'BEGIN {id=0;used=0;line=""} {if ($$2 != id){print line;id=$$2;used=0;line="";}} /^ *#####:/ {if (used == 0) {line=$$0}next} /^ * -:/ {if (used == 0){line=$$0}next} {used=1;line=$$0;}' > $${tmpHead}; \
		sed 's/#####\(.*\)}$$/    -\1}/' $${tmpHead} > $${tmpSed};\
		sed 's/#####\(.*\)\(throw std::domain_error\)/    -\1\2/' $${tmpSed} > coverage/$*.h.gcov;\
		grep -v '^ *-:' coverage/$*.h.gcov | awk -F: 'BEGIN {id=0;used=0;count=0;exe=0} {if ($$2 != id){id=$$2;count++;if (used == 1){used=0;exe++;}}} /#####/ {next} {used=1} END {if (used == 1){exe++;}if (count != 0){printf("Lines executed: %.2f%% of %d\n", exe * 100 / count, count);}else{}printf("Lines executed: 00.00%%\n");}' > coverage/$*.h.out; \
		if ( test "$(VERBOSE)" = "On" ); then				\
			$(ECHO) $(call colour_text, GRAY, "$(COV) coverage $*.h") | awk '{printf "%-80s", $$0}' ; \
			$(ECHO) $(GREEN_OK);							\
		fi;													\
		$(RM) -f $${tmpHead} $${tmpSed};					\
	fi
	@if ( test "$(VERBOSE)" = "On" ); then					\
		$(ECHO) "Done";										\
	fi

%.cpp_report_coverage:	coverage/%.cpp.gcov
	@if [ -e coverage/$*.cpp.out ]; then $(ECHO) $*.cpp $(call getPercentColour,$(shell cat coverage/$*.cpp.out | awk -F: 'START {FOUND=0} {if (FOUND==1) {print $$2;FOUND=0}} /File.*$*.cpp/ {FOUND=1}' | awk '{print substr($$1,0,length($$1)-1)}')) | awk '{printf "%-80s%s%%\n", $$1, $$2}'; fi
	@if [ "$(COVERAGE)" = "On" ]; then cat coverage/$*.cpp.gcov ; fi;
	@if [ "$(COVERAGE)" = "$*.cpp" ]; then cat coverage/$*.cpp.gcov ; fi;
%.tpp_report_coverage:	coverage/%.tpp.gcov
	@if [ -e coverage/$*.cpp.out ]; then $(ECHO) $*.tpp $(call getPercentColour,$(shell cat coverage/$*.cpp.out | awk -F: 'START {FOUND=0} {if (FOUND==1) {print $$2;FOUND=0}} /File.*$*.tpp/ {FOUND=1}' | awk '{print substr($$1,0,length($$1)-1)}')) | awk '{printf "%-80s%s%%\n", $$1, $$2}'; fi
	@if [ "$(COVERAGE)" = "On" ]; then cat $$(find . -name "*$*.tpp.gcov") ; fi
	@if [ "$(COVERAGE)" = "$*.tpp" ]; then cat $$(find . -name "*$*.tpp.gcov") ; fi
%.h_report_coverage:	coverage/%.h.gcov coverage/%*.h.out
	@$(ECHO) $*.h $(call getPercentColour, $(shell awk '{print substr($$3,0,length($$3)-1)}' coverage/$*.h.out)) | awk '{printf "%-80s%s%%\n", $$1, $$2}'
	@if [ "$(COVERAGE)" = "On" ]; then cat coverage/$*.h.gcov ; fi
	@if [ "$(COVERAGE)" = "$*.h" ]; then cat coverage/$*.h.gcov ; fi

debug:
	@$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=debug	INSTALL_ACTIVE=$(INSTALL_ACTIVE) all
release:
	@$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=release INSTALL_ACTIVE=$(INSTALL_ACTIVE) all
profile:
	@$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=profile INSTALL_ACTIVE=$(INSTALL_ACTIVE) all try_install_head doInstall

buildDir:	$(TARGET_MODE).Dir coverage.Dir


%.Dir:
	@if [ ! -e $* ]; then mkdir -p $*; fi

.PRECIOUS:	$(OBJ)
.PRECIOUS:	$(GCOV_OBJ)
.PRECIOUS:	$(TARGET_MODE)/%.app
.PRECIOUS:	$(TARGET_MODE)/lib%.$(SO)
.PRECIOUS:  $(TARGET_MODE)/lib%.a
.PRECIOUS:	%.tab.cpp
.PRECIOUS:	%.lex.cpp
.PRECIOUS:	%.gperf.cpp
.PRECIOUS:	%.cpp.gcov
.PRECIOUS:	%.tpp.gcov
.PRECIOUS:	%.vera


.PHONY:	%.app %.slib %.head %.defer
.PHONY:	run_test vera vera_head vera_body

%.head:
	@$(ECHO) $(call subsection_title, Nothing to build for $*)
	
%.app:		buildDir $(TARGET_MODE)/%.app
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



vera/%.vera:
	@if [ "$(VERA)" != "off" ]; then						\
		if ( test "$(VERBOSE)" = "On" ); then				\
			$(ECHO) "$(VERA) --show-rule --error --std-report $@.report $*"; \
		else $(ECHO) $(call colour_text, GRAY, $(VERA) $*)	| awk '{printf "%-80s", $$0}' ; fi; \
		PATH="${PATH}:$(PREFIX_BIN)" $(VERA) --profile thor --show-rule --error --std-report $@.report $*; \
		if [ $$? != 0 ];									\
		then												\
			$(ECHO) $(RED_ERROR);							\
			$(ECHO) "$(VERA) --profile thor --show-rule --error --std-report $@.report $*";	\
			$(ECHO) "==================================================="; \
			cat $@.report;									\
			exit 1;											\
		else 												\
			$(ECHO) $(GREEN_OK);							\
			$(RM) $@.report;								\
		fi;													\
	fi

$(TARGET_MODE)/%.app:	$(OBJ) $(DEFER_OBJ) $(TARGET_MODE)/%.o
	@if ( test "$(VERBOSE)" = "On" ); then \
		$(ECHO) '$(CXX) -o $@ $(LDFLAGS) $(OBJ) $(DEFER_OBJ) $(CXXFLAGS) $(call expandFlag,$($*_CXXFLAGS)) $(TARGET_MODE)/$*.o $(LOADLIBES) $(ALL_LDLIBS) $(LDLIBS) $($*_LDLIBS) $(call expand,$($*_LINK_LIBS))' ; \
	else $(ECHO) $(call colour_text, GRAY, "$(CC) -o $@ $(OPTIMIZER_FLAGS_DISP)  $(call expandFlag,$($*_CXXFLAGS))")	| awk '{printf "%-80s", $$0}' ;	fi
	@$(LDLIBS_EXTERN_RPATH) $(CXX) -o $@ $(LDFLAGS) $(OBJ) $(DEFER_OBJ) $(CXXFLAGS) $(call expandFlag,$($*_CXXFLAGS)) $(TARGET_MODE)/$*.o $(LOADLIBES) $(ALL_LDLIBS) $(LDLIBS) $($*_LDLIBS) $(call expand,$($*_LINK_LIBS)) 2>makefile_tmp; \
	if [ $$? != 0 ];									\
	then												\
		$(ECHO) $(RED_ERROR);							\
		$(ECHO) $(LDLIBS_EXTERN_RPATH) $(CXX) -o $@ $(LDFLAGS) $(OBJ) $(DEFER_OBJ) $(TARGET_MODE)/$*.o $(LOADLIBES) $(ALL_LDLIBS) $(LDLIBS) $($*_LDLIBS) $(call expand,$($*_LINK_LIBS)); \
		$(ECHO) "==================================================="; \
		cat makefile_tmp;								\
		exit 1;											\
	else 												\
		$(ECHO) $(GREEN_OK);							\
		$(RM) makefile_tmp;								\
	fi

$(TARGET_MODE)/lib%.a:	coverage.Dir $(GCOV_OBJ) $(DEFER_OBJ)
	@if ( test "$(VERBOSE)" = "On" ); then				\
		$(ECHO) '$(AR) $(ARFLAGS) $@ $(GCOV_OBJ) $(DEFER_OBJ)';\
	else $(ECHO) $(call colour_text, GRAY, "$(AR) $(ARFLAGS) $@")	| awk '{printf "%-80s", $$0}' ; fi
	@$(AR) $(ARFLAGS) $@ $(GCOV_OBJ) $(DEFER_OBJ) > makefile_tmp 2>&1;	\
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

$(TARGET_MODE)/lib%.$(SO):	$(GCOV_OBJ) $(DEFER_OBJ)
	@if ( test "$(VERBOSE)" = "On" ); then				\
		$(ECHO) '$(CXX) $(SHARED_LIB_FLAG_$(PLATFORM)) -o $@ $(LDFLAGS) $(GCOV_OBJ) $(DEFER_OBJ) $(CXXFLAGS)  $(call expandFlag,$($*_CXXFLAGS)) $(LOADLIBES) $(ALL_LDLIBS) $(LDLIBS) $(THORSANVIL_STATICLOADALL)' ; \
	else $(ECHO) $(call colour_text, GRAY, "$(CC) $(SHARED_LIB_FLAG_$(PLATFORM)) -o $@ $(OPTIMIZER_FLAGS_DISP)  $(call expandFlag,$($*_CXXFLAGS))")	| awk '{printf "%-80s", $$0}' ; fi
	@$(LDLIBS_EXTERN_RPATH) $(CXX) $(SHARED_LIB_FLAG_$(PLATFORM)) -o $@ $(LDFLAGS) $(GCOV_OBJ) $(DEFER_OBJ) $(CXXFLAGS)  $(call expandFlag,$($*_CXXFLAGS)) $(LOADLIBES) $(ALL_LDLIBS) $(LDLIBS) $(THORSANVIL_STATICLOADALL) 2>makefile_tmp; \
	if [ $$? != 0 ];									\
	then												\
		$(ECHO) $(RED_ERROR);							\
		$(ECHO) $(LDLIBS_EXTERN_RPATH) $(CXX) -shared -o $@ $(LDFLAGS) $(GCOV_OBJ) $(DEFER_OBJ) $(CXXFLAGS)  $(call expandFlag,$($*_CXXFLAGS)) $(LOADLIBES) $(ALL_LDLIBS) $(LDLIBS) $(THORSANVIL_STATICLOADALL); \
		$(ECHO) "==================================================="; \
		cat makefile_tmp;								\
		exit 1;											\
	else 												\
		$(ECHO) $(GREEN_OK);							\
		$(RM) makefile_tmp;								\
	fi

coverage/ThorsAnvilUnitTestMarker.o: ThorsAnvilUnitTestMarker.cpp $(BASE)/coverage/MockHeaders.h $(BASE)/coverage/ThorMock.h
	@$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(MOCK_HEADERS)  $(call expandFlag,$($*_CXXFLAGS)) 2>&1
$(TARGET_MODE)/%.o: %.cpp $(BASE)/coverage/MockHeaders.h $(BASE)/coverage/ThorMock.h
	@if ( test "$(VERBOSE)" = "Off" ); then				\
		$(ECHO) $(call colour_text, GRAY, "$(CXX) -c $< $(OPTIMIZER_FLAGS_DISP)  $(call expandFlag,$($*_CXXFLAGS))") | awk '{printf "%-80s", $$0}' ; \
	elif ( test "$(VERBOSE)" = "On" ); then				\
		$(ECHO) '$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(call expandFlag,$($*_CXXFLAGS))' ;		\
	fi
	@export tmpfile=$(shell $(MKTEMP));					\
	$(ECHO) $(call colour_text, GRAY, "$(CXX) -c $(OPTIMIZER_FLAGS_DISP)  $(call expandFlag,$($*_CXXFLAGS))") $< | awk '{printf "%-80s", $$0}' ; \
	$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(MOCK_HEADERS)  $(call expandFlag,$($*_CXXFLAGS)) 2>$${tmpfile};	\
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
$(BASE)/coverage/%.o: $(BASE)/coverage/%.cpp
	@if ( test "$(VERBOSE)" = "Off" ); then				\
		$(ECHO) $(call colour_text, GRAY, "$(CXX) -c $< $(OPTIMIZER_FLAGS_DISP)  $(call expandFlag,$($*_CXXFLAGS))") | awk '{printf "%-80s", $$0}' ; \
	elif ( test "$(VERBOSE)" = "On" ); then				\
		$(ECHO) '$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(call expandFlag,$($*_CXXFLAGS))' ;		\
	fi
	@export tmpfile=$(shell $(MKTEMP));					\
	$(ECHO) $(call colour_text, GRAY, "$(CXX) -c $(OPTIMIZER_FLAGS_DISP)  $(call expandFlag,$($*_CXXFLAGS))") $< | awk '{printf "%-80s", $$0}' ; \
	$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(MOCK_HEADERS)  $(call expandFlag,$($*_CXXFLAGS)) 2>$${tmpfile};	\
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
		$(ECHO) $(call colour_text, GRAY, "$(YACC) $^") | awk '{printf "%-80s", $$0}' ; \
	elif ( test "$(VERBOSE)" = "On" ); then				\
		$(ECHO) '$(YACC) -o $@ -d $<' ;					\
	fi
	@export tmpfile=$(shell $(MKTEMP));					\
	$(YACC) -o $@ -d $< 2>$${tmpfile};				    \
	if [ $$? != 0 ];									\
	then												\
		$(ECHO) "Failed in Parser Generator";			\
		$(ECHO) $(RED_ERROR);							\
		$(ECHO) $(YACC) -o $@ -d $<;					\
		$(ECHO) "========================================";\
		cat $${tmpfile};								\
		exit 1;											\
	else 												\
		if ( test "$(VERBOSE)" = "NONE" ); then			\
			$(ECHO) $(call colour_text, GRAY, "$(YACC) $^") | awk '{printf "%-80s", $$0}' ; \
		fi;												\
		$(ECHO) $(GREEN_OK);							\
		$(RM) $${tmpfile};								\
	fi

%.lex.cpp: %.l
	@if ( test "$(VERBOSE)" = "Off" ); then				\
		$(ECHO) $(call colour_text, GRAY, "$(LEX) $^") | awk '{printf "%-80s", $$0}' ; \
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
		cat $${tmpfile} | sed -e 's/<stdout>/$*.lex.cpp/' -e 's/extern "C" int isatty/\/\/ Removed extern "C" int isatty/' -e 's/max_size )) < 0 )/max_size )) == std::size_t(-1) )/' > $@;	\
		if ( test "$(VERBOSE)" = "NONE" ); then			\
			$(ECHO) $(call colour_text, GRAY, "$(LEX) $^") | awk '{printf "%-80s", $$0}' ; \
		fi;												\
		$(ECHO) $(GREEN_OK);							\
		$(RM) $${tmpfile};								\
	fi

%.gperf.cpp: %.gperf
	@if ( test "$(VERBOSE)" = "Off" ); then				\
		$(ECHO) $(call colour_text, GRAY, "$(GPERF) --class-name=$*_Hash $^") | awk '{printf "%-80s", $$0}' ; \
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
			$(ECHO) $(call colour_text, GRAY, "$(GPERF) --class-name=$*_Hash $^") | awk '{printf "%-80s", $$0}' ; \
		fi;												\
		$(ECHO) $(GREEN_OK);							\
	fi

NotImplemented.%:
	@$(ECHO) $(call colour_text, RED, "$* Not Implemented Yet")


.PHONY:	Print_Off Print_On
PrintDebug:	Print_$(VERBOSE)
Print_Off:
Print_NONE:
Print_On:
	@$(ECHO) "TARGET:               $(TARGET)"
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
	@$(ECHO) "TESTNAME:             $(TESTNAME)"
	@$(ECHO) "DEFER_NAME:           $(DEFER_NAME)"
	@$(ECHO) "INSTALL_DEFER:        $(INSTALL_DEFER)"
	@$(ECHO) "DEFER_NAME:           $(DEFER_NAME)"
	@$(ECHO) "DEFER_LIBS:           $(DEFER_LIBS)"
	@$(ECHO) "DEFER_OBJDIR:         $(DEFER_OBJDIR)"
	@$(ECHO) "DEFER_OBJ:            $(DEFER_OBJ)"
	@echo    "ECHO:                 $(ECHO)"

.PHONY: always
always:
	@$(ECHO)

include $(BUILD_ROOT)/tools/lint.Makefile
include $(BUILD_ROOT)/tools/Doc.Makefile

