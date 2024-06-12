


neovimflags:
	@echo "$(CXX_STD_FLAG) -I.. -I$$(realpath $(THORSANVIL_ROOT))/build/include -I/opt/homebrew/include -I$$(realpath $(THORSANVIL_ROOT))/build/include3rd --include Mock.h"


