
testonly:
	make build_unit_test run_unit_test_only
test-%:
	TESTNAME=$* make build_unit_test run_unit_test_only

testrun.%:	build_unit_test
	DYLD_LIBRARY_PATH=$(PREFIX_LIB)/lib:/usr/local/lib test/coverage/unittest.app --gtest_filter=$*

debugrun.%: build_unit_test
	DYLD_LIBRARY_PATH=$(PREFIX_LIB)/lib:/usr/local/lib lldb -- test/coverage/unittest.app --gtest_filter=$*


#($(ECHO) "$(RUNTIME_SHARED_PATH_SET)=$(RUNTIME_PATH):$(LDLIBS_EXTERN_PATH) lldb test/coverage/unittest.app" && exit 1)) | tee coverage/test.report;\


build_unit_test:
	@-$(RM) -rf coverage/libobject.a coverage/*gcov coverage/*.gcda test/coverage/unittest.app test/coverage/*gcov test/coverage/*gcda
	@$(ECHO) $(call section_title,Building Objects for Testing and Coverage)
	@echo "int aThorsAnvilUnitTestMarker = 1;" > ThorsAnvilUnitTestMarker.cpp
	@$(MAKE) $(PARALLEL) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=coverage INSTALL_ACTIVE=$(INSTALL_ACTIVE) gcovarch
	@rm ThorsAnvilUnitTestMarker.cpp
	@$(ECHO) $(call section_title,Building Unit Tests)
	@result=0;												\
	if ( test -d test ); then								\
		touch test/unittest.cpp;							\
		$(MAKE) $(PARALLEL) BASE=.. VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=coverage INSTALL_ACTIVE=$(INSTALL_ACTIVE) -C test -f ../Makefile THORSANVIL_ROOT=$(THORSANVIL_ROOT) BUILD_ROOT=$(BUILD_ROOT) LOCAL_ROOT=$(LOCAL_ROOT) TEST_STATE=on TARGET=unittest.app LINK_LIBS="$(UNITTEST_LINK_LIBS)" EXLDLIBS="$(UNITTEST_LDLIBS)" COVERAGE_TARGET="$(COVERAGE_TARGET)" GCOV_LIBOBJ_PASS="$(GCOV_LIBOBJ)" item;	\
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
	@$(RM) coverage/test.report
	echo -n > coverage/test.report.out
	@if ( test -d test ); then								\
		$(ECHO) $(call section_title,Running Unit Tests);	\
		$(ECHO) "$(RUNTIME_SHARED_PATH_SET)=$(RUNTIME_PATH):$(LDLIBS_EXTERN_PATH) test/coverage/unittest.app --gtest_filter=$(TESTNAME)";	\
		($(RUNTIME_SHARED_PATH_SET)=$(RUNTIME_PATH):$(LDLIBS_EXTERN_PATH) test/coverage/unittest.app --gtest_color=yes --gtest_filter=$(TESTNAME) ||	\
							($(ECHO) "$(RUNTIME_SHARED_PATH_SET)=$(RUNTIME_PATH):$(LDLIBS_EXTERN_PATH) lldb test/coverage/unittest.app" && exit 1)) | tee -a coverage/test.report;\
	else													\
		echo "NO Tests" > coverage/test.report;				\
	fi


