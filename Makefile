# --------------------------------------------------------------------------------
# Configuration
# --------------------------------------------------------------------------------
CFG_PRJ_DIR = $(shell pwd)
# Configures the Google Test directory URL
CFG_GTEST_DIR_URL = https://github.com/google/googletest.git
# Configures the Doxygen configuration file
CFG_DOXYFILE = $(CFG_PRJ_DIR)/Doxyfile
# Configures the build directory location
CFG_BLD_OUT_DIR = build
# Configures the directory for external projects
CFG_EXT_OUT_DIR = externals
# Configures the output directories for objects
CFG_OBJ_OUT_DIR = objects
# Configures the output directories for binaries
CFG_BIN_OUT_DIR = binaries
# Configures the output directories for libraries
CFG_LIB_OUT_DIR = libraries
# Configures the output directories for resources
CFG_RES_OUT_DIR = resources
# Configures the output directories where the installation will happen
CFG_INS_OUT_DIR = install
# Configures the test directory
CFG_TST_DIR = tests
# Configures the executable name
CFG_EXE_NAME = app
# Configures the test executable prefix
CFG_TST_EXE_PREFIX = $(CFG_EXE_NAME)_test_
# Configures the compiler
CFG_CXX_COMP = g++
# Configures the preprocessor flags
CFG_CC_COMP = gcc

# Configures the compiler flags
# -MMD: generate dependencies
# -MP: add phony target for each dependency
CFG_CPPFLAGS = -MMD -MP

# Configures the compiler flags for C++ standard (C++2b is the default standard)
CFG_CXXFLAGS = -std=c++2b

# Configures the linker flags (Wall - enable all warnings, Wpedantic - enable pedantic warnings, Wextra - enable extra warnings)
CFG_LDFLAGS = -Wall -Wpedantic -Wextra

# Configures the linker flags for the libraries
CFG_LDLIBS =

# Configures the source files
CFG_SRC_FILES = *.cpp

# Configures the includes for the OS (define as plain paths)
CFG_OS_INCLUDES =

# Configures the release and debug flags
# Release: optimize for speed, disable assertions, native architecture optimization, etc.
CFG_RELEASE_FLAGS = -O3 -DNDEBUG -march=native -ftree-vectorize -msse2 -mfpmath=sse -ftree-vectorizer-verbose=5 -fopenmp -fopenacc -fopenmp-simd
# Debug: no optimization, include debug symbols (simplified)
CFG_DEBUG_FLAGS = -O0 -g

# Code coverage flags (for gcov)
CFG_COVERAGE_FLAGS = --coverage

# --------------------------------------------------------------------------------
# Project settings
# --------------------------------------------------------------------------------
CFG_INC_DIR = $(CFG_PRJ_DIR)/include
CFG_SRC_DIR = $(CFG_PRJ_DIR)/source
CFG_RES_DIR = $(CFG_PRJ_DIR)/resources

CFG_COMP = $(CFG_CXX_COMP)
CPPFLAGS += $(CFG_CPPFLAGS)
CXXFLAGS += $(CFG_CXXFLAGS)
LDFLAGS += $(CFG_LDFLAGS)
LDLIBS += $(CFG_LDLIBS)
COMPILER = $(CFG_COMP)

# Target OS detection
ifeq ($(OS),Windows_NT)
	OS = windows
	EXE_NAME = $(CFG_EXE_NAME).exe
	TST_EXE_EXT = .exe
	# Windows specific settings (static linking for GCC on Windows)
	LDFLAGS += -static-libgcc -static-libstdc++
	OS_INCLUDES :=
	LDLIBS +=
	# 64-bit build settings
	CXXFLAGS += -m64
	CPPFLAGS +=
