
.PHONY:	ActionInstall ActionUInstall
.PHONY: clean veryclean
.PHONY:	ActionDoInstallDebug  ActionDoInstallRelease  ActionDoInstallHead  ActionDoInstallMan
.PHONY:	ActionDoUInstallDebug ActionDoUInstallRelease ActionDoUInstallHead ActionDoUInstallMan
.PHONY:	ActionTryInstallApp  ActionTryInstallSlib  ActionTryInstallAlib  ActionTryInstallHead  ActionTryInstallDefer  ActionTryInstallMan
.PHONY:	ActionTryUInstallApp ActionTryUInstallSlib ActionTryUInstallAlib ActionTryUInstallHead ActionTryUInstallDefer ActionTryUInstallMan   ActionTryUInstallDRoot
.PHONY:	ActionInstallApp  ActionInstallSlib  ActionInstallAlib  ActionInstallAHead  ActionInstallDefer  ActionInstallMan
.PHONY:	ActionUInstallApp ActionUInstallSlib ActionUInstallAlib ActionUInstallAHead ActionUInstallDefer ActionUInstallMan ActionUInstallDRoot
.PHONY:	install_app_% install_shared_lib_% install_defer_NO_% install_lib_defer_YES_% install_lib_defer_NO_% install_head_% clean_app_% clean_shared_lib_% clean_static_lib_% clean_head_% clean_defer_YES_% clean_defer_NO_% clean_lib_defer_YES_% clean_lib_defer_NO_% root_clean_defer_YES_% root_clean_defer_NO_% install_defer_NO_%


# This is the interface to this makefile.
# Use either ActionInstall or ActionUInstall
#
ActionInstall:	ActionDoInstallHead  ActionDoInstallDebug  ActionDoInstallRelease  ActionDoInstallMan
ActionUInstall:	ActionDoUInstallHead ActionDoUInstallDebug ActionDoUInstallRelease ActionDoUInstallMan


ActionDoInstallDebug:
	#$(MAKE) $(PARALLEL) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=debug INSTALL_ACTIVE=$(INSTALL_ACTIVE) all
	$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=debug INSTALL_ACTIVE=$(INSTALL_ACTIVE) ActionTryInstallApp  ActionTryInstallSlib ActionTryInstallAlib ActionTryInstallDefer
ActionDoInstallRelease:
	#$(MAKE) $(PARALLEL) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=release INSTALL_ACTIVE=$(INSTALL_ACTIVE) all
	$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=release INSTALL_ACTIVE=$(INSTALL_ACTIVE) ActionTryInstallApp  ActionTryInstallSlib ActionTryInstallAlib ActionTryInstallDefer
ActionDoInstallHead:
	$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=profile INSTALL_ACTIVE=$(INSTALL_ACTIVE) ActionTryInstallHead
ActionDoInstallMan:
	$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=profile INSTALL_ACTIVE=$(INSTALL_ACTIVE) ActionTryInstallMan

ActionDoUInstallDebug:
	$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=debug INSTALL_ACTIVE=$(INSTALL_ACTIVE) ActionTryUInstallApp ActionTryUInstallSlib ActionTryUInstallAlib ActionTryUInstallDefer
ActionDoUInstallRelease:
	$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=release INSTALL_ACTIVE=$(INSTALL_ACTIVE) ActionTryUInstallApp ActionTryUInstallSlib ActionTryUInstallAlib ActionTryUInstallDefer
ActionDoUInstallHead:
	$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=profile INSTALL_ACTIVE=$(INSTALL_ACTIVE) ActionTryUInstallHead ActionTryUInstallDRoot
ActionDoUInstallMan:
	$(MAKE) BASE=$(BASE) VERBOSE=$(VERBOSE) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER) TARGET_MODE=profile INSTALL_ACTIVE=$(INSTALL_ACTIVE) ActionTryUInstallMan

ActionTryInstallApp :		$(if $(INSTALL_APP), ActionInstallApp)
ActionTryInstallSlib:	$(if $(INSTALL_SHARED_LIB), ActionInstallSlib)
ActionTryInstallAlib:	$(if $(INSTALL_STATIC_LIB), ActionInstallAlib)
ActionTryInstallHead:		$(if $(INSTALL_HEADER), ActionInstallAHead)
ActionTryInstallMan:		$(if $(INSTALL_MAN), ActionInstallMan)
ActionTryInstallDefer:		$(if $(INSTALL_DEFER), ActionInstallDefer)

ActionTryUInstallApp:			$(if $(INSTALL_APP), ActionUInstallApp)
ActionTryUInstallSlib:	$(if $(INSTALL_SHARED_LIB), ActionUInstallSlib)
ActionTryUInstallAlib:	$(if $(INSTALL_STATIC_LIB), ActionUInstallAlib)
ActionTryUInstallHead:			$(if $(INSTALL_HEADER), ActionUInstallAHead)
ActionTryUInstallMan:			$(if $(INSTALL_MAN), ActionUInstallMan)
ActionTryUInstallDefer:		$(if $(INSTALL_DEFER), ActionUInstallDefer)
ActionTryUInstallDRoot:	$(if $(INSTALL_DEFER), ActionUInstallDRoot)

ActionInstallApp:			Note_Start_Installing_Applications $(INSTALL_APP)           Note_End_Installing_Applications
ActionInstallSlib:		Note_Start_Installing_Libraries    $(INSTALL_SHARED_LIB)    Note_End_Installing_Libraries
ActionInstallAlib:		Note_Start_Installing_Libraries    $(INSTALL_STATIC_LIB)    Note_End_Installing_Libraries
ActionInstallAHead:			Note_Start_Installing_Headers      $(INSTALL_HEADER)        Note_End_Installing_Headers
ActionInstallMan:			Note_Start_Installing_Man          $(INSTALL_MAN)           Note_End_Installing_Man
ActionInstallDefer:			Note_Start_Installing_DeferLib     $(INSTALL_DEFER)         Note_End_Installing_DeferLib
ActionUInstallApp:				Note_Start_Clean_Applications      $(patsubst install_%, clean_%, $(INSTALL_APP))               Note_End_Clean_Applications
ActionUInstallSlib:		Note_Start_Clean_Libraries         $(patsubst install_%, clean_%, $(INSTALL_SHARED_LIB))        Note_End_Clean_Libraries
ActionUInstallAlib:		Note_Start_Clean_Libraries         $(patsubst install_%, clean_%, $(INSTALL_STATIC_LIB))        Note_End_Clean_Libraries
ActionUInstallAHead:				Note_Start_Clean_Headers           $(patsubst install_%, clean_%, $(INSTALL_HEADER))            Note_End_Clean_Headers
ActionUInstallMan:				Note_Start_Clean_Man               $(patsubst install_%, clean_%, $(INSTALL_MAN))               Note_End_Clean_Man
ActionUInstallDefer:			Note_Start_Clean_Defer             $(patsubst install_%, clean_%, $(INSTALL_DEFER))             Note_End_Clean_Defer
ActionUInstallDRoot:		Note_Start_Clean_Defer_Root        $(patsubst install_%, root_clean_%, $(INSTALL_DEFER_OBJ))    Note_End_Clean_Defer_Root


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


