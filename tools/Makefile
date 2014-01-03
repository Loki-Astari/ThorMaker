
#
# Generic Makefile for all building.
#

#
# To use set the variable TARGET
# Then include this file.
# The TARGET variable may include multiple things to build
# 

#
# A name with a *.app  extension is an executable			(the app will NOT be part of the final name)
# A name with a *.a    extension is a static library		(the lib prefix will automatically be added)
# A name with a *.slib extension is a shared library		(the lib prefix will automatically be added. And platform specific suffix will replace slib)
# A name with a *.dir  extension builds a subdirectory
# A name with a *.head extension builds a header only library
#
#		Note: This will build a shared library with the appropriate platform specific extension
#			  In the directory TARGET_Mode (debug/release)
#
# Flags Help:
#	CXXSTDVER=03					(set to 11 for newer C++)
#	VERBOSE=On						Turn on verbose mode
#										This will print the full compile command rather than a summary
# 
# Flags For Specific files:
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
#

-include $(THORSANVIL_ROOT)/Makefile.config
BUILD_ROOT		?= $(THORSANVIL_ROOT)/build
include $(BUILD_ROOT)/tools/Colour.Makefile
include $(BUILD_ROOT)/tools/Platform.Makefile

YACC			= bison
LEX				= flex
GPERF			= gperf --ignore-case
CP				= cp
CXX				= $(CXX_$(TARGET_MODE))
COV				= gcov$(CXX_coverage_$(PLATFORM)$(PLATFORMVER))
	
CXX_debug		= g++$(CXX_debug_$(PLATFORM)$(PLATFORMVER))
CXX_release		= g++$(CXX_release_$(PLATFORM)$(PLATFORMVER))
CXX_coverage	= g++$(CXX_coverage_$(PLATFORM)$(PLATFORMVER))
CXX_profile		= g++$(CXX_profile_$(PLATFORM)$(PLATFORMVER))

#
# This is obviously not working
# Need to look at this
CXX_coverage_Darwin11_3_0		= -4.2
CXX_profile_Darwin11_3_0		= -4.2

CXX_debug_Darwin12_2_1			= -4.7
CXX_release_Darwin12_2_1		= -4.7
CXX_coverage_Darwin12_2_1		= -4.7
CXX_profile_Darwin12_2_1		= -4.7

CXX_debug_Darwin12_3_0			= -4.7
CXX_release_Darwin12_3_0		= -4.7
CXX_coverage_Darwin12_3_0		= -4.7
CXX_profile_Darwin12_3_0		= -4.7

CXX_debug_Darwin12_4_0			= -4.7
CXX_release_Darwin12_4_0		= -4.7
CXX_coverage_Darwin12_4_0		= -4.7
CXX_profile_Darwin12_4_0		= -4.7

CXX_debug_Linux2_6_32			= -4.6
CXX_release_Linux2_6_32			= -4.6
CXX_coverage_Linux2_6_32		= -4.6
CXX_profile_Linux2_6_32			= -4.6


#
# Add Files(without extension) that you do not want coverage metrics for
NOCOVERAGE		+= %.lex %.tab

APP_SRC						= $(patsubst %.app,%.cpp,$(TARGET))
CPP_SRC						= $(filter-out %.lex.cpp %.tab.cpp %.gperf.cpp $(APP_SRC),$(wildcard *.cpp))
LEX_SRC						= $(wildcard *.l)
GPERF_SRC					= $(wildcard *.gperf)
YACC_SRC					= $(wildcard *.y)
SRC							= $(patsubst %.y,%.tab.cpp,$(YACC_SRC)) $(patsubst %.l,%.lex.cpp,$(LEX_SRC)) $(patsubst %.gperf,%.gperf.cpp,$(GPERF_SRC)) $(CPP_SRC)
HEAD						= $(wildcard *.h *.tpp) $(EXTRA_HEADERS)
OBJ							= $(patsubst %.cpp,$(TARGET_MODE)/%.o,$(SRC))
GCOV_OBJ					= $(filter-out coverage/main.o,$(OBJ))
GCOV						= $(patsubst coverage/%.o, coverage/%.cpp.gcov, $(GCOV_OBJ)) $(patsubst %.tpp,coverage/%.tpp.gcov, $(wildcard *.tpp))

