# =============================================================================
# targets/devinstall.mk — development install using symbolic links
#
# Like install.mk, but creates symbolic links from the system install
# directories back to the build tree instead of copying files.
# Libraries and binaries are linked as individual files; header directories
# are linked as a single directory symlink.
#
# Requires: TARGET_ALL NO_HEADER INSTALL_ACTIVE DEFER_NAME           (core/variables.mk)
#           PREFIX_BIN PREFIX_LIB PREFIX_INC BUILD_ROOT
#           BUILD_EXTENSION BUILD_SUFFIX SO HEAD
#           paragraph LNSOFT RM ECHO TARGET_MODE
# Defines:  DEVINSTALL_SRC_BIN DEVINSTALL_SRC_LIB DEVINSTALL_SRC_INC
#           DEVINSTALL_* (many)
# Goals:    ActionDevInstall ActionDevUInstall and their supporting machinery.
# =============================================================================

##### External
.PHONY:	ActionDevInstall ActionDevUInstall
##### Internal
.PHONY:	ActionDoDevInstallDebug  ActionDoDevInstallRelease  ActionDoDevInstallHead
.PHONY:	ActionDoDevUInstallDebug ActionDoDevUInstallRelease ActionDoDevUInstallHead
.PHONY:	ActionTryDevInstallApp  ActionTryDevInstallSlib  ActionTryDevInstallAlib  ActionTryDevInstallHead
.PHONY:	ActionTryDevUInstallApp ActionTryDevUInstallSlib ActionTryDevUInstallAlib ActionTryDevUInstallHead
.PHONY:	ActionDevInstallApp  ActionDevInstallSlib  ActionDevInstallAlib  ActionDevInstallAHead
.PHONY:	ActionDevUInstallApp ActionDevUInstallSlib ActionDevUInstallAlib ActionDevUInstallAHead
.PHONY:	devinstall_app_%   devinstall_shared_lib_%   devinstall_static_lib_%   devinstall_head_%
.PHONY:	devuninstall_app_% devuninstall_shared_lib_% devuninstall_static_lib_% devuninstall_head_%
.PHONY:	nodevinstall_app_% nodevinstall_shared_lib_% nodevinstall_static_lib_% nodevinstall_head_%


# Source paths — always resolve to BUILD_ROOT regardless of INSTALL_ACTIVE
DEVINSTALL_SRC_BIN				= $(BUILD_ROOT)/bin
DEVINSTALL_SRC_LIB				= $(BUILD_ROOT)/lib
DEVINSTALL_SRC_INC				= $(BUILD_ROOT)/include

USE_HEADER						?= $(if $(NO_HEADER),NO,YES)
DEVINSTALL_LIBBASENAME_NO_YES	=
DEVINSTALL_LIBBASENAME			= $(DEVINSTALL_LIBBASENAME_$(USE_HEADER)_$(INSTALL_ACTIVE))
DEVINSTALL_LIBBASENAME_NO_NO	= $(LIBBASENAME_ACTUAL)
DEVINSTALL_LIBBASENAME_YES_NO	= $(LIBBASENAME_ACTUAL)
DEVINSTALL_LIBBASENAME_YES_YES	= $(LIBBASENAME_ACTUAL)

DEVINSTALL_TEST_NO				= devinstall
DEVINSTALL_TEST_YES				= nodevinstall
DEVINSTALL_ACTION				= $(DEVINSTALL_TEST_$(TEST_ONLY))

DEVINSTALL_APP					= $(patsubst %.prog,   $(DEVINSTALL_ACTION)_app_%,			$(filter %.prog,  $(TARGET_ALL)))
DEVINSTALL_SHARED_LIB			= $(patsubst %.slib,   $(DEVINSTALL_ACTION)_shared_lib_%,	$(filter %.slib,  $(TARGET_ALL)))
DEVINSTALL_STATIC_LIB			= $(patsubst %.a,      $(DEVINSTALL_ACTION)_static_lib_%,	$(filter %.a,     $(TARGET_ALL)))
DEVINSTALL_HEADER				= $(patsubst %,        $(DEVINSTALL_ACTION)_head_%,			$(DEVINSTALL_LIBBASENAME))


