

PLATFORM					= $(shell uname -s)
PLATFORMVER					= $(subst .,_,$(shell uname -r | sed 's/-.*//'))
SO							= $(SHARD_LIB_EXTENSOION_$(PLATFORM))
SONAME						= $(SHARD_LIB_NAME_FLAG_$(PLATFORM))
SHARED_LIB_FLAG				= $(SHARED_LIB_FLAG_$(PLATFORM))
ECHO						= $(ECHO_$(PLATFORM))

#
COMPILER_NAME				= $(basename $(basename $(basename $(subst -,.,$(subst +,p,$(CXX))))))
COMPILER_VERSION			= $(COMPILER_CXX_$(COMPILER_NAME)_VERSION)

# If we add different compilers we can expand this with how they fetch their version
# Currently we only use gcc so we have the technique for getting the gcc version
COMPILER_CXX_gpp_VERSION	= $(subst .,_,$(basename $(shell $(CXX) -dumpversion)))

ECHO_Darwin					= echo -e
ECHO_Linux					= echo -e

SHARD_LIB_EXTENSOION_Darwin	= dylib
SHARD_LIB_EXTENSOION_Linux	= so

SHARED_LIB_FLAG_Darwin		= -dynamiclib -install_name lib$*$(BUILD_EXTENSION).$(SO)
SHARED_LIB_FLAG_Linux		= -shared

SHARD_LIB_NAME_FLAG_Darwin	= -install_name
SHARD_LIB_NAME_FLAG_Linux	= -soname

RUNTIME_SHARED_PATH_SET			= $(RUNTIME_SHARED_PATH_SET_$(PLATFORM))
RUNTIME_SHARED_PATH_SET_Darwin	= DYLD_LIBRARY_PATH
RUNTIME_SHARED_PATH_SET_Linux	= LD_LIBRARY_PATH