else
	UNAME := $(shell uname -s)
	ifeq ($(UNAME),Darwin)
		OS = macos
		EXE_NAME = $(CFG_EXE_NAME)
		TST_EXE_EXT =
		OS_INCLUDES := /usr/local/include
		LDFLAGS += -L/usr/local/lib
		# (pthread - POSIX threads, m - math library)
		LDLIBS += -lpthread -lm
		CXXFLAGS +=
		CPPFLAGS +=
	else ifeq ($(UNAME),Linux)
		OS = linux
		EXE_NAME = $(CFG_EXE_NAME)
		TST_EXE_EXT =
		OS_INCLUDES := /usr/local/include
		LDFLAGS += -L/usr/local/lib -L/usr/lib
		# (pthread - POSIX threads, m - math library)
		LDLIBS += -lpthread -lm
		CXXFLAGS +=
		CPPFLAGS +=
	else
    	$(error OS not supported by this Makefile)
	endif
endif

# Build mode selection (default = Release)
# Use debug=1 to compile in debug mode; otherwise, default to release.
ifneq ($(debug),1)
	BLD_DIR = $(CFG_BLD_OUT_DIR)/release
	CXXFLAGS += $(CFG_RELEASE_FLAGS)
else
	BLD_DIR = $(CFG_BLD_OUT_DIR)/debug
	CXXFLAGS += $(CFG_DEBUG_FLAGS)
endif

# --------------------------------------------------------------------------------
# main app settings
# --------------------------------------------------------------------------------
CPP_BLD_DIR = $(CFG_PRJ_DIR)/$(CFG_BLD_OUT_DIR)/$(OS)
CPP_CLS_DIR = $(CFG_PRJ_DIR)/$(CFG_BLD_OUT_DIR)/$(OS)
CPP_BIN_DIR = $(CPP_BLD_DIR)/$(CFG_BIN_OUT_DIR)/app
CPP_OBJ_DIR = $(CPP_BLD_DIR)/$(CFG_OBJ_OUT_DIR)/app
CPP_LIB_DIR = $(CPP_BLD_DIR)/$(CFG_LIB_OUT_DIR)/app
CPP_INS_DIR = $(CPP_BLD_DIR)/$(CFG_INS_OUT_DIR)/app
CPP_EXT_DIR = $(CPP_BLD_DIR)/$(CFG_EXT_OUT_DIR)/app
CPP_BLD_DOC = $(CPP_BLD_DIR)/doc

SRCS := $(sort $(shell find $(CFG_SRC_DIR) -name $(CFG_SRC_FILES)))
# Build INCS using addprefix so that multiple OS_INCLUDES work properly.
INCS := -I$(CFG_INC_DIR) -I$(CFG_SRC_DIR) $(addprefix -I, $(OS_INCLUDES))
LIBS := -L$(CPP_LIB_DIR)
OBJS := $(SRCS:$(CFG_SRC_DIR)/%.cpp=$(CPP_OBJ_DIR)/%.o)
DEPS := $(OBJS:.o=.d)
CPPFLAGS += $(INCS)
LDFLAGS += $(LIBS)

# --------------------------------------------------------------------------------
# Test settings
# --------------------------------------------------------------------------------
# Define directories
TST_BLD_DIR := $(CFG_PRJ_DIR)/$(CFG_BLD_OUT_DIR)/$(OS)
TST_BIN_DIR := $(TST_BLD_DIR)/$(CFG_BIN_OUT_DIR)/tests
TST_OBJ_DIR := $(TST_BLD_DIR)/$(CFG_OBJ_OUT_DIR)/tests
TST_LIB_DIR := $(TST_BLD_DIR)/$(CFG_LIB_OUT_DIR)/tests
TST_INS_DIR := $(TST_BLD_DIR)/$(CFG_INS_OUT_DIR)/tests
TST_EXT_DIR := $(TST_BLD_DIR)/$(CFG_EXT_OUT_DIR)/tests
TST_SRC_DIR := $(CFG_PRJ_DIR)/$(CFG_TST_DIR)
TST_INC_DIR := $(TST_SRC_DIR)/include

