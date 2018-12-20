#
# These tools are used to build *.md files for documentation.
# It is designed to work with `andvari` and the theme andvari-theme-documentation
#
#	andvari:						https://github.com/Loki-Astari/andvari
#	andvari-theme-documentation:	https://github.com/Loki-Astari/andvari-theme-documentation
#
# How to set up your project to use these tools:
#	Prerequisite:
#		Your project is built with ThorMaker (this package).
#		You have "andvari" installed locally
#	
#	> andvari init docSource --dest docs -t "My Project" -d "Some Text" --themeRepo git@github.com:Loki-Astari/andvari-theme-documentation.git --themeName documentation
#	> make doc
#	> git add <all documentation>
#	> git commit -a -m "Initial documentation"
#	> cd docSource
#	> andvari deploy
#	# Your documentation should be available through your github pages
#
#	PostActions
#		You have set your projects github pages to "docs"
#			Goto the project "Settings" tab on github.com
#			Scroll down to the section: "GitHub Pages"
#			Set the "Source" drop down to "Master branch /docs folder"
#			Wait 15 minutes for git hub to get all the auto publishing corret.
#
# What is put in the documentation
#	1: Tags
#			You can place tags in the header file.
#			This will cause any local comments to placed into the documentation.
#	2: Docs files
#			In the source directory Add a docs directory.
#			Each file in the docs directory will be used for the third column
#			in the documentation page.
#			See below for naming conventions.
#
# Tags
# ====
#
#	@class
#	@function
#	@method
#	@param
#	@return
#
#	The above tags will add information about class/methdod/functions/param/return values to the documentation.
#
#	Useage: @class
#
#		// @class
#		// <Multiple Lines Of Documentation>
#		class <name>
#
#		Example:
#		========
#		// @class
#		// Base of all the socket classes
#		// This class should not be directly created.
#		// All socket classes are movable but not copyable
#		class BaseSocket
#		{
#		}
#
#	This will create the documentation for "BaseSocket" using the comments between
#	@class and the class definition as the source used in the documentation.
#	It is looking for "class <name>" as the termination point
#
#	Useage: @function
#
#		// @function
#		// <Multiple Lines Of Documentation>
#		// @param and @return params allowed
#		<type> <name>(
#
#		Example:
#		========
#		// @function
#		// Builds an error message from 2 parts
#		std::string buildErrorMessage(char const*, char const*)
#
#	The @function declaration works in basically the same way as the @class.
#	It is just looking for a function definition "<type> <name>(" as the termination point.
#
#	Usage: @method
#
#		// @class
#		..... Ignored Lines
#		// @method
#		// <Multiple Lines Of Documentation>
#		// @param and @return params allowed and
#		<type> <name>(
#
#		Example:
#		========
#		// @method
#		// Reads data from a sokcet into a buffer.
#		// If the stream is blocking will not return until the requested amount of data has been read or there is no more data to read.
#		// If the stream in non blocking will return if the read operation would block.
#		// @return              This method returns a <code>std::pair&lt;bool, std::size_t&gt;</code>. The first member `bool` indicates if more data can potentially     be read from the stream. If the socket was cut or the EOF reached then this value will be false. The second member `std::size_t` indicates exactly how many bytes we    re read from this stream.
#		// @param buffer        The buffer data will be read into.
#		// @param size          The size of the buffer.
#		// @param alreadyGot    Offset into buffer (and amount size is reduced by) as this amount was read on a previous call).
#		std::pair<bool, std::size_t> getMessageData(char* buffer, std::size_t size, std::size_t alreadyGot = 0);
#
#	The @method must be used inside a class marked with @class
#	After the @method line all comments are added to the documentation.
#	You can also add @param and @return markers to get more specific information about these values.
#
#	Usage:	@param
#		// @param <Name>		<Documentation>
#
#	Can only be used after a @method or @function tag.
#
#	Usage:	@return
#		// @return				<Documentation>
#
#	Can only be used after a @method or @function tag.
#
# Docs
# ====
#
# Files:
#	docs/package
#		Added to the package.
#	docs/<FileName>.<ClassName>
#		Added this file into the documentation for the class "ClassName" defined in "FileName".
#	docs/<FileName>.<FunctionName>
#		Added this file into the documentation for the function "FunctionName" defined in "FileName".
#	docs/<FileName>.<ClassName>.<MethodName>
#		Added this file into the documentation for the Method "MethodName" in the class "ClassName" defined in "FileName".
#

