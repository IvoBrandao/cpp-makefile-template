
CFG_PRJ_DIR  = $(shell pwd)
CFG_INC_DIR  = $(shell pwd)/include
CFG_SRC_DIR  = $(shell pwd)/source
CFG_RES_DIR  = $(shell pwd)/resources
CFG_TST_DIR  = $(shell pwd)/test

CFG_BLD_OUT_DIR = build
CFG_EXT_OUT_DIR = externals
CFG_OBJ_OUT_DIR = Objects
CFG_BIN_OUT_DIR = binaries
CFG_LIB_OUT_DIR = libraries
CFG_RES_OUT_DIR = resources
CFG_INS_OUT_DIR = install

CFG_EXE_NAME = app
CFG_CXX_COMP = g++

#-----------------------------------------------------------
# C preprocessor settings
CPPFLAGS = -MMD -MP

# C++ compiler flags
CXXFLAGS = -std=c++2b

# Linker settings
LDFLAGS = -Wall -Wpedantic -Wextra

# Libraries to link
LDLIBS = -lpthread -lm

#-----------------------------------------------------------
# Target OS detection
ifeq ($(OS),Windows_NT) # OS is a preexisting environment variable on Windows
	OS = windows
	EXE_NAME = $(CFG_EXE_NAME).exe

	# Link libgcc and libstdc++ statically on Windows
	LDFLAGS += -static-libgcc -static-libstdc++
	OS_INCLUDES +=
	LDLIBS +=
	CXXFLAGS += -m64
	CPPFLAGS +=
else
	UNAME := $(shell uname -s)
	ifeq ($(UNAME),Darwin)
		OS = macos
		EXE_NAME = $(CFG_EXE_NAME)

		# Mac-specific settings
		OS_INCLUDES +=
		LDFLAGS +=
		LDLIBS +=
		CXXFLAGS +=
		CPPFLAGS +=

	else ifeq ($(UNAME),Linux)
		OS = linux
		EXE_NAME = $(CFG_EXE_NAME)
		# Linux-specific settings
		OS_INCLUDES +=
		LDFLAGS += 
		LDLIBS +=
		CXXFLAGS +=
		CPPFLAGS +=

	else
    	$(error OS not supported by this Makefile)
	endif
endif

# ----------------------------------------------------------
# Debug (default) and release modes settings
ifeq ($(release),1)
	BLD_DIR := $(BLD_DIR)/release
	CXXFLAGS += -O3
	CPPFLAGS += -DNDEBUG
else
	BLD_DIR := $(BLD_DIR)/debug
	CXXFLAGS += -O0 -g
endif

# ----------------------------------------------------------
CPP_BLD_DIR = $(CFG_PRJ_DIR)/$(CFG_BLD_OUT_DIR)/$(OS)
CPP_BIN_DIR = $(CPP_BLD_DIR)/$(CFG_BIN_OUT_DIR)
CPP_OBJ_DIR = $(CPP_BLD_DIR)/$(CFG_OBJ_OUT_DIR)
CPP_LIB_DIR = $(CPP_BLD_DIR)/$(CFG_LIB_OUT_DIR)
CPP_INS_DIR = $(CPP_BLD_DIR)/$(CFG_INS_OUT_DIR)
CPP_EXT_DIR = $(CPP_BLD_DIR)/$(CFG_EXT_OUT_DIR)

SRCS := $(sort $(shell find $(CFG_SRC_DIR) -name '*.cpp'))
INCS := -I$(CFG_INC_DIR) 
OBJS := $(SRCS:$(CFG_SRC_DIR)/%.cpp=$(CPP_OBJ_DIR)/%.o)
DEPS := $(OBJS:.o=.d)
CPPFLAGS += $(INCS)

# --------------------------------------------------------------------------------
.PHONY: all
all: setup compile link
	@echo "All done."
	@echo " "

# --------------------------------------------------------------------------------
.PHONY: setup
setup:
	@echo "Setting up..."
	@echo "BLD: $(CPP_BLD_DIR)"
	@mkdir -p $(CPP_BLD_DIR)
	@echo "BIN: $(CPP_BIN_DIR)"
	@mkdir -p $(CPP_BIN_DIR)
	@echo "OBJ: $(CPP_OBJ_DIR)"
	@mkdir -p $(CPP_OBJ_DIR)
	@echo "LIB: $(CPP_LIB_DIR)"
	@mkdir -p $(CPP_LIB_DIR)
	@echo "INS: $(CPP_INS_DIR)"
	@mkdir -p $(CPP_INS_DIR)
	@echo "EXT: $(CPP_EXT_DIR)"
	@mkdir -p $(CPP_EXT_DIR)
	@echo "Setting up done."
	@echo " "

# --------------------------------------------------------------------------------
.PHONY: compile
compile: setup 
	@echo "Compiling..."
	@echo "CPPFLAGS: $(CPPFLAGS)"
	@$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $(SRCS) -o $(OBJS)
	@echo "Compiling done."
	@echo " "

# --------------------------------------------------------------------------------
.PHONY: link
link: compile
	@echo "Linking..."
	@$(CXX) $(LDFLAGS) $(OBJS) $(LDLIBS) -o $(CPP_BIN_DIR)/$(EXE_NAME)
	@echo "Linking done."
	@echo " "

# --------------------------------------------------------------------------------
.PHONY: run
run: all
	@echo "Starting program: $(CPP_BIN_DIR)/$(EXE_NAME)"
	@cd $(CPP_BIN_DIR); ./$(EXE_NAME)

# --------------------------------------------------------------------------------
.PHONY: clean
clean:
	@echo "Cleaning..."
	@rm -rf $(CPP_BLD_DIR)
	@echo "Cleaning done."

# --------------------------------------------------------------------------------
.PHONY: install
install: all setup_resources
	@echo "Packaging program to $(CPP_INS_DIR)"
	@mkdir -p $(CPP_INS_DIR); cp -r $(CPP_BIN_DIR)/. $(CPP_INS_DIR)
	@echo "Packaging done."
	@echo " "

# --------------------------------------------------------------------------------
.PHONY: setup_resources
setup_resources:
	@echo "Copying assets from $(CFG_RES_DIR) and $(CPP_RES_DIR) to $(CPP_BIN_DIR)"
	@mkdir -p $(CPP_BIN_DIR)
	@cp -r $(CFG_RES_DIR)/. $(CPP_BIN_DIR)/
	@cp -r $(CFG_RES_DIR)/. $(CPP_BIN_DIR)/ 2> /dev/null || :	
	@echo "Copying done."
	@echo " "

# --------------------------------------------------------------------------------
.PHONY: help
help: 
	@echo " "
	@echo "Usage: make [target] [options]"
	@echo " "
	@echo "Targets:"
	@echo "  all       - (default) compiles and links the program"
	@echo "  setup     - creates the build directory structure"
	@echo "  compile   - compiles the source files"
	@echo "  link      - links the object files"
	@echo "  run       - runs the program"
	@echo "  clean     - removes the build directory"
	@echo "  install   - packages the program to the install directory"
	@echo "  help      - prints this help message"
	@echo " "
	@echo "Options:"
	@echo "  release=1 - compiles the program in release mode"
	@echo " "
	@echo "Examples:"
	@echo "  make"
	@echo "  make release=1"
	@echo "  make clean"
	@echo "  make install"
	@echo " "





