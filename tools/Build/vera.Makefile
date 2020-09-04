
# External
.PHONY:	ActionRunVera vera-%
# Internal

VERA_OBJ					= $(patsubst %,coverage/%.vera, $(VERA_SRC))


ActionRunVera:		report/vera	 report/vera.show
	@rm -f report/vera.show

vera-%:
	@PATH="${PATH}:$(PREFIX_BIN)" $(VERA) --profile thor --show-rule --error --std-report - $*

report/vera:  $(SRC) $(HEAD)
	@$(MKDIR) -p report
	@$(ECHO) $(call section_title,Static Analysis) | tee report/vera
	@if [[ "$(VERA)" != "off" ]]; then $(MAKE) TARGET_MODE=coverage $(VERA_OBJ); fi
	@echo -n | cat - $$(ls coverage/*.vera 2> /dev/null) >> report/vera
	@touch report/vera.show

report/vera.show:
	@cat report/vera

coverage/%.vera: %
	@if ( test "$(VERBOSE)" = "On" ); then				\
		$(ECHO) "$(VERA) --show-rule --error --std-report $@.report $*" | tee coverage/$*.vera; \
	else												\
		$(ECHO) $(call colour_text, GRAY, $(VERA) $*)	| awk '{printf "%-80s", $$0}' | tee -a coverage/$*.vera;	\
	fi
	@PATH="${PATH}:$(PREFIX_BIN)" $(VERA) --profile thor --show-rule --error --std-report $@.report $*;\
	if [ $$? != 0 ]; then								\
		$(ECHO) $(RED_ERROR) | tee -a coverage/$*.vera;	\
		$(ECHO) "$(VERA) --profile thor --show-rule --error --std-report $@.report $*";	\
		$(ECHO) "==================================================="; \
		cat $@.report;									\
		exit 1;											\
	else 												\
		$(ECHO) $(GREEN_OK) | tee -a coverage/$*.vera;	\
		$(RM) $@.report;								\
	fi

