
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
#		Note: This will build a shared library with the appropriate platform specific extension
#			  In the directory TARGET_Mode (debug/release)
#
#

include $(THORSANVIL_ROOT)/Makefile.config
include $(THORSANVIL_ROOT)/build/tools/Colour.Makefile
include $(THORSANVIL_ROOT)/build/tools/Platform.Makefile

YACC			= bison
LEX				= flex
CXX				= $(CXX_$(TARGET_MODE))
	
CXX_debug		= g++
CXX_release		= g++
CXX_coverage	= $(CXX_coverage_$(PLATFORM))

CXX_coverage_Darwin	= g++-4.2
CXX_coverage_Linux	= g++

CP				= cp

#
# Add Files(without extension) that you do not want coverage metrics for
NOCOVERAGE		+=

APP_SRC						= $(patsubst %.app,%.cpp,$(TARGET))
CPP_SRC						= $(filter-out %.lex.cpp %.tab.cpp $(APP_SRC),$(wildcard *.cpp))
LEX_SRC						= $(wildcard *.l)
YACC_SRC					= $(wildcard *.y)
SRC							= $(patsubst %.y,%.tab.cpp,$(YACC_SRC)) $(patsubst %.l,%.lex.cpp,$(LEX_SRC)) $(CPP_SRC)
HEAD						= $(wildcard *.h) $(EXTRA_HEADERS)
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
CXXSTDVER					?=  03
VERBOSE						?=	Off
TARGET_MODE					?=	debug


#
# Warning flags turned off for test suite.
# As long as the main code compiles without warnings

ENVIRONMENT_FLAGS			=	$(PLATFORM_SPECIFIC_FLAGS) $(COMPILER_SPECIFIC_FLAGS) 

PLATFORM_SPECIFIC_FLAGS		=	$(PLATFORM_$(PLATFORM)_FLAGS)
PLATFORM_Darwin_FLAGS		=
PLATFORM_Linux_FLAGS		=

COMPILER_SPECIFIC_FLAGS		= $(COMPILER_$(COMPILER_NAME)_$(COMPILER_VERSION)_FLAGS)
#
# Having problems with unreachable code being reported in the system header files
# Had to turn this on to make the code compile with no errors.
COMPILER_gpp_4_4_3_FLAGS	= -Wno-unreachable-code


WARNING_FLAGS				=	$(WARNING_FLAGS_$(TEST_STATE)) $(WARNING_FLAGS_$(TARGET_MODE)) $(FILE_WARNING_FLAGS)
WARNING_FLAGS_				=	-Wall -Wextra -Wstrict-aliasing -ansi -pedantic -Werror -Wunreachable-code -Wno-long-long
WARNING_FLAGS_coverage		=	-DCOVERAGE_TEST


expand						=	$(foreach lib, $(1), -l$(lib)$(BUILD_EXTENSION))
THORSANVIL_FLAGS			=	-I$(PREFIX_INC)
THORSANVIL_LIBS				=	-L$(PREFIX_LIB) $(call expand,$(LINK_LIBS))


BOOST_FLAGS					=	-isystem $(PREFIX_INC3RD)
BOOST_LIBS					=


TEST_FLAGS					=	$(TEST_FLAGS_$(TEST_STATE))
TEST_LIBS					=	$(TEST_LIBS_$(TEST_STATE)) -fprofile-arcs -ftest-coverage -lpthread
TEST_FLAGS_on				=	-I..
TEST_LIBS_on				=	-L../coverage -lobject -lgtest


OPTIMIZER_FLAGS				=	$(OPTIMIZER_FLAGS_$(TARGET_MODE))
OPTIMIZER_LIBS				=	$(OPTIMIZER_LIBS_$(TARGET_MODE))
OPTIMIZER_FLAGS_debug		=	-g
OPTIMIZER_FLAGS_release		=	-O3
OPTIMIZER_FLAGS_coverage	=	-g -fprofile-arcs -ftest-coverage

CXXSTDVER_FLAGS_03			=
CXXSTDVER_FLAGS_11			=	-std=c++0x

CC							=	$(CXX)
CXXFLAGS					+=	-fPIC $(WARNING_FLAGS) $(THORSANVIL_FLAGS) $(BOOST_FLAGS) $(TEST_FLAGS) $(OPTIMIZER_FLAGS) $(ENVIRONMENT_FLAGS) $(CXXSTDVER_FLAGS_$(CXXSTDVER))
ALL_LDLIBS					+=	$(THORSANVIL_LIBS) $(BOOST_LIBS) $(TEST_LIBS) $(OPTIMIZER_LIBS)