DOC_PACKAGE_TOOL			= $(BUILD_ROOT)/doc/buildPackage
DOC_PACKAGE_SECTION_TOOL	= $(BUILD_ROOT)/doc/packageSectionList
DOC_CLASS_TOOL				= $(BUILD_ROOT)/doc/buildClass
DOC_METHOD_TOOL				= $(BUILD_ROOT)/doc/buildMethod
DOC_FUNCTION_TOOL			= $(BUILD_ROOT)/doc/buildFunction
DOC_CLASS_LIST_TOOL			= $(BUILD_ROOT)/doc/classList
DOC_METHOD_LIST_TOOL		= $(BUILD_ROOT)/doc/methodList

DOC_SOURCE					?= docSource/source
DOC_DIR						= $(THORSANVIL_ROOT)/$(DOC_SOURCE)

DOC_DEST					= $(DOC_DIR)/$(1)/$(2).md

DOC_FILES					= $(DOC_PACKAGE) $(DOC_CLASSES) $(DOC_METHODS)
DOC_BASE					= $(basename $(firstword $(TARGET)))

DOC_PACKAGE_SECT			= $(shell $(DOC_PACKAGE_SECTION_TOOL))
DOC_PACKAGE_SECT_FILE		= $(foreach loop, $(DOC_PACKAGE_SECT), $(call DOC_DEST,package,$(DOC_BASE)-$(loop)))
DOC_PACKAGE					= $(if $(DOC_CLASS_FILES) $(DOC_METHOD_FILES), $(call DOC_DEST,package,$(DOC_BASE)) $(DOC_PACKAGE_SECT_FILE))

DOC_CLASS_EXPAND			= $(foreach loop, $(shell $(BUILD_ROOT)/doc/classList $(1) '.*'), $(call DOC_DEST,class,$(DOC_BASE).$(basename $(1)).$(loop)))
DOC_CLASSES					= $(foreach loop, $(DOC_CLASS_FILES), $(call DOC_CLASS_EXPAND, $(loop)))
DOC_CLASS_FILES				= $(shell $(BUILD_ROOT)/doc/findMarksFiles function)

DOC_FUNC_EXPAND				= $(foreach loop, $(shell $(BUILD_ROOT)/doc/functionList $(1) '.*'), $(call DOC_DEST,function,$(DOC_BASE).$(basename $(1)).glob.none.$(loop)))

# Given a list of files generate a list of functions
#	$(call $(DOC_DIR)/function/$(DOC_BASE).${file-rm-ext}.glob.none.${funcName}.md
DOC_FUNCS					= $(foreach loop, $(DOC_FUNC_FILES), $(call DOC_FUNC_EXPAND,$(loop)))

# List of all files with Functions
DOC_FUNC_FILES				= $(shell $(BUILD_ROOT)/doc/findMarksFiles function)

# Build a list of file names
#	$(DOC_DIR)/method/$(DOC_BASE).${file-rm-ext}.${class}.${methodType}.${index}.${methodName}.md
DOC_METHOD_GETCLASSMETHOD_T	= $(foreach loop, $(shell $(BUILD_ROOT)/doc/methodList $(1) $(3) $(2)), $(call DOC_DEST,method,$(DOC_BASE).$(basename $(1)).$(2).$(3).$(loop)))

# Call DOC_METHOD_GETCLASSMETHOD_T ${file} ${class} ${method}
#	To get a list of files for methods/virtuals/protected
#	$(DOC_DIR)/method/$(DOC_BASE).${file-rm-ext}.${class}.${methodType}.${index}.${methodName}.md
DOC_METHOD_GETCLASSMETHOD	= $(call DOC_METHOD_GETCLASSMETHOD_T,$(1),$(2),methods) $(call DOC_METHOD_GETCLASSMETHOD_T,$(1),$(2),virtual) $(call  DOC_METHOD_GETCLASSMETHOD_T,$(1),$(2),protected)

