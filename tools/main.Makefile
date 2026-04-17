# =============================================================================
# main.Makefile — build-system orchestrator
#
# This file wires up all the .mk fragments that make up the build system.
# It is included (via tools/Makefile) by every leaf project Makefile.
#
# For the public API — TARGET suffixes (.prog .a .slib .lib .head .defer
# .test), per-target variables (<NAME>_CXXFLAGS, <NAME>_LDLIBS, etc.) and
# the top-level goals (all / build / debug / release / test / install /
# coverage / vera / lint / doc) — see tools/docs/target-conventions.md.
#
# Directory layout:
#   core/         — always-loaded kernel (platform, colour, variables)
#   rules/        — pattern rules + parallel-build engine
#   targets/      — one file per user-visible goal family
#   drivers/      — multi-subdir orchestrators
#   integrations/ — help, editor, header-only workflow
#   debug/        — diagnostic printers, never on the hot build path
#   docs/         — markdown documentation
# =============================================================================

SHELL=/bin/bash

-include $(realpath $(THORSANVIL_ROOT)/Makefile.config)
-include $(realpath $(THORSANVIL_ROOT)/third/$(CONFIG_NAME)/Makefile.config)
BUILD_ROOT		?= $(THORSANVIL_ROOT)/build
BASE			?= .

# --- Core: always loaded --------------------------------------------------
include $(BUILD_ROOT)/tools/core/platform.mk
include $(BUILD_ROOT)/tools/core/colour.mk
include $(BUILD_ROOT)/tools/core/thors-anvil-libs.mk
include $(BUILD_ROOT)/tools/core/variables.mk

# --- Top-level goals + header-only workflow -------------------------------
include $(BUILD_ROOT)/tools/targets/build.mk
include $(BUILD_ROOT)/tools/integrations/header-only.mk

# --- Target-level features ------------------------------------------------
include $(BUILD_ROOT)/tools/targets/install.mk
include $(BUILD_ROOT)/tools/targets/test.mk
include $(BUILD_ROOT)/tools/targets/coverage.mk
include $(BUILD_ROOT)/tools/targets/vera.mk
include $(BUILD_ROOT)/tools/integrations/help.mk
include $(BUILD_ROOT)/tools/targets/lint.mk
include $(BUILD_ROOT)/tools/targets/doc.mk
include $(BUILD_ROOT)/tools/integrations/neovim.mk

# --- Pattern rules + parallel engine --------------------------------------
include $(BUILD_ROOT)/tools/rules/link.mk
include $(BUILD_ROOT)/tools/rules/parallel.mk
include $(BUILD_ROOT)/tools/rules/compile.mk
include $(BUILD_ROOT)/tools/rules/generate.mk

# --- Diagnostics (print / dumpversion / tools / headerinfo) ---------------
include $(BUILD_ROOT)/tools/debug/print.mk
