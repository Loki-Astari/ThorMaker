
-include $(THORSANVIL_ROOT)/Makefile.config
-include $(THORSANVIL_ROOT)/build/tools/Colour.Makefile

.PHONY:	all test clean install %.dir

MAKE	= make --silent


SUB_PROJECTS	= $(foreach target,$(TARGET),$(target).dir)

all:		ACTION=build
test:		ACTION=test
clean:		ACTION=clean
veryclean:	ACTION=veryclean
install:	ACTION=install
profile:	ACTION=profile
build:		ACTION=build
lint:		ACTION=lint
vera:		ACTION=vera
doc:		ACTION=doc

ACTION		?=all
BUILD_ROOT	?=$(THORSANVIL_ROOT)/build
PREFIX		?=$(BUILD_ROOT)


all:		$(SUB_PROJECTS)
test:		$(SUB_PROJECTS)
clean:		$(SUB_PROJECTS)
veryclean:	$(SUB_PROJECTS)
install:	$(SUB_PROJECTS)
profile:	$(SUB_PROJECTS)
build:		$(SUB_PROJECTS)
lint:		check_lint $(SUB_PROJECTS)
vera:		$(SUB_PROJECTS)
doc:		$(SUB_PROJECTS) docbuild


docbuild:
	@if [[ -d docSource ]]; then		\
		cd docSource;				\
		andvari build;				\
	fi

%.dir:
	@echo $(call colour_text, LIGHT_PURPLE, "Building Dir $* Start")
	@if test -d $*; then														\
		$(MAKE) -j1 -C $* $(ACTION) PREFIX=$(PREFIX) CXXSTDVER=$(CXXSTDVER);		\
	else																		\
		echo $(call colour_text, RED, "Sub Project $* non local ignoring");		\
	fi
	@echo $(call colour_text, LIGHT_PURPLE, "Building Dir $* Finish")

include $(THORSANVIL_ROOT)/build/tools/lint.Makefile
	
