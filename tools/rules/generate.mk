# =============================================================================
# rules/generate.mk — source-code generation pattern rules (yacc / lex / gperf)
#
# Requires: YACC LEX GPERF                                           (core/variables.mk)
#           ECHO MKTEMP RM MODE_TEXT_COLOR colour_text GREEN_OK RED_ERROR
#           VERBOSE LINE_WIDTH
# Defines:  (nothing consumable)
# Goals:    %.tab.cpp  %.lex.cpp  %.gperf.cpp
# =============================================================================

.PRECIOUS:	%.tab.cpp
.PRECIOUS:	%.lex.cpp
.PRECIOUS:	%.gperf.cpp


%.tab.cpp: %.y
	@if ( test "$(VERBOSE)" = "Off" ); then				\
		$(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), "$(YACC) $^") | awk '{printf "%-$(LINE_WIDTH)s", $$0}' ; \
	elif ( test "$(VERBOSE)" = "On" ); then				\
		$(ECHO) '$(YACC) -o $@ -d $<' ;					\
	fi
	@export tmpfile=$(shell $(MKTEMP));					\
	export errorFile=$(shell $(MKTEMP));				\
	$(YACC) -o $@ -d $< 2>$${errorFile};			    \
	if [ $$? != 0 ];									\
	then												\
		$(ECHO) "Failed in Parser Generator";			\
		$(ECHO) $(RED_ERROR);							\
		$(ECHO) $(YACC) -o $@ -d $<;					\
		$(ECHO) "========================================";\
		cat $${errorFile};								\
		exit 1;											\
	else 												\
		mv $@ $${tmpfile};								\
		sed -e 's/semantic_type yylval;/semantic_type yylval{};/'	\
			$${tmpfile} > $@;							\
		if ( test "$(VERBOSE)" = "NONE" ); then			\
			$(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), "$(YACC) $^") | awk '{printf "%-$(LINE_WIDTH)s", $$0}' ; \
		fi;												\
		$(ECHO) $(GREEN_OK);							\
		$(RM) $${errorFile} $${tmpfile};				\
	fi

%.lex.cpp: %.l
	@if ( test "$(VERBOSE)" = "Off" ); then				\
		$(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), "$(LEX) -P $* $^") | awk '{printf "%-$(LINE_WIDTH)s", $$0}' ; \
	elif ( test "$(VERBOSE)" = "On" ); then				\
		$(ECHO) '$(LEX) -P $* -t $< > $@' ;					\
	fi
	@export tmpfile=$(shell $(MKTEMP));					\
	export errorFile=$(shell $(MKTEMP));				\
	$(LEX) -P $* -t --c++ --header-file=$*.lex.h $< > $${tmpfile} 2> $${errorFile};	\
	if [ $$? != 0 ];									\
	then												\
		$(ECHO) "Failed in Lexer Generator";			\
		$(ECHO) $(RED_ERROR);							\
		$(ECHO) $(LEX) -P $* -t $< > $@;				\
		$(ECHO) "========================================";\
		cat $${errorFile};								\
		exit 1;											\
	else 												\
		cat $${tmpfile} |								\
			sed -e 's/<stdout>/$*.lex.cpp/'				\
				-e 's/extern "C" int isatty/\/\/ Removed extern "C" int isatty/' -e 's/max_size )) < 0 )/max_size )) == std::size_t(-1) )/'	\
				-e 's/(int)(result = LexerInput/(std::size_t)(result = LexerInput/'	\
				-e 's/int yy_buf_size;/std::size_t yy_buf_size;/'	\
				> $@;									\
		if ( test "$(VERBOSE)" = "NONE" ); then			\
			$(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), "$(LEX) -P $* $^") | awk '{printf "%-$(LINE_WIDTH)s", $$0}' ; \
		fi;												\
		$(ECHO) $(GREEN_OK);							\
		$(RM) $${errorFile} $${tmpFile};				\
	fi

%.gperf.cpp: %.gperf
	@if ( test "$(VERBOSE)" = "Off" ); then				\
		$(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), "$(GPERF) --class-name=$*_Hash $^") | awk '{printf "%-$(LINE_WIDTH)s", $$0}' ; \
	elif ( test "$(VERBOSE)" = "On" ); then				\
		$(ECHO) '$(GPERF) -l -L C++ --class-name=$*_Hash $^ > $@'	;	\
	fi
	@export tmpfile=$(shell $(MKTEMP));					\
	$(GPERF) -l -L C++ --class-name=$*_Hash $^ > $@ 2>$${tmpfile}; \
	if [ $$? != 0 ];									\
	then												\
		$(ECHO) "Failed in Lexer Generator";			\
		$(ECHO) $(RED_ERROR);							\
		$(ECHO) "$(GPERF) -l -L C++ --class-name=$@_Hash $^ > $@"; \
		$(ECHO) "========================================";\
		cat $@;											\
		exit 1;											\
	else 												\
		if ( test "$(VERBOSE)" = "NONE" ); then			\
			$(ECHO) $(call colour_text, $(MODE_TEXT_COLOR), "$(GPERF) --class-name=$*_Hash $^") | awk '{printf "%-$(LINE_WIDTH)s", $$0}' ; \
		fi;												\
		$(ECHO) $(GREEN_OK);							\
	fi
