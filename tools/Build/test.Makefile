
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

coverage/$(COVERAGE_LIB): $(SRC) $(HEAD) coverage/MockHeaders.h coverage/MockHeaders.cpp test/MockHeaderInclude.h | coverage.Dir
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
# Allows for easy mocking of system calls for unit tests.
#
coverage/Mock.built:	| coverage.Dir
$(BASE)/coverage/MockHeaders.h: $(THORSANVIL_ROOT)/build/mock/MockHeaders.h.prefix $(THORSANVIL_ROOT)/build/mock/MockHeaders.h.suffix test/MockHeaderInclude.h | coverage.Dir
	@rm -f coverage/MockHeaders.h.tmp
	@cat $(THORSANVIL_ROOT)/build/mock/MockHeaders.h.prefix	>> coverage/MockHeaders.h.tmp
	@perl -ne '/MOCK_(T?)FUNC\([ \t]*([^\) \t]*)/ and print $$1 eq "T" ? "ThorsAnvil::BuildTools::Mock::FuncType_$$2" : "decltype(::$$2)", "-$$2\n"' *	\
		| sort	| uniq																																	\
		| perl -ne '/([^-]*)-(.*)/ and print "extern MockFunctionHolder<RemoveNoExcept<$$1>> MOCK_BUILD_MOCK_SNAME($$2);\n"'							\
		>> coverage/MockHeaders.h.tmp
	@perl -ne '/MOCK_(T?)FUNC\([ \t]*([^\) \t]*)/ and print $$1 eq "T" ? "ThorsAnvil::BuildTools::Mock::FuncType_$$2" : "decltype(::$$2)", "-$$2\n"' *	\
		| sort	| uniq																																	\
		| perl -ne '/([^-]*)-(.*)/ and print "extern MockResultHolder<RemoveNoExcept<$$1>> MOCK2_BUILD_MOCK_SNAME($$2);\n"'								\
		>> coverage/MockHeaders.h.tmp
	@echo "class MockFunctionGroup {"						>>	coverage/MockHeaders.h.tmp
	@echo "    int built;"									>>	coverage/MockHeaders.h.tmp
	@perl -ne '/MOCK_(T?)FUNC\([ \t]*([^\) \t]*)/ and print "    MOCK2_$${1}MEMBER($$2);\n"' *.cpp *.h | sort | uniq >> coverage/MockHeaders.h.tmp
	@echo "    public:"										>>	coverage/MockHeaders.h.tmp
	@echo "        MockFunctionGroup(TA_Test& parent)"		>>	coverage/MockHeaders.h.tmp
	@echo "            : built(1)"							>>	coverage/MockHeaders.h.tmp
	@perl -ne '/MOCK_(T?)FUNC\([ \t]*([^\) \t]*)/ and print "            , MOCK2_$${1}MEM_PARAM($$2)\n"' *.cpp *.h | sort | uniq >> coverage/MockHeaders.h.tmp
	@echo "        {"										>>	coverage/MockHeaders.h.tmp
	@echo "				((void)parent);"					>>	coverage/MockHeaders.h.tmp
	@echo "        }"										>>	coverage/MockHeaders.h.tmp
	@echo "};"												>>	coverage/MockHeaders.h.tmp
	@cat $(THORSANVIL_ROOT)/build/mock/MockHeaders.h.suffix >>	coverage/MockHeaders.h.tmp
	if [[ -e coverage/MockHeaders.h ]]; then							\
		diff coverage/MockHeaders.h.tmp coverage/MockHeaders.h;			\
		if [[ $$? == 1 ]]; then											\
			echo "ReBuilt: coverage/MockHeaders.h";						\
			mv coverage/MockHeaders.h.tmp coverage/MockHeaders.h;		\
		else															\
			rm coverage/MockHeaders.h.tmp;								\
		fi;																\
	else																\
		echo "Built: coverage/MockHeaders.h";							\
		mv coverage/MockHeaders.h.tmp coverage/MockHeaders.h;			\
	fi


$(BASE)/coverage/MockHeaders.cpp: $(THORSANVIL_ROOT)/build/mock/MockHeaders.cpp.prefix $(THORSANVIL_ROOT)/build/mock/MockHeaders.cpp.suffix test/MockHeaderInclude.h coverage/Mock.built coverage/MockHeaders.h | coverage.Dir
	@rm -f coverage/MockHeaders.cpp.tmp
	@cat $(THORSANVIL_ROOT)/build/mock/MockHeaders.cpp.prefix >> coverage/MockHeaders.cpp.tmp
	@perl -ne '/MOCK_(T?)FUNC\([ \t]*([^\) \t]*)/ and print $$1 eq "T" ? "ThorsAnvil::BuildTools::Mock::FuncType_$$2" : "decltype(::$$2)", "-$$2\n"' *	\
		| sort	| uniq																																	\
		| perl -ne '/([^-]*)-(.*)/ and print "MockFunctionHolder<RemoveNoExcept<$$1>> MOCK_BUILD_MOCK_SNAME($$2)(\"$$2\", ::$$2);\n"'					\
		>> coverage/MockHeaders.cpp.tmp
	@perl -ne '/MOCK_(T?)FUNC\([ \t]*([^\) \t]*)/ and print $$1 eq "T" ? "ThorsAnvil::BuildTools::Mock::FuncType_$$2" : "decltype(::$$2)", "-$$2\n"' *	\
		| sort	| uniq																																	\
		| perl -ne '/([^-]*)-(.*)/ and print "MockResultHolder<RemoveNoExcept<$$1>> MOCK2_BUILD_MOCK_SNAME($$2)(\"$$2\", ::$$2);\n"'					\
		>> coverage/MockHeaders.cpp.tmp
	@cat $(THORSANVIL_ROOT)/build/mock/MockHeaders.cpp.suffix >> coverage/MockHeaders.cpp.tmp
	if [[ -e coverage/MockHeaders.cpp ]]; then							\
		diff coverage/MockHeaders.cpp.tmp coverage/MockHeaders.cpp;		\
		if [[ $$? == 1 ]]; then											\
			echo "ReBuilt: coverage/MockHeaders.cpp";					\
			mv coverage/MockHeaders.cpp.tmp coverage/MockHeaders.cpp;	\
		else															\
			rm coverage/MockHeaders.cpp.tmp;							\
		fi;																\
	else																\
		echo "Built: coverage/MockHeaders.cpp";							\
		mv coverage/MockHeaders.cpp.tmp coverage/MockHeaders.cpp;		\
	fi

$(BASE)/test/MockHeaderInclude.h: $(THORSANVIL_ROOT)/build/mock/buildMockHeaderInclude
	$(THORSANVIL_ROOT)/build/mock/buildMockHeaderInclude
