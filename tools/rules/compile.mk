# =============================================================================
# rules/compile.mk — per-source compile and dependency rules
#
# Requires: CXX CPPFLAGS CXXFLAGS ARCH_FLAG MOCK_HEADERS             (core/variables.mk)
#           ECHO MKTEMP RM MODE_TEXT_COLOR colour_text                (core/platform.mk / colour.mk)
#           GREEN_OK RED_ERROR VERBOSE OPTIMIZER_FLAGS_DISP LINE_WIDTH
#           META BUILD_PIPE_OUT                                       (rules/parallel.mk)
#           TARGET_MODE BASE FILEDIR                                  (core/variables.mk)
# Defines:  (nothing consumable)
# Goals:    $(TARGET_MODE)/%.o  makedependency/%.d
#           $(BASE)/coverage/MockHeaders.o
#           (legacy, disabled) XXmakedependency/%.d  $(XTARGET_MODE)/%.o
# =============================================================================

.SECONDARY: makedependency/%.d

.PRECIOUS:	$(OBJ)
.PRECIOUS:	$(GCOV_OBJ)
.PRECIOUS:	%.cpp.gcov
.PRECIOUS:	%.tpp.gcov


XXmakedependency/%.d: %.cpp | makedependency.Dir
	@if ( test "$(VERBOSE)" = "On" ); then				\
		$(ECHO) '$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(ARCH_FLAG) $(call expandFlag,$($*_CXXFLAGS))  -MF"$@" -MM -MP -MT"debug/$(<:.cpp=.o)" -MT"release/$(<:.cpp=.o)" -MT"coverage/$(<:.cpp=.o)" "$<"'; \
	fi
	$(ECHO) "WORKING: DEP $*"
	@export tmpfile=$(shell $(MKTEMP));					\
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(ARCH_FLAG) $(call expandFlag,$($*_CXXFLAGS))  -MF"$@" -MM -MP -MT"debug/$(<:.cpp=.o)" -MT"release/$(<:.cpp=.o)" -MT"coverage/$(<:.cpp=.o)" "$<" 2> $${tmpfile}; \
	if [ $$? != 0 ];									\
	then												\
		$(ECHO) $(RED_ERROR);							\
		$(ECHO) '$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(ARCH_FLAG) $(call expandFlag,$($*_CXXFLAGS))  -MF"$@" -MM -MP -MT"debug/$(<:.cpp=.o)" -MT"release/$(<:.cpp=.o)" -MT"coverage/$(<:.cpp=.o)" "$<"'; \
		$(ECHO) "========================================";\
		cat $${tmpfile} | awk '/error:/ {if (index($$1, "/") != 1){printf("$(FILEDIR)");}} /note:/ {if (index($$1, "/") != 1){printf("$(FILEDIR)");}} /warning:/ {if (index($$1, "/") != 1){printf("$(FILEDIR)");}} {print}';	\
		exit 1;											\
	fi

