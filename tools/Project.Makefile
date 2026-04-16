
-include $(THORSANVIL_ROOT)/Makefile.config
include $(THORSANVIL_ROOT)/build/tools/Make/Colour.Makefile
include $(THORSANVIL_ROOT)/build/tools/Make/Platform.Makefile

.PHONY:	all test clean veryclean install uninstall profile build lint vera doc %.dir

MAKEFLAGS				+= --silent
SHELL					= /bin/bash
DISABLE_CONTROL_CODES	?= FALSE
FILEDIR					?=

filter-remove			= $(filter-out %.Not$(2),$(1))
filter-NotMac			= $(patsubst %.NotMac,%,$(1))
filter-NotLinux			= $(patsubst %.NotLinux,%,$(1))
filter-NotWin			= $(patsubst %.NotWin,%,$(1))
filter-nots				= $(call filter-NotMac,$(call filter-NotLinux,$(call filter-NotWin,$(call filter-remove,$(1),$(PLATFORM_CAT)))))
filter-keep-current		= $(patsubst %.Only$(PLATFORM_CAT),%,$(1))
filter-OnlyMac			= $(filter-out %.OnlyMac,$(1))
filter-OnlyLinux		= $(filter-out %.OnlyLinux,$(1))
filter-OnlyWin			= $(filter-out %.OnlyWin,$(1))
filter-only				= $(call filter-OnlyMac,$(call filter-OnlyLinux,$(call filter-OnlyWin,$(call filter-keep-current,$(1)))))
TARGET_AFTER_HEAD_FILTER= $(call filter-remove,$(call filter-remove,$(call filter-remove,$(TARGET),Win),Linux),Mac)
TARGET_AFTER_FILTER 	= $(call filter-only,$(call filter-nots,$(TARGET)))
SUB_PROJECTS			= $(foreach target,$(TARGET_AFTER_FILTER),$(target).dir)
HEAD_SUB_PROJECTS		= $(foreach target,$(TARGET_AFTER_HEAD_FILTER),$(target).dir)

all:		ACTION=build
release-only:	ACTION=release-only
test:		ACTION=test
clean:		ACTION=clean
veryclean:	ACTION=veryclean NODEP=1
install:	ACTION=install
uninstall:	ACTION=uninstall
profile:	ACTION=profile
build:		ACTION=build
lint:		ACTION=lint
vera:		ACTION=vera
doc:		ACTION=doc
build-honly:ACTION=build-honly
build-hcont:ACTION=build-hcont
print:		ACTION=print
tools:		ACTION=tools
dumpversion:ACTION=dumpversion

ACTION		?=all
BUILD_ROOT	?=$(THORSANVIL_ROOT)/build
PREFIX		?=$(BUILD_ROOT)


all:		$(SUB_PROJECTS)
release-only:	$(SUB_PROJECTS)
test:		$(SUB_PROJECTS)
clean:		$(SUB_PROJECTS)
veryclean:	$(SUB_PROJECTS)
install:	$(SUB_PROJECTS)
uninstall:	$(SUB_PROJECTS)
profile:	$(SUB_PROJECTS)
build:		$(SUB_PROJECTS)
lint:		check_lint $(SUB_PROJECTS)
vera:		$(SUB_PROJECTS)
doc:		$(SUB_PROJECTS) docbuild
build-honly:$(HEAD_SUB_PROJECTS)
build-hcont:$(HEAD_SUB_PROJECTS)
print:		$(SUB_PROJECTS)
tools:		$(SUB_PROJECTS)
dumpversion:$(SUB_PROJECTS)

header-only:
	@host=$$(git remote get-url origin);									\
	dst=$$(mktemp -d);														\
	echo "host: $${host}  dst: $${dst}";									\
	git clone --single-branch --branch header-only $${host} $${dst};		\
	$(MAKE) FILEDIR=$(FILEDIR) DISABLE_CONTROL_CODES=$(DISABLE_CONTROL_CODES) THORSANVIL_ROOT=$(THORSANVIL_ROOT) PREFIX=$${dst} build-honly;	\
	echo "DONE";															\
	echo "		$${dst}";													\
	echo;																	\
	echo "Please Check $${dst} and commit push if required";
headercont:
	@host=$$(git remote get-url origin);									\
	dst="${DST}";															\
	echo "host: $${host}  dst: $${dst}";									\
	$(MAKE) FILEDIR=$(FILEDIR) DISABLE_CONTROL_CODES=$(DISABLE_CONTROL_CODES) THORSANVIL_ROOT=$(THORSANVIL_ROOT) PREFIX=$${dst} build-hcont;	\
	echo "DONE";															\
	echo "		$${dst}";													\
	echo;																	\
	echo "Please Check $${dst} and commit push if required";


docbuild:
	@if [[ -d docSource ]]; then		\
		cd docSource;				\
		andvari build;				\
	fi

%.dir:
	@$(ECHO) $(call colour_text, LIGHT_PURPLE, "Building Dir $(FILEDIR)$* Start")
	@if test -d $*; then														\
		$(MAKE) -j1 -C $* $(ACTION) FILEDIR=$(FILEDIR)$*/ DISABLE_CONTROL_CODES=$(DISABLE_CONTROL_CODES) THORSANVIL_ROOT=$(THORSANVIL_ROOT) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER);		\
	else																		\
		$(ECHO) $(call colour_text, RED, "Sub Project $* non local ignoring");		\
	fi
	@$(ECHO) $(call colour_text, LIGHT_PURPLE, "Building Dir $(FILEDIR)$* Finish")

include $(THORSANVIL_ROOT)/build/tools/Make/Lint.Makefile
include $(THORSANVIL_ROOT)/build/tools/Make/NeoVim.Makefile
include $(THORSANVIL_ROOT)/build/tools/Make/Help.Makefile
	