PREFIX						?=	$(THORSANVIL_ROOT)/build
PREFIX_BIN					?=	$(PREFIX)/bin
PREFIX_LIB					?=	$(PREFIX)/lib
PREFIX_INC					?=	$(PREFIX)/include
PREFIX_INC3RD				?=	$(PREFIX)/include3rd
BUILD_EXTENSION				=	$(BUILD_EXTENSION_CXXSTDVER_$(CXXSTDVER))$(BUILD_EXTENSION_TYPE_$(TARGET_MODE))
BUILD_EXTENSION_CXXSTDVER_03	=   03
BUILD_EXTENSION_CXXSTDVER_11	=	11
BUILD_EXTENSION_TYPE_debug		=	D
BUILD_EXTENSION_TYPE_coverage	=	D


#
# For reference the default rules are
#	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS)
#	$(CC) $(LDFLAGS) N.o $(LOADLIBES) $(LDLIBS)

.PHONY:	all validate install objectarch clean veryclean test coverage

all:	PrintDebug buildDir Note_Building_$(TARGET_MODE) $(TARGET)
	@echo $(call colour_text, BLUE, "Done")
validate:		test 
install:		test try_install_head install_Dodebug install_Dorelease
install_debug:	test try_install_head install_Dodebug
install_release:test try_install_head install_Dorelease
	
