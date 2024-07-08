
LOCAL_ROOT		?= $(shell pwd)
# TODO: Remove the need for BASE
BASE			?= .

REALATIVEPATH=$(shell $(THORSANVIL_ROOT)/build/tools/RelPath "$(realpath $(LOCAL_ROOT))" "$(abspath $(THORSANVIL_ROOT)/)")

-include $(THORSANVIL_ROOT)/Makefile.config

BUILD_ROOT		?= $(abspath $(LOCAL_ROOT)/$(REALATIVEPATH))/build
include $(BUILD_ROOT)/tools/main.Makefile


check:
	@echo "LOCAL_ROOT:               $(LOCAL_ROOT)"
	@echo "realpath (LOCAL_ROOT):    $(realpath $(LOCAL_ROOT))"
	@echo "THORSANVIL_ROOT:          $(THORSANVIL_ROOT)"
	@echo "abspath(THORSANVIL_ROOT): $(abspath $(THORSANVIL_ROOT)/)"
	@echo "REALATIVEPATH:            $(REALATIVEPATH)"
	@echo "BUILD_ROOT:               $(BUILD_ROOT)"


