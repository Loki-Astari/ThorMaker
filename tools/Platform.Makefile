

PLATFORM					= $(shell uname -s)
PLATFORMVER					= $(subst .,_,$(shell uname -r | sed 's/-.*//'))
SO							= $(SHARD_LIB_EXTENSOION_$(PLATFORM))
SONAME						= $(SHARD_LIB_NAME_FLAG_$(PLATFORM))

#
COMPILER_NAME				= $(subst +,p,$(CXX))
COMPILER_VERSION			= $(COMPILER_CXX_$(COMPILER_NAME)_VERSION)

# If we add different compilers we can expand this with how they fetch their version
# Currently we only use gcc so we have the technique for getting the gcc version
COMPILER_CXX_gpp_VERSION	= $(subst .,_,$(shell g++ -dumpversion))

SHARD_LIB_EXTENSOION_Darwin	= dylib
SHARD_LIB_EXTENSOION_Linux	= so

SHARD_LIB_NAME_FLAG_Darwin	= -install_name
HARD_LIB_NAME_FLAG_Linux	= -soname

RUNTIME_SHARED_PATH_SET			= $(RUNTIME_SHARED_PATH_SET_$(PLATFORM))
RUNTIME_SHARED_PATH_SET_Darwin	= DYLD_LIBRARY_PATH
RUNTIME_SHARED_PATH_SET_Linux	= LD_LIBRARY_PATH

