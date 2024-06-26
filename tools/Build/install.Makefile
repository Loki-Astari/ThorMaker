
#
# Input:
#		TARGET_ALL:		Expanded set of TARGET
#						Anything to do with "TARGET" will be installed/uninstalled
#		NO_HEADER:		1:			Will only install headers.
#						0(Empty)	Normal install. Will install libs executables
#
#		INSTALL_ACTIVE:	YES =>	/usr/local
#						NO  =>  <ROOT>/build/
#							The "Defered" objects are only installed locally (NO)
#							This allows future targets to be built using the deferred objects.
#
# Usage:
#	Add "ActionInstall" or "ActionUInstall" as a dependency.
#
#

##### External
.PHONY:	ActionInstall ActionUInstall
##### Internal
.PHONY: clean veryclean
.PHONY:	ActionDoInstallDebug  ActionDoInstallRelease  ActionDoInstallHead  ActionDoInstallMan ActionDoInstallConfig
.PHONY:	ActionDoUInstallDebug ActionDoUInstallRelease ActionDoUInstallHead ActionDoUInstallMan ActionDoUInstallConfig
.PHONY:	ActionTryInstallApp  ActionTryInstallSlib  ActionTryInstallAlib  ActionTryInstallHead  ActionTryInstallDefer ActionTryInstallMan ActionTryInstallConfig
.PHONY:	ActionTryUInstallApp ActionTryUInstallSlib ActionTryUInstallAlib ActionTryUInstallHead ActionTryUInstallDefer ActionTryUInstallMan ActionTryUInstallConfig ActionTryUInstallDRoot
.PHONY:	ActionInstallApp  ActionInstallSlib  ActionInstallAlib  ActionInstallAHead  ActionInstallDefer  ActionInstallMan ActionInstallConfig
.PHONY:	ActionUInstallApp ActionUInstallSlib ActionUInstallAlib ActionUInstallAHead ActionUInstallDefer ActionUInstallMan ActionUInstallConfig ActionUInstallDRoot
.PHONY:	install_app_%   install_shared_lib_%   install_static_lib_%   install_head_%   install_defer_YES_%   install_defer_NO_%   install_defer_dir_YES_%   install_defer_dir_NO_%
.PHONY:	uninstall_app_% uninstall_shared_lib_% uninstall_static_lib_% uninstall_head_% uninstall_defer_YES_% uninstall_defer_NO_% uninstall_defer_dir_YES_% uninstall_defer_dir_NO_%
.PHONY:	install_config_local_NO_% install_config_local_YES_% install_config_root_NO_% install_config_root_YES_%
.PHONY:	root_clean_defer_YES_% root_clean_defer_NO_%
.PHONY:	install_defer_lib install_defer_obj
.PRECIOUS: $(PREFIX_BIN)/%$(BUILD_EXTENSION)
.PRECIOUS: $(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib%$(BUILD_EXTENSION).$(SO)
.PRECIOUS: $(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib%$(BUILD_EXTENSION).a



# Variables used local only
LIBBASENAME_ONE_OF			= $(patsubst %.a,    %, $(filter %.a,    $(TARGET_ALL)))	\
							  $(patsubst %.slib, %, $(filter %.slib, $(TARGET_ALL)))	\
							  $(patsubst %.lib,  %, $(filter %.lib,  $(TARGET_ALL)))	\
							  $(patsubst %.head, %, $(filter %.head, $(TARGET_ALL)))	\
							  $(patsubst %.test, %, $(filter %.test, $(TARGET_ALL)))	\
							  $(patsubst %.defer,%, $(filter %.defer,$(TARGET_ALL)))
LIBBASENAME_ACTUAL			= $(strip $(firstword $(LIBBASENAME_ONE_OF)))
USE_HEADER					= $(if $(NO_HEADER),NO,YES)
LIBBASENAME_NO_NO			= $(LIBBASENAME_ACTUAL)
LIBBASENAME_YES_NO			= $(LIBBASENAME_ACTUAL)
LIBBASENAME_YES_YES			= $(LIBBASENAME_ACTUAL)

#
# If we don't want headers and this is a full install
# Then don't do any work with the headers (ie. don't install into /usr/local/include)
# All other situations above we make a copy locally.
LIBBASENAME_NO_YES			= 
LIBBASENAME					= $(LIBBASENAME_$(USE_HEADER)_$(INSTALL_ACTIVE))
INSTALL_MAN_SRC				= $(wildcard man/man*/*)
INSTALL_MAN_DIR				= $(patsubst man/%, $(PREFIX_MAN)/%.Dir, $(sort $(dir $(INSTALL_MAN_SRC))))
INSTALL_MAN_PAGE			= $(patsubst man/%, $(PREFIX_MAN)/%.man, $(INSTALL_MAN_SRC))
INSTALL_CONFIG_LOCAL		= $(if $(CONFIG) $(INSTALL_APP_NAME), $(patsubst %, install_config_local_$(INSTALL_ACTIVE)_%, $(wildcard *.$(CONFIG))))
INSTALL_CONFIG_ROOT			= $(if $(CONFIG) $(INSTALL_APP_NAME), $(patsubst %, install_config_root_$(INSTALL_ACTIVE)_%, $(wildcard *.$(CONFIG))))

INSTALL_APP_NAME			= $(strip $(patsubst %.prog,   %,					$(filter %.prog,  $(TARGET_ALL))))
INSTALL_APP					= $(patsubst %.prog,   install_app_%,		$(filter %.prog,  $(TARGET_ALL)))
INSTALL_SHARED_LIB			= $(patsubst %.slib,  install_shared_lib_%, $(filter %.slib, $(TARGET_ALL)))
INSTALL_STATIC_LIB			= $(patsubst %.a,     install_static_lib_%, $(filter %.a,    $(TARGET_ALL)))
INSTALL_HEADER				= $(patsubst %,		  install_head_%,		$(LIBBASENAME))
INSTALL_MAN					= $(if $(strip $(INSTALL_MAN_PAGE)), install_man_$(INSTALL_ACTIVE))
INSTALL_CONFIG				= $(INSTALL_CONFIG_LOCAL) $(INSTALL_CONFIG_ROOT)
INSTALL_DEFER				= $(patsubst %, install_defer_$(INSTALL_ACTIVE)_%, $(DEFER_NAME))
INSTALL_DEFER_DIR			= $(patsubst %, install_defer_dir_$(INSTALL_ACTIVE)_%, $(DEFER_NAME))
INSTALL_HEAD				= $(patsubst %, $(PREFIX_INC)/$(LIBBASENAME)/%, $(HEAD))
INSTALL_DEFER_OBJ			= $(patsubst %, $(PREFIX_DEFER_OBJ)/$(DEFER_NAME)/%, $(OBJ)) 


# This is the interface to this makefile.
# Use either ActionInstall or ActionUInstall
#
ActionInstall:				ActionDoInstallHead  ActionDoInstallDebug  ActionDoInstallRelease  ActionDoInstallMan ActionDoInstallConfig
ActionUInstall:				ActionDoUInstallHead ActionDoUInstallDebug ActionDoUInstallRelease ActionDoUInstallMan ActionDoUInstallConfig ActionTryUInstallDRoot

ActionDoInstallDebug:
	$(MAKE) FILEDIR=$(FILEDIR) NEOVIM=$(NEOVIM) TARGET_MODE=debug	ActionTryInstallApp  ActionTryInstallSlib ActionTryInstallAlib ActionTryInstallDefer
ActionDoInstallRelease:
	$(MAKE) FILEDIR=$(FILEDIR) NEOVIM=$(NEOVIM) TARGET_MODE=release ActionTryInstallApp  ActionTryInstallSlib ActionTryInstallAlib ActionTryInstallDefer
ActionDoInstallHead:		ActionTryInstallHead
ActionDoInstallMan:			ActionTryInstallMan
ActionDoInstallConfig:		ActionTryInstallConfig

ActionDoUInstallDebug:
	$(MAKE) FILEDIR=$(FILEDIR) NEOVIM=$(NEOVIM) TARGET_MODE=debug	ActionTryUInstallApp ActionTryUInstallSlib ActionTryUInstallAlib ActionTryUInstallDefer
ActionDoUInstallRelease:
	$(MAKE) FILEDIR=$(FILEDIR) NEOVIM=$(NEOVIM) TARGET_MODE=release	ActionTryUInstallApp ActionTryUInstallSlib ActionTryUInstallAlib ActionTryUInstallDefer
ActionDoUInstallHead:		ActionTryUInstallHead
ActionDoUInstallMan:		ActionTryUInstallMan
ActionDoUInstallConfig:		ActionTryUInstallConfig

ActionTryInstallApp :		$(if $(strip $(INSTALL_APP)),			ActionInstallApp)
ActionTryInstallSlib:		$(if $(strip $(INSTALL_SHARED_LIB)),	ActionInstallSlib)
ActionTryInstallAlib:		$(if $(strip $(INSTALL_STATIC_LIB)),	ActionInstallAlib)
ActionTryInstallHead:		$(if $(strip $(INSTALL_HEADER)),		ActionInstallAHead)
ActionTryInstallMan:		$(if $(strip $(INSTALL_MAN)),			ActionInstallMan)
ActionTryInstallConfig:		$(if $(strip $(INSTALL_CONFIG)),		ActionInstallConfig)
ActionTryInstallDefer:		$(if $(strip $(INSTALL_DEFER)),			ActionInstallDefer)

ActionTryUInstallApp:		$(if $(strip $(INSTALL_APP)),			ActionUInstallApp)
ActionTryUInstallSlib:		$(if $(strip $(INSTALL_SHARED_LIB)),	ActionUInstallSlib)
ActionTryUInstallAlib:		$(if $(strip $(INSTALL_STATIC_LIB)),	ActionUInstallAlib)
ActionTryUInstallHead:		$(if $(strip $(INSTALL_HEADER)),		ActionUInstallAHead)
ActionTryUInstallMan:		$(if $(strip $(INSTALL_MAN)),			ActionUInstallMan)
ActionTryUInstallConfig:	$(if $(strip $(INSTALL_CONFIG)),		ActionUInstallConfig)
ActionTryUInstallDefer:		$(if $(strip $(INSTALL_DEFER)),			ActionUInstallDefer)
ActionTryUInstallDRoot:		$(if $(strip $(INSTALL_DEFER_DIR)),		ActionUInstallDRoot)

ActionInstallApp:			Note_Start_Installing_Applications $(INSTALL_APP)           Note_End_Installing_Applications
ActionInstallSlib:			Note_Start_Installing_Libraries    $(INSTALL_SHARED_LIB)    Note_End_Installing_Libraries
ActionInstallAlib:			Note_Start_Installing_Libraries    $(INSTALL_STATIC_LIB)    Note_End_Installing_Libraries
ActionInstallAHead:			Note_Start_Installing_Headers      $(INSTALL_HEADER)        Note_End_Installing_Headers
ActionInstallMan:			Note_Start_Installing_Man          $(INSTALL_MAN)           Note_End_Installing_Man
ActionInstallConfig:		Note_Start_Installing_Config       $(INSTALL_CONFIG)        Note_End_Installing_Config
ActionInstallDefer:			Note_Start_Installing_DeferLib     $(INSTALL_DEFER)         Note_End_Installing_DeferLib
ActionUInstallApp:			Note_Start_Clean_Applications      $(patsubst install_%, uninstall_%, $(INSTALL_APP))               Note_End_Clean_Applications
ActionUInstallSlib:			Note_Start_Clean_Libraries         $(patsubst install_%, uninstall_%, $(INSTALL_SHARED_LIB))        Note_End_Clean_Libraries
ActionUInstallAlib:			Note_Start_Clean_Libraries         $(patsubst install_%, uninstall_%, $(INSTALL_STATIC_LIB))        Note_End_Clean_Libraries
ActionUInstallAHead:		Note_Start_Clean_Headers           $(patsubst install_%, uninstall_%, $(INSTALL_HEADER))            Note_End_Clean_Headers
ActionUInstallMan:			Note_Start_Clean_Man               $(patsubst install_%, uninstall_%, $(INSTALL_MAN))               Note_End_Clean_Man
ActionUInstallConfig:		Note_Start_Clean_Config            $(patsubst install_%, uninstall_%, $(INSTALL_CONFIG))            Note_End_Clean_Config
ActionUInstallDefer:		Note_Start_Clean_Defer             $(patsubst install_%, uninstall_%, $(INSTALL_DEFER))             Note_End_Clean_Defer
ActionUInstallDRoot:		Note_Start_Clean_Defer_Root        $(patsubst install_%, uninstall_%, $(INSTALL_DEFER_DIR))         Note_End_Clean_Defer_Root

install_app_%:				$(PREFIX_BIN)/%$(BUILD_EXTENSION)
	@# Don't know why I need this!
install_shared_lib_%:		$(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib%$(BUILD_EXTENSION).$(SO)
	@# Don't know why I need this!
install_static_lib_%:		$(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib%$(BUILD_EXTENSION).a
	@# Don't know why I need this!
install_head_$(LIBBASENAME):$(INSTALL_HEAD)
	@# Do nothng
install_man_NO:
	@# Do nothng
install_man_YES: $(INSTALL_MAN_PAGE)
	@# Do nothng


install_config_local_NO_%:
	@# Do nothng
install_config_root_NO_%:
	@# Do nothng
install_config_local_YES_%:	$(HOME)/.$(INSTALL_APP_NAME).Dir
	-cp $* $(HOME)/.$(INSTALL_APP_NAME)/
install_config_root_YES_%: $(PREFIX_CONFIG)/$(INSTALL_APP_NAME).Dir
	-cp $* $(PREFIX_CONFIG)/$(INSTALL_APP_NAME)/
install_defer_YES_%:
	@# Do nothng
install_defer_NO_$(DEFER_NAME):		install_defer_lib install_defer_obj
	@# Do nothng
install_defer_dir_YES_%:
	@# Do nothng
install_defer_dir_NO_%:
	@# Do nothng

install_defer_lib:		$(PREFIX_DEFER_LIB)/libUnitTest$(DEFER_NAME)$(BUILD_EXTENSION).a
install_defer_obj:		$(INSTALL_DEFER_OBJ)


$(PREFIX_BIN)/%$(BUILD_EXTENSION):				$(TARGET_MODE)/%.prog		| $(PREFIX_BIN).Dir
	@$(CP) $(TARGET_MODE)/$*.prog $(PREFIX_BIN)/$*$(BUILD_EXTENSION)
	@$(LNSOFT) $(PREFIX_BIN)/$*$(BUILD_EXTENSION) $(PREFIX_BIN)/$*$(BUILD_SUFFIX)
	@$(ECHO) $(call paragraph, Install - $(TARGET_MODE) - $*$(BUILD_EXTENSION))

$(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib%$(BUILD_EXTENSION).$(SO):		$(TARGET_MODE)/lib%.$(SO)	| $(PREFIX_LIB)$(PREFIX_LIB_SUB).Dir
	@$(CP) $(TARGET_MODE)/lib$*.$(SO) $(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_EXTENSION).$(SO)
	@$(LNSOFT) $(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_EXTENSION).$(SO) $(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_SUFFIX).$(SO)
	@$(ECHO) $(call paragraph, Install - $(TARGET_MODE) - lib$*$(BUILD_EXTENSION).$(SO))

$(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib%$(BUILD_EXTENSION).a:			$(TARGET_MODE)/lib%.a		| $(PREFIX_LIB)$(PREFIX_LIB_SUB).Dir
	@$(CP) $(TARGET_MODE)/lib$*.a $(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_EXTENSION).a
	@$(LNSOFT) $(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_EXTENSION).a $(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_SUFFIX).a
	@$(ECHO) $(call paragraph, Install - $(TARGET_MODE) - lib$*$(BUILD_EXTENSION).a)

$(PREFIX_INC)/$(LIBBASENAME)/%:	%											| $(PREFIX_INC)/$(LIBBASENAME).Dir
	@#for head in $(HEAD); do $(CP) $${head} $(PREFIX_INC)/$*/;done
	@$(CP) $* $(PREFIX_INC)/$(LIBBASENAME)/$*
	@$(ECHO) $(call paragraph, Install Header $*)

$(PREFIX_MAN)/%.man:	man/% | $(INSTALL_MAN_DIR)
	$(CP) man/$* $(PREFIX_MAN)/$*

$(PREFIX_DEFER_LIB)/libUnitTest$(DEFER_NAME)$(BUILD_EXTENSION).a:	$(TARGET_MODE)/libUnitTest$(DEFER_NAME).a	| $(PREFIX_DEFER_LIB).Dir
	@$(CP) $(TARGET_MODE)/libUnitTest$(DEFER_NAME).a $(PREFIX_DEFER_LIB)/libUnitTest$(DEFER_NAME)$(BUILD_EXTENSION).a
	@$(ECHO) $(call paragraph, Install Defer - $(TARGET_MODE) - libUnitTest$(DEFER_NAME)$(BUILD_EXTENSION).a)

$(PREFIX_DEFER_OBJ)/$(DEFER_NAME)/$(TARGET_MODE)/%:	%								| $(PREFIX_DEFER_OBJ)/$(DEFER_NAME)/$(TARGET_MODE).Dir
	@#for obj in $(OBJ); do base=$$(basename $${obj});$(CP) $${obj} $(PREFIX_DEFER_OBJ)/$*/$(TARGET_MODE)/$${base}; done
	@$(CP) $* $(PREFIX_DEFER_OBJ)/$(DEFER_NAME)/$(TARGET_MODE)/
	@$(ECHO) $(call paragraph, Install Defer $*)

uninstall_app_%:
	@$(ECHO) $(call paragraph, Clean - $(TARGET_MODE) - $*$(BUILD_EXTENSION))
	@$(RM) $(PREFIX_BIN)/$*$(BUILD_EXTENSION)
	@if [[ "$(shell readlink $(PREFIX_BIN)/$*$(BUILD_SUFFIX))" == "$(PREFIX_BIN)/$*$(BUILD_EXTENSION)" ]]; then \
		$(RM) $(PREFIX_BIN)/$*$(BUILD_SUFFIX); \
	fi

uninstall_shared_lib_%:
	@$(ECHO) $(call paragraph, Clean - $(TARGET_MODE) - lib$*$(BUILD_EXTENSION).$(SO))
	@$(RM) $(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_EXTENSION).$(SO)
	@if [[ "$(shell readlink $(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_SUFFIX).$(SO))" == "$(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_EXTENSION).$(SO)" ]]; then \
		$(RM) $(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_SUFFIX).$(SO); \
	fi

uninstall_static_lib_%:
	@$(ECHO) $(call paragraph, Clean - $(TARGET_MODE) - lib$*$(BUILD_EXTENSION).a)
	@$(RM) $(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_EXTENSION).a
	@if [[ "$(shell readlink $(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_SUFFIX).a)" == "$(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_EXTENSION).a" ]]; then \
		$(RM) $(PREFIX_LIB)$(PREFIX_LIB_SUB)/lib$*$(BUILD_SUFFIX).a; \
	fi

uninstall_head_%:
	@$(ECHO) $(call paragraph, Clean Header $*)
	@for head in $(HEAD); do $(RM) -f $(PREFIX_INC)/$*/$${head};done
	@if [[ -e $(PREFIX_INC)/$*/ ]]; then $(RMDIR) $(PREFIX_INC)/$*/; fi

uninstall_man_NO:
uninstall_man_YES: $(patsubst %.man, %.unman, $(INSTALL_MAN_PAGE))

uninstall_config_local_NO_%:
	@# Do nothng
uninstall_config_root_NO_%:
	@# Do nothng
uninstall_config_local_YES_%:
	-$(RM) -rf $(HOME)/.$(INSTALL_APP_NAME)/
uninstall_config_root_YES_%:
	-$(RM) -rf $(PREFIX_CONFIG)/$(INSTALL_APP_NAME)/

$(PREFIX_MAN)/%.unman: $(PREFIX_MAN).Dir
	$(RM) $(PREFIX_MAN)/$*

uninstall_defer_YES_%:
	@# nothing to do

uninstall_defer_NO_%:
	@$(ECHO) $(call paragraph, Clean Defer $(TARGET_MODE) libUnitTest$*$(BUILD_EXTENSION).a)
	@$(RM) $(PREFIX_DEFER_LIB)/libUnitTest$*$(BUILD_EXTENSION).a
	@$(ECHO) $(call paragraph, Clean Defer $(TARGET_MODE) $*)
	@for obj in $(OBJ); do base=$$(basename $${obj});$(RM) -f $(PREFIX_DEFER_OBJ)/$*/$(TARGET_MODE)/$${base}; done
	@if [[ -e $(PREFIX_DEFER_OBJ)/$*/$(TARGET_MODE) ]]; then $(RMDIR) $(PREFIX_DEFER_OBJ)/$*/$(TARGET_MODE); fi

uninstall_defer_dir_YES_%:
	@# nothing to do

uninstall_defer_dir_NO_%:
	@$(ECHO) $(call paragraph, Clean Defer $* ROOT)
	@if [[ -e $(PREFIX_DEFER_OBJ)/$*/ ]]; then $(RMDIR) $(PREFIX_DEFER_OBJ)/$*/; fi