# This is the interface to this makefile.
# Use either ActionDevInstall or ActionDevUInstall
#
ActionDevInstall:				ActionDoDevInstallHead  ActionDoDevInstallDebug  ActionDoDevInstallRelease
ActionDevUInstall:				ActionDoDevUInstallHead ActionDoDevUInstallDebug ActionDoDevUInstallRelease

ActionDoDevInstallDebug:
	$(MAKE) TARGET_MODE=debug	ActionTryDevInstallApp  ActionTryDevInstallSlib ActionTryDevInstallAlib
ActionDoDevInstallRelease:
	$(MAKE) TARGET_MODE=release	ActionTryDevInstallApp  ActionTryDevInstallSlib ActionTryDevInstallAlib
ActionDoDevInstallHead:			ActionTryDevInstallHead

ActionDoDevUInstallDebug:
	$(MAKE) TARGET_MODE=debug	ActionTryDevUInstallApp ActionTryDevUInstallSlib ActionTryDevUInstallAlib
ActionDoDevUInstallRelease:
	$(MAKE) TARGET_MODE=release	ActionTryDevUInstallApp ActionTryDevUInstallSlib ActionTryDevUInstallAlib
ActionDoDevUInstallHead:		ActionTryDevUInstallHead

ActionTryDevInstallApp:			$(if $(strip $(DEVINSTALL_APP)),			ActionDevInstallApp)
ActionTryDevInstallSlib:		$(if $(strip $(DEVINSTALL_SHARED_LIB)),		ActionDevInstallSlib)
ActionTryDevInstallAlib:		$(if $(strip $(DEVINSTALL_STATIC_LIB)),		ActionDevInstallAlib)
ActionTryDevInstallHead:		$(if $(strip $(DEVINSTALL_HEADER)),			ActionDevInstallAHead)

ActionTryDevUInstallApp:		$(if $(strip $(DEVINSTALL_APP)),			ActionDevUInstallApp)
ActionTryDevUInstallSlib:		$(if $(strip $(DEVINSTALL_SHARED_LIB)),		ActionDevUInstallSlib)
ActionTryDevUInstallAlib:		$(if $(strip $(DEVINSTALL_STATIC_LIB)),		ActionDevUInstallAlib)
ActionTryDevUInstallHead:		$(if $(strip $(DEVINSTALL_HEADER)),			ActionDevUInstallAHead)

ActionDevInstallApp:			Note_Start_DevInstalling_Applications $(DEVINSTALL_APP)
ActionDevInstallSlib:			Note_Start_DevInstalling_Libraries    $(DEVINSTALL_SHARED_LIB)
ActionDevInstallAlib:			Note_Start_DevInstalling_Libraries    $(DEVINSTALL_STATIC_LIB)
ActionDevInstallAHead:			Note_Start_DevInstalling_Headers      $(DEVINSTALL_HEADER)
ActionDevUInstallApp:			Note_Start_Clean_Applications  $(patsubst devinstall_%, devuninstall_%, $(DEVINSTALL_APP))
ActionDevUInstallSlib:			Note_Start_Clean_Libraries     $(patsubst devinstall_%, devuninstall_%, $(DEVINSTALL_SHARED_LIB))
ActionDevUInstallAlib:			Note_Start_Clean_Libraries     $(patsubst devinstall_%, devuninstall_%, $(DEVINSTALL_STATIC_LIB))
ActionDevUInstallAHead:			Note_Start_Clean_Headers       $(patsubst devinstall_%, devuninstall_%, $(DEVINSTALL_HEADER))