# Directory for Google Test framework
GTEST_DIR := $(TST_EXT_DIR)/googletest
# Google Test include directory
GTEST_INCLUDE := $(GTEST_DIR)/googletest/include
# Google Test libraries
GTEST_LIB := $(GTEST_DIR)/build/lib/libgtest.a $(GTEST_DIR)/build/lib/libgtest_main.a
GMOCK_LIB := $(GTEST_DIR)/build/lib/libgmock.a $(GTEST_DIR)/build/lib/libgmock_main.a

# Source files and objects for tests
TST_SRCS := $(sort $(shell find $(TST_SRC_DIR) -name *.cpp))
TST_OBJS := $(TST_SRCS:$(TST_SRC_DIR)/%.cpp=$(TST_OBJ_DIR)/%.o) $(DEPS)
TST_DEPS := $(TST_OBJS:.o=.d)
TST_BINS := $(TST_SRCS:$(TST_SRC_DIR)/%.cpp=$(TST_BIN_DIR)/$(CFG_TST_EXE_PREFIX)%)

# remove the main object from the list of objects to link for tests
TST_OBJS += $(filter-out $(CPP_OBJ_DIR)/main.o, $(OBJS))

TST_INCS := -I$(TST_INC_DIR) -I$(CFG_INC_DIR)

# Compiler and linker flags for tests
TST_COMPILER := $(CFG_CXX_COMP)
TST_CPPFLAGS := -MMD -MP -I$(TST_INC_DIR) -I$(GTEST_INCLUDE) $(TST_INCS)
TST_CXXFLAGS := -std=c++2b -O0 -g
TST_LDFLAGS := -pthread -L$(TST_LIB_DIR)
TST_LDLIBS := $(GTEST_LIB) -lgtest -lgtest_main -lgmock -lgmock_main


# --------------------------------------------------------------------------------
# all Targets
# --------------------------------------------------------------------------------
.PHONY: all
all: resources build
	@echo "INFO: Build Successful"

# --------------------------------------------------------------------------------
# Setting up the project directories
# --------------------------------------------------------------------------------
.PHONY: setup_app
setup_app:
	@echo "INFO: Setting up the project."
	@echo "INFO: Create dir: $(CPP_BIN_DIR)"
	@mkdir -p $(CPP_BIN_DIR)
	@echo "INFO: Create dir: $(CPP_OBJ_DIR)"
	@mkdir -p $(CPP_OBJ_DIR)
	@echo "INFO: Create dir: $(CPP_LIB_DIR)"
	@mkdir -p $(CPP_LIB_DIR)
	@echo "INFO: Create dir: $(CPP_INS_DIR)"
	@mkdir -p $(CPP_INS_DIR)
	@echo "INFO: Create dir: $(CPP_EXT_DIR)"
	@mkdir -p $(CPP_EXT_DIR)
	@echo "INFO: Setup Successful"
	@echo "INFO: Setting up build directory permissions"
	@chmod -R u+w $(CFG_BLD_OUT_DIR)
	@echo "INFO: Permissions set"

# --------------------------------------------------------------------------------
# Compiling the source files (now handled by pattern rules)
# --------------------------------------------------------------------------------

.PHONY: compile
compile:
	@echo "INFO: Compling Sources Files"
	@mkdir -p $(CPP_OBJ_DIR)
	@$(foreach src,$(SRCS), \
		echo "INFO: Compiling: $(abspath $(src))"; \
		$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $(src) -o $(CPP_OBJ_DIR)/$(notdir $(src:.cpp=.o)); \
	)
	@echo "INFO: Compilation Successful"
# --------------------------------------------------------------------------------
# Linking the object files
# --------------------------------------------------------------------------------
.PHONY: link
link: compile
	@echo "INFO: Linking object files to create executable"
	@$(foreach obj,$(OBJS), \
		echo "INFO: Linking: $(abspath $(obj))"; \
	)
	@$(CXX) $(LDFLAGS) $(OBJS) $(LDLIBS) -o $(CPP_BIN_DIR)/$(EXE_NAME)
	@echo "INFO: Linking Successful"