GCOV_REPORT					= $(filter-out $(foreach nocoverage,$(NOCOVERAGE),coverage/$(nocoverage).cpp.gcov), $(GCOV))
GCOV_ACTUAL					= $(filter $(GCOV_REPORT), $(wildcard coverage/*.gcov))


INSTALL_APP					= $(if $(filter %.app,  $(TARGET)), $(patsubst %.app,  install_app_%, $(TARGET)))
INSTALL_LIB					= $(if $(filter %.slib, $(TARGET)), $(patsubst %.slib, install_lib_%, $(TARGET)))
INSTALL_HEADER				= $(if $(filter %.slib, $(TARGET)), $(patsubst %, install_head_%, $(HEAD)))

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
COVERAGE_TARGET				?= COVERAGE_$(notdir $(shell pwd))
PARALLEL					= $(PARALLEL_$(VERBOSE))
PARALLEL_NONE				= -j8

#
# Warning flags turned off for test suite.
# As long as the main code compiles without warnings


#
# ANSI (turn it off for C++11)
THORSANVIL_ANSI_03			= -ansi
THORSANVIL_ANSI				= $(THORSANVIL_ANSI_$(CXXSTDVER))


ENVIRONMENT_FLAGS			=	$(PLATFORM_SPECIFIC_FLAGS) $(COMPILER_SPECIFIC_FLAGS)  $(LANGUAGE_SPECIFIC_FLAGS)

PLATFORM_SPECIFIC_FLAGS		=	$(PLATFORM_$(PLATFORM)_FLAGS)
PLATFORM_Darwin_FLAGS		=
PLATFORM_Linux_FLAGS		=


#
# Having problems with unreachable code being reported in the system header files
# Had to turn this on to make the code compile with no errors.
COMPILER_SPECIFIC_FLAGS		= $(COMPILER_$(COMPILER_NAME)_$(COMPILER_VERSION)_FLAGS)
COMPILER_gpp_4_4_FLAGS		= -Wno-unreachable-code
COMPILER_gpp_4_7_FLAGS		= -Wno-unreachable-code


#
# Bug in gcc
# The macro __cplusplus is always 1 so you can detect the language version at the pre-processor level.
# So we defined the flag THOR_USE_CPLUSPLUS11 to be used instead
LANGUAGE_SPECIFIC_FLAGS		= $(LANGUAGE_SPECIFIC_$(CXXSTDVER)_FLAGS)
LANGUAGE_SPECIFIC_11_FLAGS	= -DTHOR_USE_CPLUSPLUS11


WARNING_FLAGS				=	$(WARNING_FLAGS_$(TEST_STATE)) $(WARNING_FLAGS_$(TARGET_MODE)) $(FILE_WARNING_FLAGS)
WARNING_FLAGS_				=	-Wall -Wextra -Wstrict-aliasing $(THORSANVIL_ANSI) -pedantic -Werror -Wunreachable-code -Wno-long-long


expand						=	$(foreach lib, $(1), -l$(lib)$(BUILD_EXTENSION))
expandFlag					=   $(foreach flag, $(1), $(flag))
THORSANVIL_FLAGS			=	-I$(PREFIX_INC)
THORSANVIL_LIBS				=	-L$(PREFIX_LIB) $(call expand,$(LINK_LIBS)) $(EX_LDLIBS)


BOOST_FLAGS					=	-isystem $(PREFIX_INC3RD) -DBOOST_FILESYSTEM_VERSION=3
BOOST_LIBS					=


TEST_FLAGS					=	$(TEST_FLAGS_$(TEST_STATE))
TEST_LIBS					=	$(TEST_LIBS_$(TEST_STATE)) -fprofile-arcs -ftest-coverage -lpthread
TEST_FLAGS_on				=	-I..
TEST_LIBS_on				=	-L../coverage -L$(THORSANVIL_ROOT)/build/lib -lobject -lgtest


OPTIMIZER_FLAGS				=	$(OPTIMIZER_FLAGS_DISP)$(OPTIMIZER_FLAGS_HIDE)
OPTIMIZER_FLAGS_DISP		=	$(OPTIMIZER_FLAGS_DISP_$(TARGET_MODE))
OPTIMIZER_FLAGS_HIDE		=	$(OPTIMIZER_FLAGS_HIDE_$(TARGET_MODE))
OPTIMIZER_LIBS				=	$(OPTIMIZER_LIBS_$(TARGET_MODE))
OPTIMIZER_FLAGS_DISP_debug		=	-g
OPTIMIZER_FLAGS_DISP_release	=	-O3
OPTIMIZER_FLAGS_DISP_coverage	=	-D$(COVERAGE_TARGET)  
OPTIMIZER_FLAGS_HIDE_coverage	=	-g -fprofile-arcs -ftest-coverage -DCOVERAGE_TEST
OPTIMIZER_FLAGS_HIDE_profile	=	-g -pg -DPROFILE_TEST

CXXSTDVER_FLAGS_03			=
CXXSTDVER_FLAGS_11			=	-std=c++0x

CC							=	$(CXX)
CXXFLAGS					+=	-fPIC $(WARNING_FLAGS) $(THORSANVIL_FLAGS) $(BOOST_FLAGS) $(TEST_FLAGS) $(OPTIMIZER_FLAGS) $(ENVIRONMENT_FLAGS) $(CXXSTDVER_FLAGS_$(CXXSTDVER))
ALL_LDLIBS					+=	$(TEST_LIBS) $(OPTIMIZER_LIBS) $(THORSANVIL_LIBS) $(BOOST_LIBS)



PREFIX						?=	$(BUILD_ROOT)
PREFIX_BIN					?=	$(PREFIX)/bin
PREFIX_LIB					?=	$(PREFIX)/lib
PREFIX_INC					?=	$(PREFIX)/include
PREFIX_INC3RD				?=	$(THORSANVIL_ROOT)/build/include3rd
BUILD_EXTENSION				=	$(BUILD_EXTENSION_CXXSTDVER_$(CXXSTDVER))$(BUILD_EXTENSION_TYPE_$(TARGET_MODE))
BUILD_EXTENSION_CXXSTDVER_03	=   03
BUILD_EXTENSION_CXXSTDVER_11	=	11
BUILD_EXTENSION_TYPE_debug		=	D
BUILD_EXTENSION_TYPE_coverage	=	D
BUILD_EXTENSION_TYPE_profile	=	P


#
# For reference the default rules are
#	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS)
#	$(CC) $(LDFLAGS) N.o $(LOADLIBES) $(LDLIBS)

.PHONY:	all validate install objectarch clean veryclean test coverage debug release profile header_only install_dir

all:	PrintDebug buildDir Note_Building_$(TARGET_MODE) $(TARGET)
	@echo $(call colour_text, BLUE, "Done")
validate:		test 
install:		test try_install_head install_Dodebug install_Dorelease
install_debug:	test try_install_head install_Dodebug
install_release:test try_install_head install_Dorelease
install_profile:     try_install_head install_Doprofile
header_only:	test try_install_head

tools:
	@echo "PLATFORM:         $(PLATFORM)  $(PLATFORMVER)"
	@echo "PLATFORM FLAGS:   $(PLATFORM_SPECIFIC_FLAGS)"
	@echo "COMPILER FLAGS:   $(COMPILER_SPECIFIC_FLAGS)"
	@echo "LANGUAGE FLAGS:   $(LANGUAGE_SPECIFIC_FLAGS)"
	@echo "YACC:             $(YACC)"
	@echo "LEX:              $(LEX)"
	@echo "GPERF:            $(GPERF)"
	@echo "CP:               $(CP)"
	@echo "CXX:              $(CXX)   :  Name: $(COMPILER_NAME) Version:$(COMPILER_VERSION) Language:$(CXXSTDVER)"
	@echo "COV:              $(COV)"

	
install_Dodebug:
	$(MAKE) $(PARALLEL) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=debug all
	$(MAKE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=debug doInstall
install_Dorelease:
	$(MAKE) $(PARALLEL) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=release all
	$(MAKE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=release doInstall
install_Doprofile:
	$(MAKE) $(PARALLEL) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=profile all
	$(MAKE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=profile doInstall

doInstall:	try_install_app try_install_lib

try_install_app:	$(if (INSTALL_APP), install_app)
try_install_lib:	$(if (INSTALL_LIB), install_lib)
try_install_head:	$(if (INSTALL_HEADER), install_head)

install_app:	Note_Start_Installing_Applications $(INSTALL_APP)	 Note_End_Installing_Applications
install_lib:	Note_Start_Installing_Libraries    $(INSTALL_LIB)	 Note_End_Installing_Libraries
install_head:	Note_Start_Installing_Headers	   $(INSTALL_HEADER) Note_End_Installing_Headers

Note_%:
	@echo $(call section_title, $(subst _, ,$*))

%.cpp:	%.h
	
objectarch:	buildDir $(GCOV_OBJ)
	@if ( test "$(GCOV_OBJ)" != "" ); then $(AR) -rv $(TARGET_MODE)/libobject.a $(GCOV_OBJ) 2>/dev/null; fi
	@echo $(call colour_text, BLUE, "Done")
clean: test_clean
	$(RM) $(OBJ) $(GCOV)  makefile_tmp
	$(RM) $(patsubst %.y,%.tab.cpp,$(YACC_SRC)) $(patsubst %.y,%.tab.hpp,$(YACC_SRC)) $(patsubst %.l,%.lex.cpp,$(LEX_SRC)) $(patsubst %.gperf,%.gperf.cpp,$(GPERF_SRC)) $(CLEAN_EXTRA)
	$(RM) $(TARGET) $(patsubst %.app,%,$(filter %.app,$(TARGET))) $(patsubst %,$(TARGET_MODE)/%,$(filter %.app,$(TARGET)))
veryclean: clean test_veryclean
	$(RM) -rf debug release coverage profile
test:
	@-$(RM) -rf coverage/libobject.a coverage/*.gcov coverage/*.gcda test/coverage/unittest.app
	@echo $(call section_title,Building Objects for Testing and Coverage)
	@$(MAKE) $(PARALLEL) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=coverage objectarch
	@echo $(call section_title,Building Unit Tests)
	@(! test -d test) || touch test/unittest.cpp
	@(! test -d test) || $(MAKE) $(PARALLEL) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=coverage -C test -f ../Makefile THORSANVIL_ROOT=$(THORSANVIL_ROOT) BUILD_ROOT=$(BUILD_ROOT) TEST_STATE=on TARGET=unittest.app LINK_LIBS="$(UNITTEST_LINK_LIBS)" EX_LDLIBS="$(UNITTEST_LDLIBS)" COVERAGE_TARGET="$(COVERAGE_TARGET)"
	@(! test -d test) || rm    test/unittest.cpp
	@(! test -d test) || echo $(call section_title,Running Unit Tests)
	@(! test -d test) || $(RUNTIME_SHARED_PATH_SET)=$(PREFIX_LIB) test/coverage/unittest.app
	@echo
	@echo
	@echo $(call colour_text, GRAY, $(MAKE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=coverage report_coverage COVERAGE=$(COVERAGE))
	@echo
	@echo
	@(! test -d test) || $(MAKE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=coverage coverage COVERAGE=$(COVERAGE)

install_app_%:
	@mkdir -p $(PREFIX_BIN)
	@$(CP) $(TARGET_MODE)/$*.app $(PREFIX_BIN)/$*$(BUILD_EXTENSION)
	@echo $(call subsection_title, Install - $(TARGET_MODE) - $*$(BUILD_EXTENSION))

install_lib_%:
	@mkdir -p $(PREFIX_LIB)
	@$(CP) $(TARGET_MODE)/lib$*.$(SO) $(PREFIX_LIB)/lib$*$(BUILD_EXTENSION).$(SO)
	@echo $(call subsection_title, Install - $(TARGET_MODE) - lib$*$(BUILD_EXTENSION).$(SO))

install_head_%: $(PREFIX_INC)/$(basename $(filter %.slib, $(TARGET))).Dir
	@mkdir -p $(PREFIX_INC)/$(basename $(filter %.slib, $(TARGET)))/
	@$(CP) $* $(PREFIX_INC)/$(basename $(filter %.slib, $(TARGET)))/
	@echo $(call subsection_title, Install Header $*)

test_%:
	@if [ -d test ]; then $(MAKE) -C test -f ../Makefile THORSANVIL_ROOT=$(THORSANVIL_ROOT) BUILD_ROOT=$(BUILD_ROOT) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TEST_STATE=on TARGET=unittest.app $*; fi

coverage:	$(GCOV_REPORT) $(patsubst coverage/%.gcov, report_coverage_%, $(GCOV_REPORT))
	@if [ "$(GCOV_ACTUAL)" != "" ]; then								\
		 left=`cat $(GCOV_ACTUAL) | grep '####' | wc -l`;				\
		 right=`cat $(GCOV_ACTUAL)| grep -v '\-:' | wc -l`;				\
		 a=$${right};b=$${left};c=$$(($$a-$$b));d=$$(($$c*100));e=$$(($$d/$$a));		\
		 res=`echo "$${left} > ($${right}  * 0.2)"  | bc`;				\
		 if [ $${res} -ne 0 ]; then										\
			echo $(RED_ERROR) $(call colour_text, PURPLE, Code Coverage $${e}% does not exceed 80% of total);	\
			echo "Use: '$(MAKE) test VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) COVERAGE=On' to get details about coverage";		\
			exit 1;														\
		 else															\
			echo $(GREEN_OK) Code Coverage Passed;						\
		 fi																\
	 fi
coverage/%.cpp.gcov: always
	@echo "Generating Coverage for $*.cpp"
	@if [ -e $*.cpp ]; then $(COV) --long-file-names --object-directory coverage $*.cpp 2>/dev/null	> coverage/$*.cpp.out ; fi;
	@if [ -e $*.cpp*$*.tpp.gcov ]; then mv $*.cpp*$*.tpp.gcov coverage/$*.tpp.gcov; fi;
	@if [ -e $*.cpp.gcov ]; then mv $*.cpp.gcov coverage/; fi;
	@$(RM) *.gcov
coverage/%.tpp.gcov:
	@echo Do Nothing
report_coverage: report_coverage_$(COVERAGE)
report_coverage_%.cpp:
	@if [ -e coverage/$*.cpp.out ]; then echo $*.cpp $(call getPercentColour,$(shell cat coverage/$*.cpp.out | awk -F: 'START {FOUND=0} {if (FOUND==1) {print $$2;FOUND=0}} /File.*$*.cpp/ {FOUND=1}' | awk '{print substr($$1,0,length($$1)-1)}')) | awk '{printf "%-80s%s%%\n", $$1, $$2}'; fi
	@if [ "$(COVERAGE)" = "On" ]; then cat coverage/$*.cpp.gcov ; fi;
	@if [ "$(COVERAGE)" = "$*.cpp" ]; then cat coverage/$*.cpp.gcov ; fi;
report_coverage_%.tpp:
	@if [ -e coverage/$*.cpp.out ]; then echo $*.tpp $(call getPercentColour,$(shell cat coverage/$*.cpp.out | awk -F: 'START {FOUND=0} {if (FOUND==1) {print $$2;FOUND=0}} /File.*$*.tpp/ {FOUND=1}' | awk '{print substr($$1,0,length($$1)-1)}')) | awk '{printf "%-80s%s%%\n", $$1, $$2}'; fi
	@if [ "$(COVERAGE)" = "On" ]; then cat coverage/$*.tpp.gcov ; fi
	@if [ "$(COVERAGE)" = "$*.tpp" ]; then cat coverage/$*.tpp.gcov ; fi
	
debug:
	@$(MAKE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=debug	 all
release:
	@$(MAKE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=release all
profile:
	@$(MAKE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=profile all try_install_head doInstall

buildDir:	$(TARGET_MODE).Dir


%.Dir:
	@if [ ! -e $* ]; then mkdir -p $*; fi

.PRECIOUS:	$(OBJ)
.PRECIOUS:	$(TARGET_MODE)/%.app
.PRECIOUS:	$(TARGET_MODE)/lib%.$(SO)
.PRECIOUS:	%.tab.cpp
.PRECIOUS:	%.lex.cpp
.PRECIOUS:	%.gperf.cpp


.PHONY:	%.app %.slib %.head

%.head:
	@echo $(call subsection_title, Nothing to build for $*)
	
%.app:		buildDir $(TARGET_MODE)/%.app
	@echo $(call subsection_title, Done Building $(TARGET_MODE)/$*)

xxlib:		buildDir Note_Building_(TARGET_MODE)/lib%.$(SO) $(TARGET_MODE)/lib%.$(SO)

%.slib:		buildDir $(TARGET_MODE)/lib%.$(SO)
	@echo $(call subsection_title, Done Building $(shell basename `pwd`) $(TARGET_MODE)/lib$*.$(SO))




$(TARGET_MODE)/%.app:	$(OBJ) $(TARGET_MODE)/%.o
	@if ( test "$(VERBOSE)" = "On" ); then \
		echo '$(CXX) -o $@ $(LDFLAGS) $(OBJ) $(CXXFLAGS) $(call expandFlag,$($*_CXXFLAGS)) $(TARGET_MODE)/$*.o $(LOADLIBES) $(ALL_LDLIBS) $(LDLIBS) $($*_LDLIBS) $(call expand,$($*_LINK_LIBS))' ; \
	else echo $(call colour_text, GRAY, "$(CC) -o $@ $(OPTIMIZER_FLAGS_DISP)  $(call expandFlag,$($*_CXXFLAGS))")	| awk '{printf "%-80s", $$0}' ;	fi
	@$(CXX) -o $@ $(LDFLAGS) $(OBJ) $(CXXFLAGS) $(call expandFlag,$($*_CXXFLAGS)) $(TARGET_MODE)/$*.o $(LOADLIBES) $(ALL_LDLIBS) $(LDLIBS) $($*_LDLIBS) $(call expand,$($*_LINK_LIBS)) 2>makefile_tmp; \
	if [ $$? != 0 ];									\
	then												\
		echo $(RED_ERROR);								\
		echo $(CXX) -o $@ $(LDFLAGS) $(OBJ) $(TARGET_MODE)/$*.o $(LOADLIBES) $(ALL_LDLIBS) $(LDLIBS) $($*_LDLIBS) $(call expand,$($*_LINK_LIBS)); \
		echo "==================================================="; \
		cat makefile_tmp;								\
		exit 1;											\
	else 												\
		echo $(GREEN_OK);								\
		$(RM) makefile_tmp;								\
	fi

$(TARGET_MODE)/lib%.$(SO):	$(OBJ)
	@if ( test "$(VERBOSE)" = "On" ); then				\
		 echo '$(CXX) $(SHARED_LIB_FLAG_$(PLATFORM)) -o $@ $(LDFLAGS) $(OBJ) $(CXXFLAGS)  $(call expandFlag,$($*_CXXFLAGS)) $(LOADLIBES) $(ALL_LDLIBS) $(LDLIBS)' ; \
	else echo $(call colour_text, GRAY, "$(CC) $(SHARED_LIB_FLAG_$(PLATFORM)) -o $@ $(OPTIMIZER_FLAGS_DISP)  $(call expandFlag,$($*_CXXFLAGS))")	| awk '{printf "%-80s", $$0}' ; fi
	@$(CXX) $(SHARED_LIB_FLAG_$(PLATFORM)) -o $@ $(LDFLAGS) $(OBJ) $(CXXFLAGS)  $(call expandFlag,$($*_CXXFLAGS)) $(LOADLIBES) $(ALL_LDLIBS) $(LDLIBS) 2>makefile_tmp; \
	if [ $$? != 0 ];									\
	then												\
		echo $(RED_ERROR);								\
		echo $(CXX) -shared -o $@ $(LDFLAGS) $(OBJ) $(LOADLIBES) $(ALL_LDLIBS) $(LDLIBS); \
		echo "==================================================="; \
		cat makefile_tmp;								\
		exit 1;											\
	else 												\
		echo $(GREEN_OK);								\
		$(RM) makefile_tmp;								\
	fi

$(TARGET_MODE)/%.o: %.cpp
	@if ( test "$(VERBOSE)" = "Off" ); then				\
		echo $(call colour_text, GRAY, "$(CXX) -c $^ $(OPTIMIZER_FLAGS_DISP)  $(call expandFlag,$($*_CXXFLAGS))") | awk '{printf "%-80s", $$0}' ; \
	elif ( test "$(VERBOSE)" = "On" ); then				\
		echo '$(CXX) -c $^ -o $@ $(CPPFLAGS) $(CXXFLAGS)  $(call expandFlag,$($*_CXXFLAGS))' ;		\
	fi
	@export tmpfile=$(shell mktemp -u);					\
	$(CXX) -c $^ -o $@ $(CPPFLAGS) $(CXXFLAGS)  $(call expandFlag,$($*_CXXFLAGS)) 2>$${tmpfile};	\
	if [ $$? != 0 ];									\
	then												\
		echo $(RED_ERROR);								\
		echo $(CXX) -c $^ -o $@ $(CPPFLAGS) $(CXXFLAGS)  $(call expandFlag,$($*_CXXFLAGS));\
		echo "========================================";\
		cat $${tmpfile};								\
		exit 1;											\
	else 												\
		if ( test "$(VERBOSE)" = "NONE" ); then			\
			echo $(call colour_text, GRAY, "$(CXX) -c $^ $(OPTIMIZER_FLAGS_DISP)  $(call expandFlag,$($*_CXXFLAGS))") | awk '{printf "%-80s", $$0}' ; \
		fi;												\
		echo $(GREEN_OK);								\
		$(RM) $${tmpfile};								\
	fi

%.tab.cpp: %.y
	@if ( test "$(VERBOSE)" = "Off" ); then				\
		 echo $(call colour_text, GRAY, "$(YACC) $^") | awk '{printf "%-80s", $$0}' ; \
	elif ( test "$(VERBOSE)" = "On" ); then				\
		 echo '$(YACC) -o $@ -d $<' ;					\
	fi
	@export tmpfile=$(shell mktemp -u);					\
	$(YACC) -o $@ -d $< 2>$${tmpfile};				    \
	if [ $$? != 0 ];									\
	then												\
		echo "Failed in Parser Generator";				\
		echo $(RED_ERROR);								\
		echo $(YACC) -o $@ -d $<;						\
		echo "========================================";\
		cat $${tmpfile};								    \
		exit 1;											\
	else 												\
		if ( test "$(VERBOSE)" = "NONE" ); then			\
			echo $(call colour_text, GRAY, "$(YACC) $^") | awk '{printf "%-80s", $$0}' ; \
		fi;												\
		echo $(GREEN_OK);								\
		$(RM) $${tmpfile};								\
	fi

%.lex.cpp: %.l
	@if ( test "$(VERBOSE)" = "Off" ); then				\
		 echo $(call colour_text, GRAY, "$(LEX) $^") | awk '{printf "%-80s", $$0}' ; \
	elif ( test "$(VERBOSE)" = "On" ); then				\
		echo '$(LEX) -t $< > $@' ;						\
	fi
	@$(LEX) -t $< | sed -e 's/<stdout>/$*.lex.cpp/' -e 's/extern "C" int isatty/\/\/ Removed extern "C" int isatty/' -e 's/max_size )) < 0 )/max_size )) == std::size_t(-1) )/' > $@;	\
	if [ $$? != 0 ];									\
	then												\
		echo "Failed in Lexer Generator";				\
		echo $(RED_ERROR);								\
		echo $(LEX) -t $< > $@;							\
		echo "========================================";\
		cat $@;											\
		exit 1;											\
	else 												\
		if ( test "$(VERBOSE)" = "NONE" ); then			\
			echo $(call colour_text, GRAY, "$(LEX) $^") | awk '{printf "%-80s", $$0}' ; \
		fi;												\
		echo $(GREEN_OK);								\
	fi

%.gperf.cpp: %.gperf
	@if ( test "$(VERBOSE)" = "Off" ); then				\
		 echo $(call colour_text, GRAY, "$(GPERF) --class-name=$*_Hash $^") | awk '{printf "%-80s", $$0}' ; \
	elif ( test "$(VERBOSE)" = "On" ); then				\
		echo '$(GPERF) -l -L C++ --class-name=$*_Hash $^ > $@'	;	\
	fi
	@export tmpfile=$(shell mktemp -u);					\
	$(GPERF) -l -L C++ --class-name=$*_Hash $^ > $@ 2>$${tmpfile};				\
	if [ $$? != 0 ];									\
	then												\
		echo "Failed in Lexer Generator";				\
		echo $(RED_ERROR);								\
		echo "$(GPERF) -l -L C++ --class-name=$@_Hash $^ > $@"; \
		echo "========================================";\
		cat $@;											\
		exit 1;											\
	else 												\
		if ( test "$(VERBOSE)" = "NONE" ); then			\
			echo $(call colour_text, GRAY, "$(GPERF) --class-name=$*_Hash $^") | awk '{printf "%-80s", $$0}' ; \
		fi;												\
		echo $(GREEN_OK);								\
	fi

NotImplemented.%:
	@echo $(call colour_text, RED, "$* Not Implemented Yet")


.PHONY:	Print_Off Print_On
PrintDebug:	Print_$(VERBOSE)
Print_Off:
Print_NONE:
Print_On:
	@echo "SRC:		 $(SRC)"
	@echo "OBJ:		 $(OBJ)"
	@echo "GCOV:	 $(GCOV)"
	@echo "GCOV_OBJ: $(GCOV_OBJ)"
	@echo "GPERF_SRC:$(GPERF_SRC)"

.PHONY: always
always:
	@echo 