$(BASE)/coverage/MockHeaders.o: $(BASE)/coverage/MockHeaders.cpp
	@if ( test "$(VERBOSE)" = "Off" ); then				\
		$(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), "$(CXX) -c $< $(OPTIMIZER_FLAGS_DISP)  $(call expandFlag,$($*_CXXFLAGS))") | awk '{printf "%-$(LINE_WIDTH)s", $$0}' ; \
	elif ( test "$(VERBOSE)" = "On" ); then				\
		$(ECHO) '$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(MOCK_HEADERS) $(call expandFlag,$($*_CXXFLAGS))' ;		\
	fi
	@export tmpfile=$(shell $(MKTEMP));					\
	$(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), "$(CXX) -c $(OPTIMIZER_FLAGS_DISP)  $(call expandFlag,$($*_CXXFLAGS))") $< | awk '{printf "%-$(LINE_WIDTH)s", $$0}' ; \
	$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(MOCK_HEADERS) $(call expandFlag,$($*_CXXFLAGS)) 2>$${tmpfile};	\
	if [ $$? != 0 ];									\
	then												\
		$(ECHO) $(RED_ERROR);							\
		$(ECHO) $(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(MOCK_HEADERS) $(call expandFlag,$($*_CXXFLAGS));\
		$(ECHO) "========================================";\
		cat $${tmpfile} | awk '/error:/ {if (index($$1, "/") != 1){printf("$(FILEDIR)");}} /note:/ {if (index($$1, "/") != 1){printf("$(FILEDIR)");}} /warning:/ {if (index($$1, "/") != 1){printf("$(FILEDIR)");}} {print}';	\
		exit 1;											\
	else 												\
		$(ECHO) $(GREEN_OK);							\
		$(RM) $${tmpfile};								\
	fi

$(TARGET_MODE)/%.o: %.cpp
	@{ \
		if ( test "$(VERBOSE)" = "On" ); then						\
			cmd='$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(MOCK_HEADERS) $(ARCH_FLAG) $(call expandFlag,$($*_CXXFLAGS))';			\
		else														\
			cmd='$(CXX) -c $< $(OPTIMIZER_FLAGS_DISP)  $(call expandFlag,$($*_CXXFLAGS))';	\
		fi;															\
		$(call BUILD_PIPE_OUT,START,$*,"$${cmd}",building);			\
		export tmpfile=$(shell $(MKTEMP));							\
		$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(MOCK_HEADERS) $(ARCH_FLAG) $(call expandFlag,$($*_CXXFLAGS)) 2>$${tmpfile};	\
		if [ $$? != 0 ]; then 										\
			$(call BUILD_PIPE_OUT,DONE,$*,"$${cmd}",$(RED_ERROR));	\
			$(ECHO) '$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(MOCK_HEADERS) $(ARCH_FLAG) $(call expandFlag,$($*_CXXFLAGS))' > '$(META)/err.$*';	\
			cat "$${tmpfile}" >> '$(META)/err.$*';					\
			rm -f $@;												\
		else														\
			$(call BUILD_PIPE_OUT,DONE,$*,"$${cmd}",$(GREEN_OK));	\
		fi; 														\
		$(RM) "$${tmpfile}";										\
	}

makedependency/unittest.d: ;
makedependency/%.d: %.cpp
	@{ \
		if ( test "$(VERBOSE)" = "On" ); then						\
			cmd='$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(ARCH_FLAG) $(call expandFlag,$($*_CXXFLAGS))  -MF"$@" -MM -MP -MT"debug/$(<:.cpp=.o)" -MT"release/$(<:.cpp=.o)" -MT"coverage/$(<:.cpp=.o)" "$<"'; \
		else														\
			cmd='$(CXX) $< -MF$@ -MM -MP';							\
		fi;															\
		$(call BUILD_PIPE_OUT,START,$*,"$${cmd}",'building dep');	\
		export tmpfile=$(shell $(MKTEMP));							\
		$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(ARCH_FLAG) $(call expandFlag,$($*_CXXFLAGS))  -MF"$@" -MM -MP -MT"debug/$(<:.cpp=.o)" -MT"release/$(<:.cpp=.o)" -MT"coverage/$(<:.cpp=.o)" "$<" 2> $${tmpfile}; \
		if [ $$? != 0 ];											\
		then														\
			$(call BUILD_PIPE_OUT,DONE,$*,"$${cmd}",${RED_ERROR});	\
			$(ECHO) '$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(ARCH_FLAG) $(call expandFlag,$($*_CXXFLAGS))  -MF"$@" -MM -MP -MT"debug/$(<:.cpp=.o)" -MT"release/$(<:.cpp=.o)" -MT"coverage/$(<:.cpp=.o)" "$<"' > '$(META)/err.$*'; \
			cat $${tmpfile} | awk '/error:/ {if (index($$1, "/") != 1){printf("$(FILEDIR)");}} /note:/ {if (index($$1, "/") != 1){printf("$(FILEDIR)");}} /warning:/ {if (index($$1, "/") != 1){printf("$(FILEDIR)");}} {print}' >> '$(META)/err.$*';	\
			rm -f $@;												\
		else														\
			$(call BUILD_PIPE_OUT,DONE,$*,"$${cmd}",${GREEN_OK});	\
		fi;															\
		$(RM) $${tmpfile};											\
	}

$(XTARGET_MODE)/%.o: %.cpp | $(TARGET_MODE).Dir
	@if ( test "$(VERBOSE)" = "Off" ); then				\
		$(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), "$(CXX) -c $< $(OPTIMIZER_FLAGS_DISP)  $(call expandFlag,$($*_CXXFLAGS))") | awk '{printf "%-$(LINE_WIDTH)s", $$0}' ; \
	elif ( test "$(VERBOSE)" = "On" ); then				\
		$(ECHO) '$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(MOCK_HEADERS) $(ARCH_FLAG) $(call expandFlag,$($*_CXXFLAGS))' ;		\
	fi
	@export tmpfile=$(shell $(MKTEMP));					\
	$(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), "$(CXX) -c $(OPTIMIZER_FLAGS_DISP)  $(call expandFlag,$($*_CXXFLAGS))") $< | awk '{printf "%-$(LINE_WIDTH)s", $$0}' ; \
	$(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(MOCK_HEADERS) $(ARCH_FLAG) $(call expandFlag,$($*_CXXFLAGS)) 2>$${tmpfile};	\
	if [ $$? != 0 ];									\
	then												\
		$(ECHO) $(RED_ERROR);							\
		$(ECHO) $(CXX) -c $< -o $@ $(CPPFLAGS) $(CXXFLAGS) $(MOCK_HEADERS) $(ARCH_FLAG) $(call expandFlag,$($*_CXXFLAGS));\
		$(ECHO) "========================================";\
		cat $${tmpfile} | awk '/error:/ {if (index($$1, "/") != 1){printf("$(FILEDIR)");}} /note:/ {if (index($$1, "/") != 1){printf("$(FILEDIR)");}} /warning:/ {if (index($$1, "/") != 1){printf("$(FILEDIR)");}} {print}';	\
		exit 1;											\
	else 												\
		$(ECHO) $(GREEN_OK);							\
		$(RM) $${tmpfile};								\
	fi