# --------------------------------------------------------------------------------
# Build the program
# --------------------------------------------------------------------------------
.PHONY: build
build: setup_app link
	@echo "INFO: Build Successful"

# --------------------------------------------------------------------------------
# Running the program
# --------------------------------------------------------------------------------
.PHONY: run
run: all
	@echo "INFO: Executing program: $(CPP_BIN_DIR)/$(EXE_NAME)"
	@cd $(CPP_BIN_DIR); ./$(EXE_NAME); cd $(CFG_PRJ_DIR)
	@echo "\nINFO: Program finished"

# --------------------------------------------------------------------------------
# Cleaning up the build directory
# --------------------------------------------------------------------------------
.PHONY: clean
clean:
	@echo "INFO: Cleaning up build directory $(CPP_CLS_DIR)"
	@rm -rf $(CPP_CLS_DIR)
	@if [ ! -d "$(CPP_CLS_DIR)" ]; then \
		echo "INFO: Clean up successful"; \
	else \
		echo "ERROR: Clean up failed"; \
	fi

# --------------------------------------------------------------------------------
# Packaging the program to the install directory
# --------------------------------------------------------------------------------
.PHONY: install
install: all resources
	@echo "INFO: Packaging program to $(CPP_INS_DIR)"
	@mkdir -p $(CPP_INS_DIR); cp -r $(CPP_BIN_DIR)/. $(CPP_INS_DIR)
	@echo "INFO: Packaging done."

# --------------------------------------------------------------------------------
# Copying resources to the binary directory
# --------------------------------------------------------------------------------
.PHONY: resources
resources:
	@echo "INFO: Copying resources from $(CFG_RES_DIR) to $(CPP_BIN_DIR)"
	@mkdir -p $(CPP_BIN_DIR)
	@cp -r $(CFG_RES_DIR)/. $(CPP_BIN_DIR)/
	@cp -r $(CFG_RES_DIR)/. $(CPP_BIN_DIR)/ 2> /dev/null || :
	@echo "INFO: Resources copied."