# Loop over files with @class: call DOC_METHOD_GETCLASSMETHOD ${file} ${class}
# Get a list of files that need to be built
#	$(DOC_DIR)/method/$(DOC_BASE).${file-rm-ext}.${class}.${methodType}.${index}.${methodName}.md
DOC_METHOD_GETCLASS			= $(foreach loop, $(shell $(DOC_CLASS_LIST_TOOL) $(1)), $(call DOC_METHOD_GETCLASSMETHOD, $(1),$(loop)))

# List all classes in the files
DOC_METHODS					= $(foreach loop, $(DOC_METHOD_FILES), $(call DOC_METHOD_GETCLASS,$(loop)))

# List of files that contain @method
DOC_METHOD_FILES			= $(shell $(BUILD_ROOT)/doc/findMarksFiles method)

#Give a filename: $(DOC_DIR)/method/$(DOC_BASE).${file-rm-ext}.${class}.${methodType}.${index}.${methodName}
# F1:		${fileName}
# F2:		${class}
# F3:		${methodType}
# F4:		${index}
DOC_SUFFIX					= $(subst .,,$(suffix $(1)))
DOC_F1_OF_4					= $(basename $(basename $(basename $(basename $(1)))))
DOC_F2_OF_4					= $(call DOC_SUFFIX,$(basename $(basename $(basename $(1)))))
DOC_F3_OF_4					= $(call DOC_SUFFIX,$(basename $(basename $(1))))
DOC_F4_OF_4					= $(call DOC_SUFFIX,$(basename $(1)))


DOC_METHOD_SOURCE			= $(call DOC_F1_OF_4,$(1))
DOC_METHOD_CLASS			= $(call DOC_F2_OF_4,$(1))
DOC_METHOD_TYPE				= $(call DOC_F3_OF_4,$(1))
DOC_METHOD_METHOD			= $(call DOC_F4_OF_4,$(1))

doc: $(DOC_FILES)

docprint:
	@echo "DOC_FILES		$(DOC_FILES)"
	@echo "DOC_PACKAGE		$(DOC_PACKAGE)"
	@echo "DOC_CLASSES		$(DOC_CLASSES)"
	@echo "DOC_METHODS		$(DOC_METHODS)"
	@echo "DOC_CLASS_FILES	$(DOC_CLASS_FILES)"
	@echo "DOC_METHOD_FILES	$(DOC_METHOD_FILES)"

$(DOC_DIR)/package/%.md: Note_BuildPackage_% $(DOC_DIR)/package.Dir $(DOC_CLASS_FILES) $(wildcard docs/package)
	@echo "Building Package $* Document"
	$(DOC_PACKAGE_TOOL) $* > $@

$(DOC_DIR)/class/$(DOC_BASE).%.md: Note_BuildClass_% $(DOC_DIR)/class.Dir $(DOC_CLASS_FILES) $(wildcard docs/%)
	@echo "Building Class $* Document"
	@$(DOC_CLASS_TOOL) $(DOC_BASE) $(basename $*).h $(subst .,,$(suffix $*)) > $@

$(DOC_DIR)/function/$(DOC_BASE).%.md: Note_BuildFunc_% $(DOC_DIR)/function.Dir $(DOC_CLASS_FILES) $(wildcard docs/%)
	@echo "Building Function $* Documentation"
	@$(DOC_FUNCTION_TOOL) $(DOC_BASE) $(basename $*).h $(call DOC_F4_OF_4,$*) > $@

$(DOC_DIR)/method/$(DOC_BASE).%.md: Note_BuildMethod_% $(DOC_DIR)/method.Dir $(DOC_METHOD_FILES) $(wildcard docs/%)
	@echo "Building Method $* Document"
	@$(DOC_METHOD_TOOL) $(DOC_BASE) $(call DOC_METHOD_SOURCE,$*).h $(call DOC_METHOD_TYPE,$*) $(call DOC_METHOD_CLASS,$*) $(call DOC_METHOD_METHOD,$*) > $@

