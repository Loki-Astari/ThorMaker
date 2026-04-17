# =============================================================================
# tools/Makefile — ThorMaker entry point + orchestrator
#
# This is the ONLY file a project Makefile needs to include. The mode is
# selected by which variable the project sets before the include:
#
#   Leaf project  — builds files in the current directory:
#     TARGET  = foo.prog bar.slib
#     include $(THORSANVIL_ROOT)/build/tools/Makefile
#
#   Driver project — recurses into a list of subdirectories:
#     SUBDIRS = src tools doc
#     include $(THORSANVIL_ROOT)/build/tools/Makefile
#
# Setting neither (or both) is an error.
#
# See tools/docs/target-conventions.md for the public API — TARGET suffix
# semantics (.prog .a .slib .lib .head .defer .test), per-target variables,
# and the top-level goals (all / build / debug / release / test / install /
# coverage / vera / lint / doc).
#
# Leaf-mode loading is goal-gated: each feature fragment loads only when a
# goal it serves appears in MAKECMDGOALS (so `make clean` or a recursive
# sub-make of `item` loads a minimal kernel rather than all ~15 fragments).
# Set THOR_DEBUG_LOAD=1 to disable gating and force every fragment to load,
# useful for diagnosing "why isn't goal X defined?" or for running
# `make print` with the full surface visible.
#
# Directory layout:
#   core/         — always-loaded kernel (platform, colour, data tables)
#   rules/        — pattern rules + parallel-build engine       (leaf only)
#   targets/      — one file per user-visible goal family       (leaf + some driver)
#   drivers/      — multi-subdir orchestrators                  (driver only)
#   integrations/ — help, editor, header-only workflow
#   debug/        — diagnostic printers, never on the hot build path
#   docs/         — markdown documentation
# =============================================================================

SHELL=/bin/bash

LOCAL_ROOT		?= $(shell pwd)
BASE			?= .

RELATIVEPATH=$(shell $(THORSANVIL_ROOT)/build/tools/util/RelPath "$(realpath $(LOCAL_ROOT))" "$(abspath $(THORSANVIL_ROOT)/)")

-include $(THORSANVIL_ROOT)/Makefile.config
-include $(THORSANVIL_ROOT)/third/$(CONFIG_NAME)/Makefile.config

BUILD_ROOT		?= $(BUILD_ROOT_IS$(HEADER_ONLY))
BUILD_ROOT_IS	= $(abspath $(LOCAL_ROOT)/$(RELATIVEPATH))/build
BUILD_ROOT_IS1	= $(THORSANVIL_ROOT)/build

# --- Always-loaded core ---------------------------------------------------
include $(BUILD_ROOT)/tools/core/platform.mk
include $(BUILD_ROOT)/tools/core/colour.mk
include $(BUILD_ROOT)/tools/core/thors-anvil-libs.mk

# --- Mode dispatch: SUBDIRS (driver) vs TARGET (leaf) ---------------------
ifneq ($(strip $(SUBDIRS)),)
  ifneq ($(strip $(TARGET)),)
    $(error ThorMaker: set either TARGET (leaf project) or SUBDIRS (driver), not both)
  endif
  include $(BUILD_ROOT)/tools/drivers/subdirs.mk

  # Optional driver add-ons. CMAKE_CONFIG installs the ThorsAnvil CMake
  # package config files so downstream CMake consumers can find_package().
  # Typically set only at the top-level project-root driver Makefile.
  ifeq ($(strip $(CMAKE_CONFIG)),yes)
    include $(BUILD_ROOT)/tools/targets/cmake-install.mk
  endif

