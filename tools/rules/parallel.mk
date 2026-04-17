# =============================================================================
# rules/parallel.mk — parallel build orchestration engine
#
# Runs compile/link/dep jobs under a background monitor pipe that
# serialises build output into a readable progress display.
#
# The sub-make re-enters the project's Makefile with PARALLEL_BUILD set to
# OBJ or DEP, which activates the order-only _start dependency below and
# makes the _build_*/_stop_* chain fire.
#
# Requires: META JOBS LINE_WIDTH DISABLE_CONTROL_CODES              (core/variables.mk)
#           MONITOR (shell script)                                   (defined here)
#           colour_text GREEN_OK RED_ERROR MODE_TEXT_COLOR           (core/colour.mk)
#           CXX AR ARFLAGS LDFLAGS PLATFORM_LIB CXXFLAGS ARCH_FLAG   (core/platform.mk + build.mk)
#           LOADLIBES ALL_LDLIBS LDLIBS LDLIBS_EXTERN_RPATH
#           OBJ DEFER_OBJ GCOV_OBJ DEP NAME TARGET_DST
#           THORSANVIL_STATICLOADALL SHARED_LIB_FLAG_$(PLATFORM)
# Defines:  META MONITOR JOBS BUILD_PIPE_OUT
# Goals:    _start _build_prog _stop_prog
#           _build_static_lib _stop_static_lib
#           _build_dynamic_lib _stop_dynamic_lib
#           _build_dependency _stop_dependency
# =============================================================================

META							:= buildmeta
MONITOR							:= $(BUILD_ROOT)/tools/scripts/build-monitor.sh
JOBS							?= 8
BUILD_PIPE_OUT					= if [ -p $(META)/pipe ]; then (exec 3<>$(META)/pipe && printf '%s:%s:%s:%s\n' $1 $2 $3 $4 >&3); else printf "%-${LINE_WIDTH}s" $3; printf $4; printf '\n'; fi

.PHONY:		_start
.PHONY:		_build_prog         _stop_prog
.PHONY:		_build_static_lib   _stop_static_lib
.PHONY:		_build_dynamic_lib  _stop_dynamic_lib
.PHONY:		_build_dependency   _stop_dependency

_start:
	@mkdir -p $(META)
	@rm -f $(META)/pipe
ifeq ($(DISABLE_CONTROL_CODES),TRUE)
	@echo 0 > $(META)/pid
else
	@mkfifo $(META)/pipe
	@bash $(MONITOR) $(META)/pipe $(JOBS) $(LINE_WIDTH) $$PPID & printf '%d\n' $$! > $(META)/pid
endif