install_Dodebug:
	$(MAKE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=debug all doInstall
install_Dorelease:
	$(MAKE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=release all doInstall

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
	@$(AR) -rv $(TARGET_MODE)/libobject.a $(GCOV_OBJ) 2>/dev/null
	@echo $(call colour_text, BLUE, "Done")
clean: test_clean
	$(RM) $(OBJ) $(GCOV) 
	$(RM) $(patsubst %.y,%.tab.cpp,$(YACC_SRC)) $(patsubst %.y,%.tab.hpp,$(YACC_SRC)) $(patsubst %.l,%.lex.cpp,$(LEX_SRC)) $(CLEAN_EXTRA)
	$(RM) $(TARGET) $(patsubst %.app,%,$(filter %.app,$(TARGET))) $(patsubst %,$(TARGET_MODE)/%,$(filter %.app,$(TARGET)))
veryclean: clean test_veryclean
	$(RM) -rf debug release coverage
test:
	@-$(RM) -rf coverage/libobject.a coverage/*.gcov coverage/*.gcda test/coverage/unittest.app
	@echo $(call section_title,Building Objects for Testing and Coverage)
	@$(MAKE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=coverage objectarch
	@echo $(call section_title,Building Unit Tests)
	@touch test/unittest.cpp
	@$(MAKE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=coverage -C test -f ../Makefile THORSANVIL_ROOT=$(THORSANVIL_ROOT) TEST_STATE=on TARGET=unittest.app LINK_LIBS="$(UNITTEST_LINK_LIBS)"
	@rm    test/unittest.cpp
	@echo $(call section_title,Running Unit Tests)
	@$(RUNTIME_SHARED_PATH_SET)=$(PREFIX_LIB) test/coverage/unittest.app
	@echo
	@echo
	@echo $(call colour_text, GRAY, $(MAKE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=coverage report_coverage COVERAGE=$(COVERAGE))
	@echo
	@echo
	@$(MAKE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=coverage coverage COVERAGE=$(COVERAGE)

install_app_%:
	@$(CP) $(TARGET_MODE)/$*.app $(PREFIX_BIN)/$*$(BUILD_EXTENSION)
	@echo $(call subsection_title, Install - $(TARGET_MODE) - $*$(BUILD_EXTENSION))

install_lib_%:
	@$(CP) $(TARGET_MODE)/lib$*.$(SO) $(PREFIX_LIB)/lib$*$(BUILD_EXTENSION).$(SO)
	@echo $(call subsection_title, Install - $(TARGET_MODE) - lib$*$(BUILD_EXTENSION).$(SO))

install_head_%: $(PREFIX_INC)/$(basename $(filter %.slib, $(TARGET))).Dir
	@$(CP) $* $(PREFIX_INC)/$(basename $(filter %.slib, $(TARGET)))/
	@echo $(call subsection_title, Install Header $*)

test_%:
	@if [ -d test ]; then $(MAKE) -C test -f ../Makefile THORSANVIL_ROOT=$(THORSANVIL_ROOT) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TEST_STATE=on TARGET=unittest.app $*; fi

coverage:	$(GCOV_REPORT) $(patsubst coverage/%.gcov, report_coverage_%, $(GCOV_REPORT))
	@left=`cat $(GCOV_ACTUAL) | grep '####' | wc -l`;				\
	 right=`cat $(GCOV_ACTUAL)| grep -v '\-:' | wc -l`;				\
	 res=`echo "$${left} > ($${right}  * 0.2)"  | bc`;				\
	 if [ $${res} -ne 0 ]; then										\
		echo $(RED_ERROR) $(call colour_text, PURPLE, Code Coverage does not exceed 80% of total);	\
		echo "Use: '$(MAKE) test PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) COVERAGE=On' to get details about coverage";		\
		exit 1;														\
	 else															\
		echo $(GREEN_OK) Code Coverage Passed;						\
	 fi
coverage/%.cpp.gcov: always
	@echo "Generating Coverage for $*.cpp"
	@if [ -e $*.cpp ]; then gcov --long-file-names --object-directory coverage $*.cpp 2>/dev/null	> coverage/$*.cpp.out ; fi;
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
	@if [ "$(COVERAGE)" = "$*.cpp" ]; then cat coverage/$*.tpp.gcov ; fi
	
debug:
	@$(MAKE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=debug	 all
release:
	@$(MAKE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=release all

buildDir:	$(TARGET_MODE).Dir


%.Dir:
	@if [ ! -e $* ]; then mkdir -p $*; fi

.PRECIOUS:	$(OBJ)
.PRECIOUS:	$(TARGET_MODE)/%.app
.PRECIOUS:	$(TARGET_MODE)/lib%.$(SO)
.PRECIOUS:	%.tab.cpp
.PRECIOUS:	%.lex.cpp


.PHONY:	%.app %.slib


	
%.app:		buildDir $(TARGET_MODE)/%.app
	@echo $(call subsection_title, Done Building $(TARGET_MODE)/$*)

xxlib:		buildDir Note_Building_(TARGET_MODE)/lib%.$(SO) $(TARGET_MODE)/lib%.$(SO)

%.slib:		buildDir $(TARGET_MODE)/lib%.$(SO)
	@echo $(call subsection_title, Done Building $(TARGET_MODE)/lib$*.$(SO))




$(TARGET_MODE)/%.app:	$(OBJ) $(TARGET_MODE)/%.o
	@echo $(call colour_text, GRAY, "$(CC) -o $@")	| awk '{printf "%-80s", $$0}'
	@$(CXX) -o $@ $(LDFLAGS) $(OBJ) $(TARGET_MODE)/$*.o$(LOADLIBES) $(ALL_LDLIBS) $(LDLIBS) $($*_LDLIBS)$(call expand,$($*_LINK_LIBS)) 2>makefile_tmp; \
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
	@echo $(call colour_text, GRAY, "$(CC) -shared -o $@")	| awk '{printf "%-80s", $$0}'
	@$(CXX) -shared -o $@ $(LDFLAGS) $(OBJ) $(LOADLIBES) $(ALL_LDLIBS) $(LDLIBS) 2>makefile_tmp; \
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
	@echo $(call colour_text, GRAY, "$(CXX) -c $^") | awk '{printf "%-80s", $$0}'
	@$(CXX) -c $^ -o $@ $(CPPFLAGS) $(CXXFLAGS) 2>makefile_tmp;	\
	if [ $$? != 0 ];									\
	then												\
		echo $(RED_ERROR);								\
		echo $(CXX) -c $^ -o $@ $(CPPFLAGS) $(CXXFLAGS);\
		echo "========================================";\
		cat makefile_tmp;								\
		exit 1;											\
	else 												\
		echo $(GREEN_OK);								\
		$(RM) makefile_tmp;								\
	fi

%.tab.cpp: %.y
	@echo $(call colour_text, GRAY, "$(YACC) $^") | awk '{printf "%-80s", $$0}'
	@$(YACC) -o $@ -d $< 2>makefile_tmp;				\
	if [ $$? != 0 ];									\
	then												\
		echo "Failed in Parser Generator";				\
		echo $(RED_ERROR);								\
		echo $(YACC) -o $@ -d $<;						\
		echo "========================================";\
		cat makefile_tmp;								\
		exit 1;											\
	else 												\
		echo $(GREEN_OK);								\
		$(RM) makefile_tmp;								\
	fi

%.lex.cpp: %.l
	@echo $(call colour_text, GRAY, "$(LEX) $^") | awk '{printf "%-80s", $$0}'
	@$(LEX) -t $< | sed -e 's/<stdout>/$*.lex.cpp/' -e 's/extern "C" int isatty/\/\/ Removed extern "C" int isatty/' > $@;	\
	if [ $$? != 0 ];									\
	then												\
		echo "Failed in Lexer Generator";				\
		echo $(RED_ERROR);								\
		echo $(LEX) -t $< > $@;							\
		echo "========================================";\
		cat $@;											\
		exit 1;											\
	else 												\
		echo $(GREEN_OK);								\
	fi

NotImplemented.%:
	@echo $(call colour_text, RED, "$* Not Implemented Yet")


.PHONY:	Print_Off Print_On
PrintDebug:	Print_$(VERBOSE)
Print_Off:
Print_On:
	@echo "SRC:		 $(SRC)"
	@echo "OBJ:		 $(OBJ)"
	@echo "GCOV:	 $(GCOV)"
	@echo "GCOV_OBJ: $(GCOV_OBJ)"

.PHONY: always
always:
	@echo 

