
.PHONY:	doLint check_lint lintExecute

doLint:	check_lint lintExecute

check_lint:
	@vera++ --help > /dev/null 2>&1;														\
	if test $$? -ne 0; then																	\
		$(ECHO);$(ECHO);$(ECHO);															\
		$(ECHO) "You need to install *vera++ and cppcheck";									\
		$(ECHO) "The configuration does not check for these";								\
		$(ECHO) "as linting is optional";													\
		$(ECHO);$(ECHO);$(ECHO);															\
		exit 1;																				\
	fi
	@cppcheck --help > /dev/null 2>&1;														\
	if test $$? -ne 0; then																	\
		$(ECHO);$(ECHO);$(ECHO);															\
		$(ECHO) "You need to install vera++ and *cppcheck";									\
		$(ECHO) "The configuration does not check for these";								\
		$(ECHO) "as linting is optional";													\
		$(ECHO);$(ECHO);$(ECHO);															\
		exit 1;																				\
	fi
	@$(THORSANVIL_ROOT)/build/lint/vera/init

lintExecute:	$(CPP_SRC) $(APP_SRC) $(HEAD)
	@if test "$?" != ""; then																\
		$(ECHO) "cppcheck $?";																\
		cppcheck $?;																		\
	fi
	@if test "$?" != ""; then																\
		$(ECHO) "vera++ --root $(THORSANVIL_ROOT)/build/lint/vera --profile Thor.vera $?";	\
		vera++ --root $(THORSANVIL_ROOT)/build/lint/vera --profile Thor.vera $?;			\
	fi

