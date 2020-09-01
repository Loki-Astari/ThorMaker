
.PHONY:	installAction cleanAction install_debug install_release install_profile header_only
.PHONY: clean veryclean
.PHONY:	install_Dodebug install_Dorelease install_Dohead install_man
.PHONY:	clean_Dodebug   clean_Dorelease   clean_Dohead   clean_man
.PHONY:	try_install_app try_install_shared_lib try_install_static_lib try_install_head try_install_defer try_clean_app try_clean_shared_lib try_clean_static_lib try_clean_head try_clean_defer try_clean_defer_root
.PHONY:	install_app install_shared_lib install_static_lib install_head install_defer clean_app clean_shared_lib clean_static_lib clean_head clean_defer clean_defer_root
.PHONY:	install_app_% install_shared_lib_% install_defer_NO_% install_lib_defer_YES_% install_lib_defer_NO_% install_head_% clean_app_% clean_shared_lib_% clean_static_lib_% clean_head_% clean_defer_YES_% clean_defer_NO_% clean_lib_defer_YES_% clean_lib_defer_NO_% root_clean_defer_YES_% root_clean_defer_NO_% install_defer_NO_%


# 1
installAction:	install_Dohead install_Dodebug install_Dorelease install_Doman
# 1
cleanAction:	clean_Dohead   clean_Dodebug   clean_Dorelease   clean_Doman

install_debug:		test install_Dohead install_Dodebug
install_release:	test install_Dohead install_Dorelease
install_profile:	install_Dohead install_Doprofile
header_only:		test install_Dohead

clean:
	$(RM) $(GCOV_OBJ) $(GCOV_SRC) $(GCOV_HEAD) $(TMP_SRC) $(TMP_HDR) makefile_tmp
	$(RM) $(patsubst %.y,%.tab.cpp,$(YACC_SRC)) $(patsubst %.y,%.tab.hpp,$(YACC_SRC)) $(patsubst %.l,%.lex.cpp,$(LEX_SRC)) $(patsubst %.gperf,%.gperf.cpp,$(GPERF_SRC)) $(CLEAN_EXTRA)
	$(RM) $(TARGET_ALL) $(patsubst %.app,%,$(filter %.app,$(TARGET_ALL))) $(patsubst %,$(TARGET_MODE)/%,$(filter %.app,$(TARGET_ALL)))
	$(RM) $(LIBBASENAME_ACTUAL)TestMarker.cpp
	$(RM) -rf debug release coverage profile test/coverage $(TMP_SRC) $(TMP_HDR)
	$(RM) -rf *.gcov test/*.gcov


install_Dodebug:
	$(MAKE) $(PARALLEL) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=debug INSTALL_ACTIVE=$(INSTALL_ACTIVE) all
	$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=debug INSTALL_ACTIVE=$(INSTALL_ACTIVE) try_install_app try_install_shared_lib try_install_static_lib try_install_defer
install_Dorelease:
	$(MAKE) $(PARALLEL) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=release INSTALL_ACTIVE=$(INSTALL_ACTIVE) all
	$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=release INSTALL_ACTIVE=$(INSTALL_ACTIVE) try_install_app try_install_shared_lib try_install_static_lib try_install_defer
install_Dohead:
	$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=profile INSTALL_ACTIVE=$(INSTALL_ACTIVE) try_install_head
install_Doman:
	$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=profile INSTALL_ACTIVE=$(INSTALL_ACTIVE) try_install_man

clean_Dodebug:
	$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=debug INSTALL_ACTIVE=$(INSTALL_ACTIVE) try_clean_app try_clean_shared_lib try_clean_static_lib try_clean_defer
clean_Dorelease:
	$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=release INSTALL_ACTIVE=$(INSTALL_ACTIVE) try_clean_app try_clean_shared_lib try_clean_static_lib try_clean_defer
clean_Dohead:
	$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=profile INSTALL_ACTIVE=$(INSTALL_ACTIVE) try_clean_head
clean_Doman:
	$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=profile INSTALL_ACTIVE=$(INSTALL_ACTIVE) try_clean_man

try_install_app:		$(if $(INSTALL_APP), install_app)
try_install_shared_lib:	$(if $(INSTALL_SHARED_LIB), install_shared_lib)
try_install_static_lib:	$(if $(INSTALL_STATIC_LIB), install_static_lib)
try_install_head:		$(if $(INSTALL_HEADER), install_head)
try_install_man:		$(if $(INSTALL_MAN), install_man)
try_install_defer:		$(if $(INSTALL_DEFER), install_defer)

try_clean_app:			$(if $(INSTALL_APP), clean_app)
try_clean_shared_lib:	$(if $(INSTALL_SHARED_LIB), clean_shared_lib)
try_clean_static_lib:	$(if $(INSTALL_STATIC_LIB), clean_static_lib)
try_clean_head:			$(if $(INSTALL_HEADER), clean_head)
try_clean_man:			$(if $(INSTALL_MAN), clean_man)
try_clean_defer:		$(if $(INSTALL_DEFER), clean_defer)
try_clean_defer_root:	$(if $(INSTALL_DEFER), clean_defer_root)

install_app:			Note_Start_Installing_Applications $(INSTALL_APP)           Note_End_Installing_Applications
install_shared_lib:		Note_Start_Installing_Libraries    $(INSTALL_SHARED_LIB)    Note_End_Installing_Libraries
install_static_lib:		Note_Start_Installing_Libraries    $(INSTALL_STATIC_LIB)    Note_End_Installing_Libraries
install_head:			Note_Start_Installing_Headers      $(INSTALL_HEADER)        Note_End_Installing_Headers
install_man:			Note_Start_Installing_Man          $(INSTALL_MAN)           Note_End_Installing_Man
install_defer:			Note_Start_Installing_DeferLib     $(INSTALL_DEFER)         Note_End_Installing_DeferLib
clean_app:				Note_Start_Clean_Applications      $(patsubst install_%, clean_%, $(INSTALL_APP))               Note_End_Clean_Applications
clean_shared_lib:		Note_Start_Clean_Libraries         $(patsubst install_%, clean_%, $(INSTALL_SHARED_LIB))        Note_End_Clean_Libraries
clean_static_lib:		Note_Start_Clean_Libraries         $(patsubst install_%, clean_%, $(INSTALL_STATIC_LIB))        Note_End_Clean_Libraries
clean_head:				Note_Start_Clean_Headers           $(patsubst install_%, clean_%, $(INSTALL_HEADER))            Note_End_Clean_Headers
clean_man:				Note_Start_Clean_Man               $(patsubst install_%, clean_%, $(INSTALL_MAN))               Note_End_Clean_Man
clean_defer:			Note_Start_Clean_Defer             $(patsubst install_%, clean_%, $(INSTALL_DEFER))             Note_End_Clean_Defer
clean_defer_root:		Note_Start_Clean_Defer_Root        $(patsubst install_%, root_clean_%, $(INSTALL_DEFER_OBJ))    Note_End_Clean_Defer_Root


install_app_%:
	@$(MKDIR) -p $(PREFIX_BIN)
	@$(CP) $(TARGET_MODE)/$*.app $(PREFIX_BIN)/$*$(BUILD_EXTENSION)
	@$(ECHO) $(call subsection_title, Install - $(TARGET_MODE) - $*$(BUILD_EXTENSION))

install_shared_lib_%:
	@$(MKDIR) -p $(PREFIX_LIB)
	@$(CP) $(TARGET_MODE)/lib$*.$(SO) $(PREFIX_LIB)/lib$*$(BUILD_EXTENSION).$(SO)
	@$(ECHO) $(call subsection_title, Install - $(TARGET_MODE) - lib$*$(BUILD_EXTENSION).$(SO))

install_static_lib_%:
	@$(MKDIR) -p $(PREFIX_LIB)
	@$(CP) $(TARGET_MODE)/lib$*.a $(PREFIX_LIB)/lib$*$(BUILD_EXTENSION).a
	@$(ECHO) $(call subsection_title, Install - $(TARGET_MODE) - lib$*$(BUILD_EXTENSION).a)

install_head_%:
	@$(MKDIR) -p $(PREFIX_INC)/$*
	for head in $(HEAD); do $(CP) $${head} $(PREFIX_INC)/$*/;done
	@$(ECHO) $(call subsection_title, Install Header $*)

