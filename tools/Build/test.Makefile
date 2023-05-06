
# External
.PHONY:	ActionRunUnitTest
.PHONY:	test-% testrun.% debugrun.%
# Internal
.PHONY:	build_unit_test run_unit_test
.PHONY:	reportErrorCheck

TEST_FILES					= $(wildcard test/*.cpp test/*.h test/*.tpp)
GCOV_LIB					= $(if $(GCOV_OBJ),objectarch)
COVERAGE_LIB				= UnitTest$(strip $(DEFER_NAME))


ActionRunUnitTest:		report/test	 report/test.show reportErrorCheck
test-%:
	$(MAKE) TARGET_MODE=coverage	build_unit_test
	@TESTNAME=$* THOR_LOG_LEVEL=$${THOR_LOG_LEVEL:-DEBUG} make TARGET_MODE=coverage run_unit_test

testrun.%:
	$(MAKE) TARGET_MODE=coverage	build_unit_test
	@$(RUNTIME_SHARED_PATH_SET)=$(PREFIX_LIB)/lib:$(DEFAULT_LIB_DIR) THOR_LOG_LEVEL=$${THOR_LOG_LEVEL:-DEBUG} test/coverage/unittest.app --gtest_filter=$*

debugrun.%:
	$(MAKE) TARGET_MODE=coverage	build_unit_test
	@$(RUNTIME_SHARED_PATH_SET)=$(PREFIX_LIB)/lib:$(DEFAULT_LIB_DIR) THOR_LOG_LEVEL=$${THOR_LOG_LEVEL:-DEBUG} lldb -- test/coverage/unittest.app --gtest_filter=$*

report/test:  $(SRC) $(HEAD) $(TEST_FILES) | report.Dir
	@if [[ -d test ]]; then $(MAKE) TARGET_MODE=coverage		build_unit_test; fi
	@if [[ -d test ]]; then $(MAKE) TARGET_MODE=coverage		run_unit_test; fi
	@if [[ ! -d test ]]; then $(ECHO) "No Tests" | tee  report/test; fi
	@touch report/test.show

report/test.show: | report.Dir
	@cat report/test

reportErrorCheck:
	@rm -f report/test.show
	@count=$$(grep '\[  FAILED  \]' report/test | wc -l | awk '{print $$1}');	\
	if [[ $${count} != 0 ]]; then $(ECHO) $(RED_ERROR); $(ECHO) $${count} tests failed;exit 1; fi


build_unit_test:	test/coverage/unittest.app

test/coverage/unittest.app: coverage/$(COVERAGE_LIB) $(TEST_FILES) | test/coverage.Dir
	@touch test/unittest.cpp
	# Make sure the test dependencies have been updated first.
	$(MAKE) TARGET_OVERRIDE=unittest.app					\
			BASE=..											\
			THORSANVIL_ROOT=$(THORSANVIL_ROOT)				\
			TEST_STATE=on									\
			-C test											\
			-f ../Makefile									\
			makedependency
	$(MAKE) TARGET_OVERRIDE=unittest.app					\
			BASE=..											\
			THORSANVIL_ROOT=$(THORSANVIL_ROOT)				\
			TEST_STATE=on									\
			LOADLIBES="-L$(BASE)/coverage -l$(COVERAGE_LIB)"\
			LDLIBS_EXTERN_BUILD="$(LDLIBS_EXTERN_BUILD)"	\
			UNITTEST_CXXFLAGS="$(UNITTEST_CXXFLAGS)"		\
			LINK_LIBS="$(UNITTEST_LINK_LIBS)"				\
			EXLDLIBS="$(UNITTEST_LDLIBS)"					\
			-C test											\
			-f ../Makefile									\
			item
	@rm test/unittest.cpp

coverage/$(COVERAGE_LIB): $(SRC) $(HEAD) coverage/MockHeaders.h coverage/ThorMock.h | coverage.Dir
	@$(MAKE) TARGET_OVERRIDE=$(COVERAGE_LIB).a item
	@touch coverage/$(COVERAGE_LIB)

run_unit_test:
	@$(ECHO) $(call section_title,Running Unit Tests)
	-@$(RM) coverage/*gcda coverage/*gcov test/coverage/*gcda test/coverage/*gcov
	@$(ECHO) "$(RUNTIME_SHARED_PATH_SET)=$(RUNTIME_PATHS_USED_TO_LOAD) test/coverage/unittest.app --gtest_filter=$(TESTNAME)"
	@($(RUNTIME_SHARED_PATH_SET)=$(RUNTIME_PATHS_USED_TO_LOAD) THOR_LOG_LEVEL=$${THOR_LOG_LEVEL:-0} test/coverage/unittest.app --gtest_color=yes --gtest_filter=$(TESTNAME) || \
						($(ECHO) "$(RUNTIME_SHARED_PATH_SET)=$(RUNTIME_PATHS_USED_TO_LOAD) lldb test/coverage/unittest.app" && exit 1)) | tee report/test


#
# Build the mock headers from the test/Mock.def file.
# Allows for easy mocking of system calls for unit tests.
#
coverage/Mock.built:	| coverage.Dir
test/Mock.def:
coverage/MockHeaders.h: test/Mock.def coverage/Mock.built | coverage.Dir
	@touch coverage/Mock.built
	@cp $(THORSANVIL_ROOT)/build/mock/MockHeaders.h.prefix coverage/MockHeaders.h
	@if [[ -e test/Mock.def ]]; then \
		perl -ne '/(#include .*)/ and print "$$1\n"' test/Mock.def >> coverage/MockHeaders.h; \
		cat $(THORSANVIL_ROOT)/build/mock/MockHeaders.h.preamb >> coverage/MockHeaders.h; \
		perl -ne '/MOCK_SYSTEM_FUNC\(([^)]*)\)/ and print "extern std::function<RemoveNoExceptType<decltype(::$$1)>> mock$$1;\n"' test/Mock.def >> coverage/MockHeaders.h; \
		cat $(THORSANVIL_ROOT)/build/mock/MockHeaders.h.median >> coverage/MockHeaders.h; \
		perl -ne '/MOCK_SYSTEM_FUNC\(([^)]*)\)/ and print "#define $$1 ThorsAnvil::BuildTools::Mock::mock$$1\n"' test/Mock.def >> coverage/MockHeaders.h;\
	fi
	@cat $(THORSANVIL_ROOT)/build/mock/MockHeaders.h.suffix >> coverage/MockHeaders.h

coverage/ThorMock.h: coverage/MockHeaders.h | coverage.Dir
	@cp $(THORSANVIL_ROOT)/build/mock/ThorMock.h.prefix coverage/ThorMock.h
	@cat $(THORSANVIL_ROOT)/build/mock/ThorMock.h.preamb >> coverage/ThorMock.h
	@if [ -e test/Mock.def ]; then		\
		perl -ne '/MOCK_SYSTEM_FUNC\(([^)]*)\)/ and print "#undef $$1\n"' test/Mock.def >> coverage/ThorMock.h; \
	fi
	@cat $(THORSANVIL_ROOT)/build/mock/ThorMock.h.median >> coverage/ThorMock.h
	@cat $(THORSANVIL_ROOT)/build/mock/ThorMock.h.suffix >> coverage/ThorMock.h

coverage/MockHeaders.cpp: coverage/MockHeaders.h | coverage.Dir
	@cp $(THORSANVIL_ROOT)/build/mock/MockHeaders.cpp.prefix coverage/MockHeaders.cpp
	@cat $(THORSANVIL_ROOT)/build/mock/MockHeaders.cpp.preamb >> coverage/MockHeaders.cpp
	@if [ -e test/Mock.def ]; then		\
		perl -ne '/MOCK_SYSTEM_FUNC\(([^)]*)\)/ and print "#undef $$1\n"' test/Mock.def >> coverage/MockHeaders.cpp; \
	fi
	@cat $(THORSANVIL_ROOT)/build/mock/MockHeaders.cpp.median >> coverage/MockHeaders.cpp
	@if [ -e test/Mock.def ]; then		\
		perl -ne '/MOCK_SYSTEM_FUNC\(([^)]*)\)/ and print "std::function<RemoveNoExceptType<decltype(::$$1)>> mock$$1 = $$1;\n"' test/Mock.def >> coverage/MockHeaders.cpp; \
	fi
	@cat $(THORSANVIL_ROOT)/build/mock/MockHeaders.cpp.suffix >> coverage/MockHeaders.cpp


#($(ECHO) "$(RUNTIME_SHARED_PATH_SET)=$(RUNTIME_PATHS_USED_TO_LOAD) lldb test/coverage/unittest.app" && exit 1)) | tee report/test;\
## build_unit_test.old:
## 	$(MAKE) -n $(PARALLEL) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=coverage INSTALL_ACTIVE=$(INSTALL_ACTIVE) objectarch
## 		$(MAKE) $(PARALLEL) BASE=.. VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=coverage INSTALL_ACTIVE=$(INSTALL_ACTIVE) -C test -f ../Makefile THORSANVIL_ROOT=$(THORSANVIL_ROOT) BUILD_ROOT=$(BUILD_ROOT) LOCAL_ROOT=$(LOCAL_ROOT) TEST_STATE=on TARGET=unittest.app LINK_LIBS="$(UNITTEST_LINK_LIBS)" EXLDLIBS="$(UNITTEST_LDLIBS)" COVERAGE_TARGET="$(COVERAGE_TARGET)" GCOV_LIBOBJ_PASS="$(GCOV_LIBOBJ)" item;	\
##



