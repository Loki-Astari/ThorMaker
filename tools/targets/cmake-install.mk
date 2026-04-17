# =============================================================================
# targets/cmake-install.mk — CMake package config installation
#
# Installs the ThorsAnvil CMake package config files so downstream CMake
# projects can `find_package(ThorsAnvil)` against this build.
#
# Loaded only when the project sets CMAKE_CONFIG=yes in driver (SUBDIRS)
# mode. Typically enabled at the top-level project-root Makefile and
# nowhere else in the tree. Silently unused in leaf mode.
#
# Requires: THORSANVIL_ROOT BUILD_ROOT libdir SUB_PROJECTS
#           (SUB_PROJECTS comes from drivers/subdirs.mk — hence driver-only)
# Goals:    install-cmake-sys install-cmake-local uninstall-cmake
#           (extends: install build uninstall)
# =============================================================================

CMAKE_SRC_DIR			= $(THORSANVIL_ROOT)/cmake
CMAKE_LOCAL_INSTALL_DIR	= $(BUILD_ROOT)/lib/cmake/ThorsAnvil
CMAKE_SYS_INSTALL_DIR	= $(libdir)/cmake/ThorsAnvil

install:	install-cmake-sys
build:		install-cmake-local

install-cmake-local:	$(SUB_PROJECTS)
	@mkdir -p $(CMAKE_LOCAL_INSTALL_DIR)
	@cp $(CMAKE_SRC_DIR)/ThorsAnvilConfig.cmake        $(CMAKE_LOCAL_INSTALL_DIR)/
	@cp $(CMAKE_SRC_DIR)/ThorsAnvilConfigVersion.cmake  $(CMAKE_LOCAL_INSTALL_DIR)/
	@echo "  Install - CMake config -> $(CMAKE_LOCAL_INSTALL_DIR)/"

install-cmake-sys:	$(SUB_PROJECTS)
	@mkdir -p $(CMAKE_SYS_INSTALL_DIR)
	@cp $(CMAKE_SRC_DIR)/ThorsAnvilConfig.cmake        $(CMAKE_SYS_INSTALL_DIR)/
	@cp $(CMAKE_SRC_DIR)/ThorsAnvilConfigVersion.cmake  $(CMAKE_SYS_INSTALL_DIR)/
	@echo "  Install - CMake config -> $(CMAKE_SYS_INSTALL_DIR)/"

uninstall:	uninstall-cmake

uninstall-cmake:
	@rm -f $(CMAKE_SYS_INSTALL_DIR)/ThorsAnvilConfig.cmake
	@rm -f $(CMAKE_SYS_INSTALL_DIR)/ThorsAnvilConfigVersion.cmake
	@if [ -d $(CMAKE_SYS_INSTALL_DIR) ]; then rmdir $(CMAKE_SYS_INSTALL_DIR) 2>/dev/null || true; fi
