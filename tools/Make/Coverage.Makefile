
# External
.PHONY:	ActionRunCoverage
.PHONY: coverage-%
# Internal
.PHONY:	reportCoverage
.PHONY:	check_obj_coverage check_obj_head_coverage

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
	@if [[ ! -e coverage/$*.out ]]; then	$(MAKE) FILEDIR=$(FILEDIR) DISBALE_CONTROL_CODES=$(DISBALE_CONTROL_CODES) TARGET_MODE=coverage coverage/$*.out; fi
	@cat coverage/$*.gcov
	@cat coverage/$*.out

report/coverage.show:
	@cat report/coverage

report/coverage: report/test Makefile | report.Dir
	@$(ECHO) $(call section_title,Running Coverage) | tee report/coverage
	@if [[ -d test ]]; then $(MAKE) FILEDIR=$(FILEDIR) DISBALE_CONTROL_CODES=$(DISBALE_CONTROL_CODES) BASE=.. Ignore="/tmp/" THORSANVIL_ROOT=$(THORSANVIL_ROOT) TARGET_MODE=coverage -C test -f ../Makefile check_coverage; fi
	@if [[ -d test ]]; then $(MAKE) FILEDIR=$(FILEDIR) DISBALE_CONTROL_CODES=$(DISBALE_CONTROL_CODES) TARGET_MODE=coverage check_coverage; fi
	@if [[ ! -d test ]]; then $(ECHO) "No Tests" | tee  -a report/coverage; fi
	@echo -n | cat - $$(ls coverage/*.out 2> /dev/null) >> report/coverage
	@$(MAKE) FILEDIR=$(FILEDIR) DISBALE_CONTROL_CODES=$(DISBALE_CONTROL_CODES) TARGET_MODE=coverage reportCoverage
	@touch report/coverage.show

reportCoverage:
	@$(ECHO) $(call subsection_title,Project-Coverage:) | awk '{printf("%-88s", $$0);}' | tee -a report/coverage
	@$(ECHO) $(call getPercentColour, $(shell  echo -n | cat - $$(ls coverage/*.gcov 2> /dev/null) | awk -f $(BUILD_ROOT)/tools/coverageCalc.awk)) | awk '{printf "%s%%\n", $$1}' | tee -a report/coverage
	@coverage=$$(echo -n | cat - $$(ls coverage/*.gcov 2> /dev/null) | awk -f $(BUILD_ROOT)/tools/coverageCalc.awk);\
	coverageInt=$$( printf "%.0f" $${coverage} );\
	if [[ $${coverageInt} -lt $(COVERAGE_REQUIRED_TEST) ]]; then \
		$(ECHO) $(RED_ERROR)  $(call colour_text, $(MODE_TEXT_COLOR), Coverage $${coverage} is below $(COVERAGE_REQUIRED_TEST)%);\
		exit 1;\
	fi

ifeq ($(PARALLEL_BUILD),COV)
coverage/%.cpp.out  coverage/%.tpp.out  coverage/%.h.out:	| _start
coverage/%.cpp.gcov coverage/%.tpp.gcov coverage/%.h.gcov:	| _start
$(GCOV_OBJ_FILES) $(GCOV_HED_FILES) $(GCOV_ALL_FILES):		| _start
endif

check_coverage:	| coverage.Dir
	@rm -rf $(META)
	@$(ECHO) "Building Coverage:  Parallelism: $(JOBS)"
	@$(MAKE) -f$(BASE)/Makefile -j1 NAME="$*" TARGET_DST="$(TARGET_MODE)/$*.prog" THORSANVIL_ROOT="$(THORSANVIL_ROOT)" CXXSTDVER="$(CXXSTDVER)" BASE="$(BASE)" LINK_LIBS="$(LINK_LIBS)" EXLDLIBS="$(EXLDLIBS)" LDLIBS_FILTER="$(LDLIBS_FILTER)" UNITTEST_CXXFLAGS="$(UNITTEST_CXXFLAGS)" TEST_STATE="$(TEST_STATE)" LOADLIBES="$(LOADLIBES)" LDLIBS_EXTERN_BUILD="$(LDLIBS_EXTERN_BUILD)" TARGET_MODE="$(TARGET_MODE)" FILEDIR="$(FILEDIR)" DISBALE_CONTROL_CODES="$(DISBALE_CONTROL_CODES)" PARALLEL_BUILD=COV --no-print-directory _build_coverage
	@$(ECHO) "DONE---------------"

_build_coverage: _stop_coverage

_stop_coverage:  $(GCOV_OBJ_FILES) $(GCOV_HED_FILES)
	@if [ -p $(META)/pipe ]; then (exec 3<>$(META)/pipe && printf 'EXIT\n' >&3); fi
	@if [ -f $(META)/pid ]; then pid=$$(cat $(META)/pid); while kill -0 "$$pid" 2>/dev/null; do sleep 0.1; done; fi
	@rm -rf $(META)

coverage/%.out:			coverage/%.gcov | $(Ignore)coverage.Dir
	@touch $(Ignore)coverage/$*.out
	@if [[ "$(Ignore)" != "/tmp/" ]]; then					\
		result=$$( echo $(call getPercentColour,$(shell echo -n | cat - $$(ls coverage/$*.gcov 2>/dev/null) | awk -f $(BUILD_ROOT)/tools/coverageCalc.awk)) | awk '{printf "%s\n", $$1}');\
		printf "%-$(LINE_WIDTH)s" '$*' >> coverage/$*.out;	\
		printf "$${result}\n"          >> coverage/$*.out;	\
		$(call BUILD_PIPE_OUT,STATUS,"X",$*,$${result});	\
	fi

X:
	@$(ECHO) $(call colour_text, $(MODE_TEXT_COLOR),$*) | awk '{printf "\t%-$(LINE_WIDTH)s", $$1}' | tee $(Ignore)coverage/$*.out
		result=$$( echo $(call getPercentColour,$(shell echo -n | cat - $$(ls coverage/$*.gcov 2>/dev/null) | awk -f $(BUILD_ROOT)/tools/coverageCalc.awk)) | awk '{printf "%s%%\n", $$1}' | tee -a coverage/$*.out);\
	
coverage/%.cpp.gcov:	coverage/%.o | coverage.Dir coverage/%.cpp.coverage.Dir
	$(call BUILD_PIPE_OUT,START,$*.cpp,$*.cpp,"Calculating Coverage")
	@$(COV_TOOL) $(COV_LONG_FLAG) --object-directory coverage $*.cpp > /dev/null 2>&1
	@for file in $$(ls $*.cpp.gcov 2> /dev/null); do mv $${file} coverage/;done
	@checkSubFile=$$(ls $*.cpp##*.gcov 2> /dev/null);				\
	if [[ $${checkSubFile} != "" ]]; then							\
		mv $*.cpp##*.gcov coverage/$*.cpp.coverage/;				\
	fi
	$(call BUILD_PIPE_OUT,DONE,$*.cpp,$*.cpp,Done)

coverage/%.tpp.gcov:	$(GCOV_ALL_FILES) | coverage.Dir
	$(call BUILD_PIPE_OUT,START,$*.tpp,$*.tpp,"Calculating Coverage")
	$(BUILD_ROOT)/tools/coverageBuild $*.tpp
	$(call BUILD_PIPE_OUT,DONE,$*.tpp,$*.tpp,Done)
coverage/%.h.gcov:		$(GCOV_ALL_FILES) | coverage.Dir
	$(call BUILD_PIPE_OUT,START,$*.h,$*.h,"Calculating Coverage")
	$(BUILD_ROOT)/tools/coverageBuild $*.h
	$(call BUILD_PIPE_OUT,DONE,$*.h,$*.h,Done)


#report/coverage: $(SRC) $(HEAD) report/test | report.Dir
#	@$(MAKE) $(PARALLEL) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=coverage INSTALL_ACTIVE=NO run_coverage