# Only set up _start (pipe/monitor) dependency in sub-makes that do
# actual parallel builds. Sub-makes pass PARALLEL_BUILD=OBJ or
# PARALLEL_BUILD=DEP to activate the appropriate dependencies.
ifeq ($(PARALLEL_BUILD),OBJ)
$(OBJ) $(DEFER_OBJ) $(TARGET_MODE)/$(NAME).o: | _start
-include makedependency/*
endif
ifeq ($(PARALLEL_BUILD),DEP)
$(DEP): | _start
endif


_build_prog:			_stop_prog
_build_static_lib:		_stop_static_lib
_build_dynamic_lib:		_stop_dynamic_lib
_build_dependency:		_stop_dependency

_stop_prog:	$(OBJ) $(DEFER_OBJ) $(TARGET_MODE)/$(NAME).o
	@if [ -p $(META)/pipe ]; then (exec 3<>$(META)/pipe && printf 'EXIT\n' >&3); fi
	@if [ -p $(META)/pipe ]; then pid=$$(cat $(META)/pid); if [ $$pid != 0 ]; then while kill -0 "$$pid" 2>/dev/null; do sleep 0.1; done; fi; fi
	@failed=0; \
	 for f in $(META)/err.*; do \
	   [ -f "$$f" ] || continue; \
	   cat "$$f" >&2; \
	   failed=1; \
	 done; \
	 rm -rf $(META); \
	 if ( test $$failed != 0 ); then exit 1; fi
	@if ( test "$(VERBOSE)" = "On" ); then \
		$(ECHO) '$(CXX) -o $(TARGET_DST) $(LDFLAGS) $(PLATFORM_LIB) $^ $(CXXFLAGS) $(ARCH_FLAG) $(call expandFlag,$($(NAME)_CXXFLAGS)) $(LOADLIBES) $(ALL_LDLIBS) $(LDLIBS) $($(NAME)_LDLIBS) $(call expand,$($(NAME)_LINK_LIBS))' ; \
	else $(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), "$(CXX) -o $(TARGET_DST) $(OPTIMIZER_FLAGS_DISP)  $(call expandFlag,$($(NAME)_CXXFLAGS))")	| awk '{printf "%-$(LINE_WIDTH)s", $$0}' ;	fi
	@export tmpfile=$(shell $(MKTEMP));					\
	$(LDLIBS_EXTERN_RPATH) $(CXX) -o $(TARGET_DST) $(LDFLAGS) $(PLATFORM_LIB) $^ $(CXXFLAGS) $(ARCH_FLAG) $(call expandFlag,$($(NAME)_CXXFLAGS)) $(LOADLIBES) $(ALL_LDLIBS) $(LDLIBS) $($(NAME)_LDLIBS) $(call expand,$($(NAME)_LINK_LIBS)) 2> $${tmpfile}; \
	if [ $$? != 0 ];									\
	then												\
		$(ECHO) $(RED_ERROR);							\
		$(ECHO) "EX_RPATH: $(LDLIBS_EXTERN_RPATH)";		\
		$(ECHO) $(CXX) -o $(TARGET_DST) $(LDFLAGS) $(PLATFORM_LIB) $^ $(CXXFLAGS) $(ARCH_FLAG) $(call expandFlag,$($(NAME)_CXXFLAGS)) $(LOADLIBES) $(ALL_LDLIBS) $(LDLIBS) $($(NAME)_LDLIBS) $(call expand,$($(NAME)_LINK_LIBS)); \
		$(ECHO) "==================================================="; \
		cat $${tmpfile};								\
		exit 1;											\
	else 												\
		$(ECHO) $(GREEN_OK);							\
		$(RM) $${tmpfile};								\
	fi

_stop_static_lib:	$(GCOV_OBJ) $(DEFER_OBJ)
	@if [ -p $(META)/pipe ]; then (exec 3<>$(META)/pipe && printf 'EXIT\n' >&3); fi
	@if [ -p $(META)/pipe ]; then pid=$$(cat $(META)/pid); if [ $$pid != 0 ]; then while kill -0 "$$pid" 2>/dev/null; do sleep 0.1; done; fi; fi
	@failed=0; \
	 for f in $(META)/err.*; do \
	   [ -f "$$f" ] || continue; \
	   cat "$$f" >&2; \
	   failed=1; \
	 done; \
	 rm -rf $(META); \
	 if ( test $$failed != 0 ); then exit 1; fi
	@if ( test "$(VERBOSE)" = "On" ); then				\
		$(ECHO) '$(AR) $(ARFLAGS) $(TARGET_DST) $^';\
	else $(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), "$(AR) $(ARFLAGS) $(TARGET_DST)")	| awk '{printf "%-$(LINE_WIDTH)s", $$0}' ; fi
	@export tmpfile=$(shell $(MKTEMP));					\
	$(AR) $(ARFLAGS) $(TARGET_DST) $^ > $${tmpfile} 2>&1;	\
	ranlib $(TARGET_DST) 2> /dev/null;					\
	if [ $$? != 0 ];									\
	then												\
		$(ECHO) $(RED_ERROR);							\
		$(ECHO) $(AR) $(ARFLAGS) $(TARGET_DST) $^;		\
		$(ECHO) "==================================================="; \
		cat $${tmpfile};								\
		exit 1;											\
	else 												\
		$(ECHO) $(GREEN_OK);							\
		$(RM) $${tmpfile};								\
	fi

_stop_dynamic_lib:	$(GCOV_OBJ) $(DEFER_OBJ)
	@if [ -p $(META)/pipe ]; then (exec 3<>$(META)/pipe && printf 'EXIT\n' >&3); fi
	@if [ -p $(META)/pipe ]; then pid=$$(cat $(META)/pid); if [ $$pid != 0 ]; then while kill -0 "$$pid" 2>/dev/null; do sleep 0.1; done; fi; fi
	@failed=0; \
	 for f in $(META)/err.*; do \
	   [ -f "$$f" ] || continue; \
	   cat "$$f" >&2; \
	   failed=1; \
	 done; \
	 rm -rf $(META); \
	 if ( test $$failed != 0 ); then exit 1; fi
	@if ( test "$(VERBOSE)" = "On" ); then				\
		$(ECHO) '$(CXX) $(SHARED_LIB_FLAG_$(PLATFORM)) -o $(TARGET_DST) $(LDFLAGS) $^ $(CXXFLAGS) $(ARCH_FLAG) $(call expandFlag,$($*_CXXFLAGS)) $(LOADLIBES) $(ALL_LDLIBS) $(LDLIBS) $(THORSANVIL_STATICLOADALL)' ; \
	else $(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), "$(CC) $(SHARED_LIB_FLAG_$(PLATFORM)) -o $(TARGET_DST) $(OPTIMIZER_FLAGS_DISP)  $(call expandFlag,$($*_CXXFLAGS))")	| awk '{printf "%-$(LINE_WIDTH)s", $$0}' ; fi
	@export tmpfile=$(shell $(MKTEMP));					\
	$(LDLIBS_EXTERN_RPATH) $(CXX) $(SHARED_LIB_FLAG_$(PLATFORM)) -o $(TARGET_DST) $(LDFLAGS) $^ $(CXXFLAGS) $(ARCH_FLAG) $(call expandFlag,$($*_CXXFLAGS)) $(LOADLIBES) $(ALL_LDLIBS) $(LDLIBS) $(THORSANVIL_STATICLOADALL) 2> $${tmpfile}; \
	if [ $$? != 0 ];									\
	then												\
		$(ECHO) "";										\
		$(ECHO) $(RED_ERROR);							\
		$(ECHO) "EX_RPATH: $(LDLIBS_EXTERN_RPATH)";		\
		$(ECHO) $(CXX) $(SHARED_LIB_FLAG_$(PLATFORM)) -o $(TARGET_DST) $(LDFLAGS) $^ $(CXXFLAGS) $(ARCH_FLAG) $(call expandFlag,$($*_CXXFLAGS)) $(LOADLIBES) $(ALL_LDLIBS) $(LDLIBS) $(THORSANVIL_STATICLOADALL); \
		$(ECHO) "==================================================="; \
		cat $${tmpfile};								\
		exit 1;											\
	else 												\
		$(ECHO) $(GREEN_OK);							\
		$(RM) $${tmpfile};								\
	fi


_stop_dependency: $(DEP)
	@if [ -p $(META)/pipe ]; then (exec 3<>$(META)/pipe && printf 'EXIT\n' >&3); fi
	@if [ -p $(META)/pipe ]; then pid=$$(cat $(META)/pid); if [ $$pid != 0 ]; then while kill -0 "$$pid" 2>/dev/null; do sleep 0.1; done; fi; fi
	@failed=0; \
	 for f in $(META)/err.*; do \
	   [ -f "$$f" ] || continue; \
	   cat "$$f" >&2; \
	   failed=1; \
	 done; \
	 rm -rf $(META); \
	 if ( test $$failed != 0 ); then exit 1; fi;\

