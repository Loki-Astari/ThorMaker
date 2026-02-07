
LOCAL_ROOT		?= $(shell pwd)
# TODO: Remove the need for BASE
BASE			?= .

RELATIVEPATH=$(shell $(THORSANVIL_ROOT)/build/tools/RelPath "$(realpath $(LOCAL_ROOT))" "$(abspath $(THORSANVIL_ROOT)/)")

-include $(THORSANVIL_ROOT)/Makefile.config

BUILD_ROOT		?= $(BUILD_ROOT_IS$(HEADER_ONLY))
BUILD_ROOT_IS	= $(abspath $(LOCAL_ROOT)/$(RELATIVEPATH))/build
BUILD_ROOT_IS1	= $(THORSANVIL_ROOT)/build

include $(BUILD_ROOT)/tools/main.Makefile


check:
	@echo "HEADER_ONLY:              $(HEADER_ONLY)"
	@echo "LOCAL_ROOT:               $(LOCAL_ROOT)"
	@echo "realpath (LOCAL_ROOT):    $(realpath $(LOCAL_ROOT))"
	@echo "THORSANVIL_ROOT:          $(THORSANVIL_ROOT)"
	@echo "abspath(THORSANVIL_ROOT): $(abspath $(THORSANVIL_ROOT)/)"
	@echo "RELATIVEPATH:             $(RELATIVEPATH)"
	@echo "BUILD_ROOT:               $(BUILD_ROOT)"


