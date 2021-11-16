
# External
.PHONY:	ActionRunCoverage
.PHONY: coverage-%
# Internal
.PHONY:	reportCoverage
.PHONY:	check_obj_coverage check_hed_coverage

.PRECIOUS:	coverage/%.cpp.gcov
.PRECIOUS:	coverage/%.tpp.gcov
.PRECIOUS:	coverage/%.h.gcov

GCOV_OBJ_FILES			= $(patsubst coverage/%.o, coverage/%.cpp.out, $(filter-out $(MOCK_OBJECT) $(patsubst %.cpp,coverage/%.o, $(TMP_SRC)) $(APP_SRC) ,$(GCOV_OBJ)))
GCOV_HED_FILES			= $(patsubst %, coverage/%.out, $(filter-out $(APP_HEAD) $(TMP_HDR) %Config.h,$(wildcard *.h))) $(patsubst %.tpp,coverage/%.tpp.out, $(wildcard *.tpp))
GCOV_ALL_FILES			= $(filter-out $(MOCK_OBJECT) $(TMP_SRC) $(TMP_HDR) $(APP_SRC) ,$(GCOV_OBJ)) $(filter-out $(MOCK_OBJECT), $(wildcard test/*.cpp test/*.tpp test/*.h))

ActionRunCoverage:		report/coverage report/coverage.show
	@rm -f report/coverage.show


coverage-%:
	@if [[ ! -e $* ]]; then $(ECHO) $(RED_ERROR); $(ECHO) "No such file as >$*<"; exit 1; fi
	@if [[ ! -e coverage/$*.out ]]; then	$(MAKE) TARGET_MODE=coverage coverage/$*.out; fi
	@cat coverage/$*.gcov
	@cat coverage/$*.out

report/coverage.show:
	@cat report/coverage

report/coverage: report/test Makefile | report.Dir
	@$(ECHO) $(call section_title,Running Coverage) | tee report/coverage
	@if [[ -d test ]]; then $(MAKE) BASE=.. Ignore="/tmp/" THORSANVIL_ROOT=$(THORSANVIL_ROOT) TARGET_MODE=coverage -C test -f ../Makefile check_obj_coverage; fi
	@if [[ -d test ]]; then $(MAKE) TARGET_MODE=coverage check_obj_coverage; fi
	@if [[ -d test ]]; then $(MAKE) TARGET_MODE=coverage check_hed_coverage; fi
	@if [[ ! -d test ]]; then $(ECHO) "No Tests" | tee  -a report/coverage; fi
	@echo -n | cat - $$(ls coverage/*.out 2> /dev/null) >> report/coverage
	@$(MAKE) TARGET_MODE=coverage reportCoverage
	@touch report/coverage.show

reportCoverage:
	@$(ECHO) $(call subsection_title,Project-Coverage:) | awk '{printf("%-88s", $$0);}' | tee -a report/coverage
	@$(ECHO) $(call getPercentColour, $(shell  echo -n | cat - $$(ls coverage/*.gcov 2> /dev/null) | awk -f $(BUILD_ROOT)/tools/coverageCalc.awk)) | awk '{printf "%s%%\n", $$1}' | tee -a report/coverage
	@coverage=$$(echo -n | cat - $$(ls coverage/*.gcov 2> /dev/null) | awk -f $(BUILD_ROOT)/tools/coverageCalc.awk);\
	coverageInt=$$( printf "%.0f" $${coverage} );\
	if [[ $${coverageInt} -le $(COVERAGE_REQUIRED) ]]; then \
		$(ECHO) $(RED_ERROR)  $(call colour_text, GRAY, Coverage $${coverage} is below $(COVERAGE_REQUIRED)%);\
		exit 1;\
	fi

check_obj_coverage:	$(GCOV_OBJ_FILES)

check_hed_coverage: $(GCOV_HED_FILES)

coverage/%.out:			coverage/%.gcov | $(Ignore)coverage.Dir
	@touch $(Ignore)coverage/$*.out
	@$(ECHO) $(call colour_text, GRAY,$*) | awk '{printf "\t%-80s", $$1}' | tee $(Ignore)coverage/$*.out
	@if [[ "$(Ignore)" == "/tmp/" ]]; then	\
		$(ECHO) "Ignore Test File"; \
	else \
		$(ECHO) $(call getPercentColour,$(shell echo -n | cat - $$(ls coverage/$*.gcov 2>/dev/null) | awk -f $(BUILD_ROOT)/tools/coverageCalc.awk)) | awk '{printf "%s%%\n", $$1}' | tee -a coverage/$*.out;\
	fi
	
coverage/%.cpp.gcov:	coverage/%.o | coverage.Dir coverage/%.cpp.coverage.Dir
	@$(COV) $(COV_LONG_FLAG) --object-directory coverage $*.cpp > /dev/null 2>&1
	@for file in $$(ls $*.cpp.gcov 2> /dev/null); do mv $${file} coverage/;done
	@checkSubFile=$$(ls $*.cpp##*.gcov 2> /dev/null);				\
	if [[ $${checkSubFile} != "" ]]; then							\
		mv $*.cpp##*.gcov coverage/$*.cpp.coverage/;				\
	fi

coverage/%.tpp.gcov:	$(GCOV_ALL_FILES) | coverage.Dir
	$(BUILD_ROOT)/tools/coverageBuild $*.tpp
coverage/%.h.gcov:		$(GCOV_ALL_FILES) | coverage.Dir
	$(BUILD_ROOT)/tools/coverageBuild $*.h


#report/coverage: $(SRC) $(HEAD) report/test | report.Dir
#	@$(MAKE) $(PARALLEL) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=coverage INSTALL_ACTIVE=NO run_coverage

