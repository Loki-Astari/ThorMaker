
# External
.PHONY:	ActionRunVera vera-%
# Internal

VERA_OBJ					= $(patsubst %,coverage/%.vera, $(VERA_SRC))


ActionRunVera:		report/vera	 report/vera.show
	@rm -f report/vera.show

VERA_PROFILE	= $(if $(VERA_PROFILE_$(1)),$(VERA_PROFILE_$(1)),thor)

vera-%:
	@$(VERA) $(VERA_ROOT) --profile $(call VERA_PROFILE,$*) --show-rule --error --std-report - $*

report/vera:  $(SRC) $(HEAD) | report.Dir
	@$(ECHO) $(call section_title,Static Analysis) | tee report/vera
	@if [[ "$(VERA)" != "off" ]]; then $(MAKE) TARGET_MODE=coverage $(VERA_OBJ); fi
	@echo -n | cat - $$(ls coverage/*.vera 2> /dev/null) >> report/vera
	@touch report/vera.show

report/vera.show:
	@cat report/vera

coverage/%.vera: %	| coverage.Dir
	@if ( test "$(VERBOSE)" = "On" ); then				\
		$(ECHO) "$(VERA) --show-rule --error --std-report $@.report $*" | tee coverage/$*.vera; \
	else												\
		$(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), $(VERA) $*)	| awk '{printf "%-80s", $$0}' | tee -a coverage/$*.vera;	\
	fi
	@$(VERA) $(VERA_ROOT) --profile $(call VERA_PROFILE,$*) --show-rule --error --std-report $@.report $*;\
	if [ $$? != 0 ]; then								\
		$(ECHO) $(RED_ERROR) | tee -a coverage/$*.vera;	\
		$(ECHO) "$(VERA) $(VERA_ROOT) --profile $(call VERA_PROFILE,$*) --show-rule --error --std-report $@.report $*";	\
		$(ECHO) "==================================================="; \
		cat $@.report;									\
		exit 1;											\
	else 												\
		$(ECHO) $(GREEN_OK) | tee -a coverage/$*.vera;	\
		$(RM) $@.report;								\
	fi

