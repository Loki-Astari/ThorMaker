# =============================================================================
# rules/link.mk — link-time pattern rules and TARGET-suffix dispatch
#
# Declares the %.prog / %.a / %.slib / %.head / %.defer / %.test suffix rules
# that the project's TARGET names, and the $(TARGET_MODE)/%.prog,
# $(TARGET_MODE)/lib%.a, $(TARGET_MODE)/lib%.$(SO) pattern rules that
# kick off a parallel sub-make via the rules/parallel.mk engine.
#
# Requires: TARGET_MODE SO BASE JOBS META BUILD_EXTENSION            (core)
#           colour_text subsection_title                              (core/colour.mk)
#           _build_prog _build_static_lib _build_dynamic_lib          (rules/parallel.mk)
# Defines:  (nothing consumable)
# Goals:    %.prog %.a %.slib %.head %.defer %.test
#           $(TARGET_MODE)/%.prog $(TARGET_MODE)/lib%.a $(TARGET_MODE)/lib%.$(SO)
# =============================================================================

.PRECIOUS:	$(TARGET_MODE)/%.prog
.PRECIOUS:	$(TARGET_MODE)/lib%.$(SO)
.PRECIOUS:  $(TARGET_MODE)/lib%.a


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


$(TARGET_MODE)/%.prog:	%.cpp $(SRC) $(HEAD) | $(TARGET_MODE).Dir
	@rm -rf $(META)
	@if [[ "$${DEBUG}" == "1" ]];then $(ECHO) "Building: PROG: $(TARGET_MODE)/$*.prog  Dependencies:  Parallelism: $(JOBS)";fi
	@$(MAKE) -f$(BASE)/Makefile -j$(JOBS) NAME="$*" TARGET_DST="$(TARGET_MODE)/$*.prog" PARALLEL_BUILD=OBJ --no-print-directory _build_prog
	@if [[ "$${DEBUG}" == "1" ]];then $(ECHO) "DONE-----------";fi

$(TARGET_MODE)/lib%.a:	$(SRC) $(HEAD) | $(TARGET_MODE).Dir
	@rm -rf $(META)
	@if [[ "$${DEBUG}" == "1" ]];then $(ECHO) "Building: STAT: $(TARGET_MODE)/$*.prog  Dependencies:  Parallelism: $(JOBS)";fi
	@$(MAKE) -f$(BASE)/Makefile -j$(JOBS) NAME="$*" TARGET_DST="$(TARGET_MODE)/lib$*.a" PARALLEL_BUILD=OBJ --no-print-directory _build_static_lib
	@if [[ "$${DEBUG}" == "1" ]];then $(ECHO) "DONE-----------";fi

$(TARGET_MODE)/lib%.$(SO):	$(SRC) $(HEAD) | $(TARGET_MODE).Dir
	@rm -rf $(META)
	@if [[ "$${DEBUG}" == "1" ]];then $(ECHO) "Building: DYNA: $(TARGET_MODE)/$*.prog  Dependencies:  Parallelism: $(JOBS)";fi
	@$(MAKE) -f$(BASE)/Makefile -j$(JOBS) NAME="$*" TARGET_DST="$(TARGET_MODE)/lib$*.$(SO)" PARALLEL_BUILD=OBJ --no-print-directory _build_dynamic_lib
	@if [[ "$${DEBUG}" == "1" ]];then $(ECHO) "DONE-----------";fi

makeDep: | makedependency.Dir
	@rm -rf $(META)
	@if [[ "$${DEBUG}" == "1"1 ]];then $(ECHO) "Building: DEPS: Dependencies:  Parallelism: $(JOBS)";fi
	@$(MAKE) -f$(BASE)/Makefile -j$(JOBS) NAME="$*" TARGET_DST="$(TARGET_MODE)/lib$*.a" PARALLEL_BUILD=DEP --no-print-directory _build_dependency
	@if [[ "$${DEBUG}" == "1" ]];then $(ECHO) "DONE-----------";fi
