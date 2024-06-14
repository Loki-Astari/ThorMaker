


neovimflags:
	@echo "$(CXX_STD_FLAG) -I.. -I$$(realpath $(THORSANVIL_ROOT))/build/include -I/opt/homebrew/include -I$$(realpath $(THORSANVIL_ROOT))/build/include3rd --include Mock.h $(LDLIBS_EXTERN_INC_LOC) $(CXX_EXTERN_HEADER_ONLY)"

#
# This comes from the file: Build/test.Makefile that can run the executable
# We build shared libraries into these local directories
neovimruntime:
	@echo "$(RUNTIME_PATHS_USED_TO_LOAD)"

