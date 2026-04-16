


neovimflags:
	@echo -DDISABLE_CONTROL_CODES=1 "$(CXX_STD_FLAG) -I.. -I$$(realpath $(THORSANVIL_ROOT))/build/include -I/opt/homebrew/include -I$$(realpath $(THORSANVIL_ROOT))/build/3rd/include --include Mock.h $(LDLIBS_EXTERN_INC_LOC) $(CXX_EXTERN_HEADER_ONLY)"

.clangd:
	@echo "CompileFlags:" 				>  .clangd
	@echo "  Add:"						>> .clangd
	@echo -DDISABLE_CONTROL_CODES=1 $(CXX_STD_FLAG) -I.. -I$$(realpath $(THORSANVIL_ROOT))/build/include -I/opt/homebrew/include -I$$(realpath $(THORSANVIL_ROOT))/build/3rd/include $(LDLIBS_EXTERN_INC_LOC) $(CXX_EXTERN_HEADER_ONLY) | xargs -I^ -n1 echo "    - ^" >> .clangd
	@echo									>> .clangd
	@echo "---"								>> .clangd
	@echo 									>> .clangd
	@echo "If:"								>> .clangd
	@echo "  PathExclude: test/.*"			>> .clangd
	@echo "CompileFlags:" 					>> .clangd
	@echo "  Add:"							>> .clangd
	@echo "    - --include"					>> .clangd
	@echo "    - Mock.h"					>> .clangd
	@echo									>> .clangd
	@if [[ -e test/MockHeaderInclude.h ]]; then 				\
		echo "---"								>> .clangd;		\
		echo 									>> .clangd;		\
		echo "If:"								>> .clangd;		\
		echo "  PathMatch: test/.*"				>> .clangd;		\
		echo "CompileFlags:" 					>> .clangd;		\
		echo "  Add:"							>> .clangd;		\
		echo "    - --include"					>> .clangd;		\
		echo "    - test/MockHeaderInclude.h"	>> .clangd;		\
	fi



#
# This comes from the file: Build/test.Makefile that can run the executable
# We build shared libraries into these local directories
neovimruntime:
	@echo "$(RUNTIME_PATHS_USED_TO_LOAD)"