# --------------------------------------------------------------------------------
# Formatting files
# --------------------------------------------------------------------------------
.PHONY: format
format:
	@echo "INFO: Formatting source files"
	@if [ ! -f ".clang-format" ]; then \
		echo "INFO: Creating .clang-format file"; \
		clang-format -style=google -dump-config > .clang-format; \
		echo "INFO: .clang-format file created"; \
	fi
	@if [ -d "$(CFG_SRC_DIR)" ]; then \
		clang-format -i $(CFG_SRC_DIR)/*.cpp; \
	fi
	@if [ -d "$(CFG_INC_DIR)" ]; then \
		clang-format -i $(CFG_INC_DIR)/*.hpp; \
	fi
	@if [ -d "$(CFG_TST_DIR)" ]; then \
		clang-format -i $(CFG_TST_DIR)/*.cpp; \
	fi
	@if [ -d "$(CFG_TST_DIR)/include" ]; then \
		clang-format -i $(CFG_TST_DIR)/include/*.hpp; \
	fi
	@echo "INFO: Formatting done."

# --------------------------------------------------------------------------------
# Test setup framework
# --------------------------------------------------------------------------------
.PHONY: test_setup
test_setup:
	@echo "INFO: Setting up test project."
	@mkdir -p $(TST_BIN_DIR) $(TST_OBJ_DIR) $(TST_LIB_DIR) $(TST_INS_DIR) $(TST_EXT_DIR)
	@echo "INFO: Setup Successful"
	@echo "INFO: Setting up build directory permissions"
	@chmod -R u+w $(TST_BLD_DIR)
	@echo "INFO: Permissions set"
	@echo "INFO: Project Details"
	@echo "INFO: Host system   : $(OS)"
	@echo "INFO: Test project setup complete"
	@echo "INFO: Setting up Google Test framework"
	@if [ ! -d "$(GTEST_DIR)" ]; then \
		echo "INFO: Cloning Google Test"; \
		git clone $(CFG_GTEST_DIR_URL) $(GTEST_DIR)  > /dev/null 2>&1; \
	else \
		echo "INFO: Google Test already exists"; \
	fi
	@echo "INFO: Building Google Test"
	@mkdir -p $(GTEST_DIR)/build
	@cd $(GTEST_DIR)/build && cmake .. > /dev/null 2>&1 && make > /dev/null 2>&1;
	@echo "INFO: Copying Google Test/Google Mock libraries"
	@cp $(GTEST_LIB) $(TST_LIB_DIR)
	@cp $(GMOCK_LIB) $(TST_LIB_DIR)
	@echo "INFO: Google Test/Google Mock libraries copied"
	@echo "INFO: Google Test setup complete"

# --------------------------------------------------------------------------------
# Test compile
# --------------------------------------------------------------------------------
.PHONY: test_compile
test_compile: test_setup $(TST_OBJS)
	@echo "INFO: Test Compilation Successful"

$(TST_OBJ_DIR)/%.o: $(TST_SRC_DIR)/%.cpp
	@echo "INFO: Compiling $<"
	@mkdir -p $(dir $@)
	$(TST_COMPILER) $(TST_CPPFLAGS) $(TST_CXXFLAGS) -c $< -o $@

-include $(DEPS)

# --------------------------------------------------------------------------------
# Test link
# --------------------------------------------------------------------------------
.PHONY: test_link
test_link: test_compile $(TST_BINS)
	@echo "INFO: Test Linking Successful"

$(TST_BIN_DIR)/$(CFG_TST_EXE_PREFIX)%: $(TST_OBJ_DIR)/%.o
	@echo "INFO: Linking $@"
	@mkdir -p $(dir $@)
	$(TST_COMPILER) $< $(TST_LDFLAGS) $(TST_LDLIBS) $(TST_OBJS) -o $@

# --------------------------------------------------------------------------------
# Test build
# --------------------------------------------------------------------------------
.PHONY: test_build
test_build: test_setup test_compile test_link
	@echo "INFO: Test Build Successful"

# --------------------------------------------------------------------------------
# Test run
# --------------------------------------------------------------------------------
.PHONY: test_run
test_run: test_build
	@echo "INFO: Running all tests"
	@for test_bin in $(TST_BINS); do \
		echo "INFO: Running $$test_bin"; \
		if ! $$test_bin; then \
			echo "ERROR: Test $$test_bin failed"; \
			exit 1; \
		fi; \
	done
	@echo "INFO: All tests Executed"

# --------------------------------------------------------------------------------
# Test build and run
# --------------------------------------------------------------------------------
.PHONY: test
test: resources build test_build
	@echo "INFO: Test Executed"

# --------------------------------------------------------------------------------
# Test clean
# --------------------------------------------------------------------------------
.PHONY: test_clean
test_clean:
	@echo "INFO: Cleaning up test build directories"
	@rm -rf $(TST_BIN_DIR) $(TST_OBJ_DIR) $(TST_LIB_DIR) $(TST_INS_DIR) $(TST_EXT_DIR)
	@echo "INFO: Test Clean complete"

# --------------------------------------------------------------------------------
# Documentation setup
# --------------------------------------------------------------------------------
.PHONY: setup_doc
setup_doc:
	@echo "Generating default Doxygen configuration..."
	@doxygen -g $(DOXYFILE)
	@echo "Default Doxygen configuration generated as $(DOXYFILE)"

# --------------------------------------------------------------------------------
# Documentation
# --------------------------------------------------------------------------------
.PHONY: doc
doc:
	@echo "Generating documentation..."
	@mkdir -p $(CPP_BLD_DOC)
	@echo "Documentation will be generated in $(CPP_BLD_DOC)"
	@echo "Using Doxygen configuration: $(CFG_DOXYFILE)"
	@cd $(CPP_BLD_DOC) && doxygen $(DOXYFILE) . > /dev/null 2>&1
	@echo "Documentation generated in $(CPP_BLD_DOC)/html/index.html"

.PHONY: clean_doc
clean_doc:
	@echo "Cleaning up documentation..."
	@rm -rf $(CPP_BLD_DOC)
	@echo "Documentation cleaned up."

# --------------------------------------------------------------------------------
# Additional Targets: Valgrind and Coverage
# --------------------------------------------------------------------------------
.PHONY: valgrind
valgrind: build
	@echo "INFO: Running executable under Valgrind..."
	@cd $(CPP_BIN_DIR) && valgrind --leak-check=full --track-origins=yes ./$(EXE_NAME)
	@echo "INFO: Valgrind analysis complete"

.PHONY: coverage
coverage:
	@echo "INFO: Cleaning build for coverage..."
	@$(MAKE) clean
	@echo "INFO: Building project with code coverage flags"
	$(MAKE) CXXFLAGS="$(CXXFLAGS) $(CFG_COVERAGE_FLAGS)" LDFLAGS="$(LDFLAGS) $(CFG_COVERAGE_FLAGS)" build
	@echo "INFO: Running executable to generate coverage data..."
	@cd $(CPP_BIN_DIR) && ./$(EXE_NAME)
	@echo "INFO: Running gcov on source files..."
	@cd $(CFG_SRC_DIR) && gcov $(CFG_SRC_FILES)
	@echo "INFO: Code coverage analysis complete. (Check the generated .gcov files for details)"

# --------------------------------------------------------------------------------
# Help
# --------------------------------------------------------------------------------
.PHONY: help
help:
	@echo " "
	@echo "Usage: make [target] [options]"
	@echo " "
	@echo "Application Targets:"
	@echo "  all          - (default) compiles and links the program and tests"
	@echo "  setup_app    - creates the build directory structure"
	@echo "  compile      - compiles the source files"
	@echo "  link         - links the object files"
	@echo "  build        - compiles and links the program"
	@echo "  run          - runs the program"
	@echo "  clean        - removes the build directory"
	@echo "  install      - packages the program to the install directory"
	@echo "  resources    - copies the resources to the binary directory"
	@echo "  format       - formats the source files"
	@echo "  doc          - generates the documentation"
	@echo "  setup_doc    - generates the default Doxygen configuration"
	@echo "  clean_doc    - removes the documentation"
	@echo " "
	@echo "Test Targets:"
	@echo "  test_setup   - sets up the test project"
	@echo "  test_compile - compiles the test source files"
	@echo "  test_link    - links the test object files"
	@echo "  test_clean   - removes the test build directories"
	@echo "  test_run     - runs all the tests"
	@echo "  test         - builds and runs the tests"
	@echo " "
	@echo "Additional Targets:"
	@echo "  valgrind     - runs the executable under valgrind for memory checking"
	@echo "  coverage     - builds with gcov support, runs the executable, and generates coverage data"
	@echo " "
	@echo "Options:"
	@echo "  debug=1      - compiles the program in debug mode (default is release mode)"
	@echo " "
	@echo "Examples:"
	@echo "  make                "
	@echo "  make help           "
	@echo "  make all            "
	@echo "  make debug=1        "
	@echo "  make compile        "
	@echo "  make link           "
	@echo "  make build          "
	@echo "  make clean          "
	@echo "  make install        "
	@echo "  make run            "
	@echo "  make resources      "
	@echo "  make format         "
	@echo "  make test_setup     "
	@echo "  make test_compile   "
	@echo "  make test_link      "
	@echo "  make test_clean     "
	@echo "  make test           "
	@echo "  make valgrind       "
	@echo "  make coverage       "
	@echo " "
