
.PHONY:	doLint check_lint lintExecute

doLint:	check_lint lintExecute

check_lint:
	@vera++ --help > /dev/null 2>&1;														\
	if test $$? -ne 0; then																	\
		echo;echo;echo;																		\
		echo "You need to install *vera++ and cppcheck";									\
		echo "The configuration does not check for these";									\
		echo "as linting is optional";														\
		echo;echo;echo;																		\
		exit 1;																				\
	fi
	@cppcheck --help > /dev/null 2>&1;														\
	if test $$? -ne 0; then																	\
		echo;echo;echo;																		\
		echo "You need to install vera++ and *cppcheck";									\
		echo "The configuration does not check for these";									\
		echo "as linting is optional";														\
		echo;echo;echo;																		\
		exit 1;																				\
	fi
	@$(THORSANVIL_ROOT)/build/lint/vera/init

lintExecute:	$(CPP_SRC) $(APP_SRC) $(HEAD)
	@if test "$?" != ""; then																\
		echo "cppcheck $?";																	\
		cppcheck $?;																		\
	fi
	@if test "$?" != ""; then																\
		echo "vera++ --root $(THORSANVIL_ROOT)/build/lint/vera --profile Thor.vera $?";		\
		vera++ --root $(THORSANVIL_ROOT)/build/lint/vera --profile Thor.vera $?;			\
	fi