#
# For No install (When TEST_ONLY = YES) no action taken.
nodevinstall_app_%: ;
nodevinstall_shared_lib_%: ;
nodevinstall_head_%: ;


# --- DevInstall rules (create symlinks) ---

devinstall_app_%: | $(PREFIX_BIN).Dir
	@$(LNSOFT) $(DEVINSTALL_SRC_BIN)/$*$(BUILD_EXTENSION) $(PREFIX_BIN)/$*$(BUILD_EXTENSION)
	@$(LNSOFT) $(PREFIX_BIN)/$*$(BUILD_EXTENSION) $(PREFIX_BIN)/$*$(BUILD_SUFFIX)
	@$(ECHO) $(call paragraph, DevInstall - $(TARGET_MODE) - $*$(BUILD_EXTENSION))

devinstall_shared_lib_%: | $(PREFIX_LIB)$(PREFIX_LIB_SUB).Dir
	@$(LNSOFT) $(DEVINSTALL_SRC_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_EXTENSION).$(SO) $(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_EXTENSION).$(SO)
	@$(LNSOFT) $(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_EXTENSION).$(SO) $(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_SUFFIX).$(SO)
	@$(ECHO) $(call paragraph, DevInstall - $(TARGET_MODE) - lib$*$(BUILD_EXTENSION).$(SO))

devinstall_static_lib_%: | $(PREFIX_LIB)$(PREFIX_LIB_SUB).Dir
	@$(LNSOFT) $(DEVINSTALL_SRC_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_EXTENSION).a $(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_EXTENSION).a
	@$(LNSOFT) $(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_EXTENSION).a $(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_SUFFIX).a
	@$(ECHO) $(call paragraph, DevInstall - $(TARGET_MODE) - lib$*$(BUILD_EXTENSION).a)

devinstall_head_%: | $(PREFIX_INC).Dir
	@if [[ -d $(PREFIX_INC)/$* && ! -L $(PREFIX_INC)/$* ]]; then rm -rf $(PREFIX_INC)/$*; fi
	@ln -sfn $(DEVINSTALL_SRC_INC)/$* $(PREFIX_INC)/$*
	@$(ECHO) $(call paragraph, DevInstall Header Dir $*)


# --- DevUninstall rules (remove symlinks) ---

devuninstall_app_%:
	@$(ECHO) $(call paragraph, Clean Dev - $(TARGET_MODE) - $*$(BUILD_EXTENSION))
	@$(RM) $(PREFIX_BIN)/$*$(BUILD_EXTENSION)
	@if [[ "$(shell readlink $(PREFIX_BIN)/$*$(BUILD_SUFFIX))" == "$(PREFIX_BIN)/$*$(BUILD_EXTENSION)" ]]; then \
		$(RM) $(PREFIX_BIN)/$*$(BUILD_SUFFIX); \
	fi

devuninstall_shared_lib_%:
	@$(ECHO) $(call paragraph, Clean Dev - $(TARGET_MODE) - lib$*$(BUILD_EXTENSION).$(SO))
	@$(RM) $(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_EXTENSION).$(SO)
	@if [[ "$(shell readlink $(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_SUFFIX).$(SO))" == "$(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_EXTENSION).$(SO)" ]]; then \
		$(RM) $(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_SUFFIX).$(SO); \
	fi

devuninstall_static_lib_%:
	@$(ECHO) $(call paragraph, Clean Dev - $(TARGET_MODE) - lib$*$(BUILD_EXTENSION).a)
	@$(RM) $(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_EXTENSION).a
	@if [[ "$(shell readlink $(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_SUFFIX).a)" == "$(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_EXTENSION).a" ]]; then \
		$(RM) $(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_SUFFIX).a; \
	fi

devuninstall_head_%:
	@$(ECHO) $(call paragraph, Clean Dev Header $*)
	@if [[ -L $(PREFIX_INC)/$* ]]; then $(RM) $(PREFIX_INC)/$*; fi
