# ---------------------------------------------------------------------------
# CMake package config installation
# ---------------------------------------------------------------------------
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