else ifneq ($(strip $(TARGET)),)
  # CMAKE_CONFIG is silently ignored in leaf mode. The top-level driver
  # may have set it on its command line, which make auto-propagates to
  # leaf sub-makes via MAKEOVERRIDES — erroring here would break that.

  # Empty MAKECMDGOALS defaults to 'all'. Explicit goals stay literal —
  # `make clean` does NOT get unified with `all`, so it won't pull in
  # test.mk / coverage.mk / install.mk / etc.
  _GOALS := $(or $(MAKECMDGOALS),all)

  # --- Always-loaded kernel ----------------------------------------------
  # Variables, top-level build goals, pattern rules and the parallel
  # engine. Small files (help/print) that serve as escape hatches when
  # debugging are also pinned here regardless of goal.
  include $(BUILD_ROOT)/tools/core/variables.mk
  include $(BUILD_ROOT)/tools/targets/build.mk
  include $(BUILD_ROOT)/tools/rules/link.mk
  include $(BUILD_ROOT)/tools/rules/parallel.mk
  include $(BUILD_ROOT)/tools/rules/compile.mk
  include $(BUILD_ROOT)/tools/rules/generate.mk
  include $(BUILD_ROOT)/tools/debug/print.mk
  include $(BUILD_ROOT)/tools/integrations/help.mk

  # --- Goal-gated loads --------------------------------------------------
  # Each feature file is loaded only when a goal it serves appears in
  # MAKECMDGOALS. For recursive sub-makes, MAKECMDGOALS is the goal
  # they were invoked with (e.g. `item`, `_build_prog`, `ActionInstall`)
  # — small sub-makes load just the kernel.
  #
  # Escape hatch: THOR_DEBUG_LOAD=1 skips all gating and loads every
  # fragment. Use when diagnosing "why isn't goal X defined?" or when
  # `make print` needs to see the full surface.
  ifneq ($(strip $(THOR_DEBUG_LOAD)),)
    include $(BUILD_ROOT)/tools/targets/install.mk
    include $(BUILD_ROOT)/tools/targets/test.mk
    include $(BUILD_ROOT)/tools/targets/coverage.mk
    include $(BUILD_ROOT)/tools/targets/vera.mk
    include $(BUILD_ROOT)/tools/targets/lint.mk
    include $(BUILD_ROOT)/tools/targets/doc.mk
    include $(BUILD_ROOT)/tools/integrations/neovim.mk
    include $(BUILD_ROOT)/tools/integrations/header-only.mk
  else
    ifneq ($(filter all build install uninstall release-only veryclean \
                    ActionInstall% ActionUInstall% ActionDo% ActionTry%,$(_GOALS)),)
      include $(BUILD_ROOT)/tools/targets/install.mk
    endif
    ifneq ($(filter all build install test testonly \
                    ActionRunUnitTest build_unit_test run_unit_test \
                    test-% testrun.% debugrun.% reportErrorCheck,$(_GOALS)),)
      include $(BUILD_ROOT)/tools/targets/test.mk
    endif
    ifneq ($(filter all build install test covonly \
                    ActionRunCoverage coverage-% coverage/%.out \
                    check_coverage _build_coverage _stop_coverage \
                    reportCoverage,$(_GOALS)),)
      include $(BUILD_ROOT)/tools/targets/coverage.mk
    endif
    ifneq ($(filter all build install test veraonly vera \
                    ActionRunVera vera-% coverage/%.vera,$(_GOALS)),)
      include $(BUILD_ROOT)/tools/targets/vera.mk
    endif
    ifneq ($(filter lint doLint check_lint lintExecute,$(_GOALS)),)
      include $(BUILD_ROOT)/tools/targets/lint.mk
    endif
    ifneq ($(filter doc docX docprint,$(_GOALS)),)
      include $(BUILD_ROOT)/tools/targets/doc.mk
    endif
    ifneq ($(filter .clangd neovimflags neovimruntime,$(_GOALS)),)
      include $(BUILD_ROOT)/tools/integrations/neovim.mk
    endif
    ifneq ($(filter build-honly build-hcont build-honly-% build-hcont-%,$(_GOALS)),)
      include $(BUILD_ROOT)/tools/integrations/header-only.mk
    endif
  endif

else
  $(error ThorMaker: no TARGET or SUBDIRS declared — set TARGET=... for a leaf project, or SUBDIRS=... for a multi-subdir driver)
endif


check:
	@echo "HEADER_ONLY:              $(HEADER_ONLY)"
	@echo "LOCAL_ROOT:               $(LOCAL_ROOT)"
	@echo "realpath (LOCAL_ROOT):    $(realpath $(LOCAL_ROOT))"
	@echo "THORSANVIL_ROOT:          $(THORSANVIL_ROOT)"
	@echo "abspath(THORSANVIL_ROOT): $(abspath $(THORSANVIL_ROOT)/)"
	@echo "RELATIVEPATH:             $(RELATIVEPATH)"
	@echo "BUILD_ROOT:               $(BUILD_ROOT)"