install_defer_YES_%:
	# Do nothng
#
# Deferred objects are not installed into the main system.
# They are only installed when INSTALL_ACTIVE is not set and thus built into the build directory
# When the deferred library is then build it will use these object to build the appropriate
# library object.

install_defer_NO_%:
	$(MKDIR) -p $(PREFIX_OBJ)/$*/$(TARGET_MODE)
	for obj in $(OBJ); do base=$$(basename $${obj});$(CP) $${obj} $(PREFIX_OBJ)/$*/$(TARGET_MODE)/$${base}; done
	$(ECHO) $(call subsection_title, Install Defer $*)

install_lib_defer_YES_%:
	# Do nothing

install_lib_defer_NO_%:
	$(CP) $(TARGET_MODE)/lib$*$(BUILD_EXTENSION).a $(PREFIX_LIB)/

clean_app_%:
	@$(ECHO) $(call subsection_title, Clean - $(TARGET_MODE) - $*$(BUILD_EXTENSION))
	@$(RM) $(PREFIX_BIN)/$*$(BUILD_EXTENSION)

clean_shared_lib_%:
	@$(ECHO) $(call subsection_title, Clean - $(TARGET_MODE) - lib$*$(BUILD_EXTENSION).$(SO))
	@$(RM) $(PREFIX_LIB)/lib$*$(BUILD_EXTENSION).$(SO)

clean_static_lib_%:
	@$(ECHO) $(call subsection_title, Clean - $(TARGET_MODE) - lib$*$(BUILD_EXTENSION).a)
	@$(RM) $(PREFIX_LIB)/lib$*$(BUILD_EXTENSION).a

clean_head_%:
	@$(ECHO) $(call subsection_title, Clean Header $*)
	@for head in $(HEAD); do $(RM) -f $(PREFIX_INC)/$*/$${head};done
	@if [[ -e $(PREFIX_INC)/$*/ ]]; then $(RMDIR) $(PREFIX_INC)/$*/; fi

clean_defer_YES_%:
	@# nothing to do

clean_defer_NO_%:
	@$(ECHO) $(call subsection_title, Clean Defer $(TARGET_MODE) $*)
	@for obj in $(OBJ); do base=$$(basename $${obj});$(RM) -f $(PREFIX_OBJ)/$*/$(TARGET_MODE)/$${base}; done
	@if [[ -e $(PREFIX_OBJ)/$*/$(TARGET_MODE) ]]; then $(RMDIR) $(PREFIX_OBJ)/$*/$(TARGET_MODE); fi

clean_lib_defer_YES_%:
	@# nothing to do

clean_lib_defer_NO_%:
	@$(RM) $(PREFIX_LIB)/lib$*$(BUILD_EXTENSION).a

root_clean_defer_YES_%:
	@# nothing to do

root_clean_defer_NO_%:
	@$(ECHO) $(call subsection_title, Clean Defer $* ROOT)
	@if [[ -e $(PREFIX_OBJ)/$*/ ]]; then $(RMDIR) $(PREFIX_OBJ)/$*/; fi


