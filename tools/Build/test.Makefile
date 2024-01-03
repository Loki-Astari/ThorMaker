
# External
.PHONY:	ActionRunUnitTest
.PHONY:	test-% testrun.% debugrun.%
# Internal
.PHONY:	build_unit_test run_unit_test
.PHONY:	reportErrorCheck

TEST_FILES					= $(wildcard test/*.cpp test/*.h test/*.tpp)
GCOV_LIB					= $(if $(GCOV_OBJ),objectarch)
COVERAGE_LIB				= UnitTest$(strip $(DEFER_NAME))
UNITTEST_LINK_LIBS_BULD		= $(if $(HEADER_ONLY), ,$(LINK_LIBS) $(UNITTEST_LINK_LIBS))


ActionRunUnitTest:		report/test	 report/test.show reportErrorCheck
test-%:
	$(MAKE) TARGET_MODE=coverage	build_unit_test
	@TESTNAME=$* THOR_LOG_LEVEL=$${THOR_LOG_LEVEL:-DEBUG} make TARGET_MODE=coverage run_unit_test

testrun.%:
	$(MAKE) TARGET_MODE=coverage	build_unit_test
	@$(RUNTIME_SHARED_PATH_SET)="$(PREFIX_LIB)/lib:$(DEFAULT_LIB_DIR)" THOR_LOG_LEVEL=$${THOR_LOG_LEVEL:-DEBUG} test/coverage/unittest.prog --gtest_filter=$*

debugrun.%:
	$(MAKE) TARGET_MODE=coverage	build_unit_test
	@$(RUNTIME_SHARED_PATH_SET)="$(PREFIX_LIB)/lib:$(DEFAULT_LIB_DIR)" THOR_LOG_LEVEL=$${THOR_LOG_LEVEL:-DEBUG} lldb -- test/coverage/unittest.prog --gtest_filter=$*

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


build_unit_test:	test/coverage/unittest.prog

test/coverage/unittest.prog: coverage/$(COVERAGE_LIB) $(TEST_FILES) | test/coverage.Dir
	@touch test/unittest.cpp
	# Make sure the test dependencies have been updated first.
	$(MAKE) TARGET_OVERRIDE=unittest.prog					\
			BASE=..											\
			THORSANVIL_ROOT=$(THORSANVIL_ROOT)				\
			TEST_STATE=on									\
			-C test											\
			-f ../Makefile									\
			makedependency
	$(MAKE) TARGET_OVERRIDE=unittest.prog					\
			BASE=..											\
			THORSANVIL_ROOT=$(THORSANVIL_ROOT)				\
			TEST_STATE=on									\
			LOADLIBES="-L$(BASE)/coverage -l$(COVERAGE_LIB)"\
			LDLIBS_EXTERN_BUILD="$(LDLIBS_EXTERN_BUILD)"	\
			UNITTEST_CXXFLAGS="$(UNITTEST_CXXFLAGS)"		\
			LINK_LIBS="$(UNITTEST_LINK_LIBS_BULD)"			\
			EXLDLIBS="$(UNITTEST_LDLIBS) "					\
			LDLIBS_FILTER="$(LDLIBS_FILTER)"				\
			-C test											\
			-f ../Makefile									\
			item
	@rm test/unittest.cpp

coverage/$(COVERAGE_LIB): $(SRC) $(HEAD) coverage/MockHeaders.h | coverage.Dir
	@$(MAKE) TARGET_OVERRIDE=$(COVERAGE_LIB).a item
	@touch coverage/$(COVERAGE_LIB)

run_unit_test: $(PRETEST)
	@$(ECHO) $(call section_title,Running Unit Tests)
	-@$(RM) coverage/*gcda coverage/*gcov test/coverage/*gcda test/coverage/*gcov
	@$(ECHO) "$(RUNTIME_SHARED_PATH_SET)="$(RUNTIME_PATHS_USED_TO_LOAD)" test/coverage/unittest.prog --gtest_filter=$(TESTNAME)"
	@$(ECHO) "To easily debug use:"
	@$(ECHO) "     $(RUNTIME_SHARED_PATH_SET)="$(RUNTIME_PATHS_USED_TO_LOAD)" lldb test/coverage/unittest.prog"
	@$(RUNTIME_SHARED_PATH_SET)="$(RUNTIME_PATHS_USED_TO_LOAD)" THOR_LOG_LEVEL=$${THOR_LOG_LEVEL:-0} test/coverage/unittest.prog --gtest_color=yes --gtest_filter=$(TESTNAME) | tee report/test; exit $${PIPESTATUS[0]}


#
# Build the mock headers from the test/Mock.def file.
# Allows for easy mocking of system calls for unit tests.
#
coverage/Mock.built:	| coverage.Dir
coverage/Mock2.built:	| coverage.Dir
test/Mock.def:
coverage/MockHeaders.h: test/Mock.def coverage/Mock.built | coverage.Dir
	@touch coverage/Mock.built
	@cp $(THORSANVIL_ROOT)/build/mock/MockHeaders.h.prefix coverage/MockHeaders.h
	@perl -ne '/MOCK_TSYS\([ \t]*([^, \t]*),[ \t]*([^, \t]*)/ and print "$$1:$$2\n"' test/*.cpp | sort | uniq | perl -ne '/([^:]*):(.*)/ and print "extern MockFunctionHolder<$$1> mock_$(THOR_PACKAGE_NAME)_$$2;\n"' >> coverage/MockHeaders.h
	@perl -ne '/MOCK_FUNC\([ \t]*([^\) \t]*)/ and print "$$1\n"' *.cpp | sort | uniq | perl -ne '/(.*)/ and print "extern MockFunctionHolder<RemoveNoExceptType<decltype(::$$1)>> mock_$(THOR_PACKAGE_NAME)_$$1;\n"' >> coverage/MockHeaders.h
	@cat $(THORSANVIL_ROOT)/build/mock/MockHeaders.h.suffix >> coverage/MockHeaders.h

coverage/MockHeaders2.h: coverage/Mock2.built | coverage.Dir
	@cp $(THORSANVIL_ROOT)/build/mock/MockHeaders2.h.prefix coverage/MockHeaders2.h
	@perl -ne '/MOCK_(T?)FUNC\([ \t]*([^\) \t]*)/ and print $$1 eq "T" ? "FuncType_$$2" : "decltype(::$$2)", "-$$2\n"' *.cpp								\
		| sort																																		\
		| uniq																																		\
		| perl -ne '/([^-]*)-(.*)/ and print "extern MockFunctionHolder<RemoveNoExcept<$$1>> mock_$(THOR_PACKAGE_NAME)_$$2;\n"'							\
		>> coverage/MockHeaders2.h
	@cat $(THORSANVIL_ROOT)/build/mock/MockHeaders2.h.suffix >> coverage/MockHeaders2.h

coverage/MockHeaders.cpp: coverage/MockHeaders.h | coverage.Dir
	@cp $(THORSANVIL_ROOT)/build/mock/MockHeaders.cpp.prefix coverage/MockHeaders.cpp
	@perl -ne '/MOCK_TSYS\([ \t]*([^, \t]*),[ \t]*([^, \t]*)/ and print "$$1:$$2\n"' test/*.cpp | sort | uniq | perl -ne '/([^:]*):(.*)/ and print "MockFunctionHolder<$$1> mock_$(THOR_PACKAGE_NAME)_$$2(\"$$2\", ::$$2);\n"' >> coverage/MockHeaders.cpp
	@perl -ne '/MOCK_FUNC\([ \t]*([^\) \t]*)/ and print "$$1\n"' *.cpp | sort | uniq | perl -ne '/(.*)/ and print "MockFunctionHolder<RemoveNoExceptType<decltype(::$$1)>> mock_$(THOR_PACKAGE_NAME)_$$1(\"$$1\", ::$$1);\n"' >> coverage/MockHeaders.cpp;
	@cat $(THORSANVIL_ROOT)/build/mock/MockHeaders.cpp.suffix >> coverage/MockHeaders.cpp

coverage/MockHeaders2.cpp: coverage/MockHeaders2.h | coverage.Dir
	@cp $(THORSANVIL_ROOT)/build/mock/MockHeaders2.cpp.prefix coverage/MockHeaders2.cpp
	@perl -ne '/MOCK_(T?)FUNC\([ \t]*([^\) \t]*)/ and print $$1 eq "T" ? "FuncType_$$2" : "decltype(::$$2)", "-$$2\n"' *.cpp								\
		| sort																																		\
		| uniq																																		\
		| perl -ne '/([^-]*)-(.*)/ and print "MockFunctionHolder<RemoveNoExcept<$$1>> mock_$(THOR_PACKAGE_NAME)_$$2(\"$$2\", ::$$2);\n"'				\
		>> coverage/MockHeaders2.cpp
	@cat $(THORSANVIL_ROOT)/build/mock/MockHeaders2.cpp.suffix >> coverage/MockHeaders2.cpp


