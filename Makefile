# --------------------------------------------------------------------------------
# constants
# --------------------------------------------------------------------------------
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[0;33m
BLUE = \033[0;34m
MAGENTA = \033[0;35m
ORANGE = \033[0;38;5;166m
RESET = \033[0m
# --------------------------------------------------------------------------------
# Configuration
# --------------------------------------------------------------------------------
CFG_BLD_OUT_DIR = build
CFG_EXT_OUT_DIR = externals
CFG_OBJ_OUT_DIR = Objects
CFG_BIN_OUT_DIR = binaries
CFG_LIB_OUT_DIR = libraries
CFG_RES_OUT_DIR = resources
CFG_INS_OUT_DIR = install
CFG_EXE_NAME = app
CFG_CXX_COMP = g++
CFG_CC_COMP = gcc
CFG_CPPFLAGS = -MMD -MP
CFG_CXXFLAGS = -std=c++2b
CFG_LDFLAGS = -Wall -Wpedantic -Wextra 
CFG_LDLIBS = -lpthread -lm
CFG_SRC_FILES = *.cpp
CFG_OS_INCLUDES =
CFG_RELEASE_FLAGS = -O3 -DNDEBUG
CFG_DEBUG_FLAGS = -O0 -g

# --------------------------------------------------------------------------------
# Project settings
# --------------------------------------------------------------------------------
CFG_PRJ_DIR = $(shell pwd)
CFG_INC_DIR = $(CFG_PRJ_DIR)/include
CFG_SRC_DIR = $(CFG_PRJ_DIR)/source
CFG_RES_DIR = $(CFG_PRJ_DIR)/resources
CFG_TST_DIR = $(CFG_PRJ_DIR)/test
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
		OS_INCLUDES +=
		LDFLAGS +=
		LDLIBS +=
		CXXFLAGS +=
		CPPFLAGS +=
	else ifeq ($(UNAME),Linux)
		OS = linux
		EXE_NAME = $(CFG_EXE_NAME)
		OS_INCLUDES +=
		LDFLAGS += 
		LDLIBS +=
		CXXFLAGS +=
		CPPFLAGS +=
	else
    	$(error OS not supported by this Makefile)
	endif
endif

# Debug (default) and release modes settings
ifeq ($(release),1)
	BLD_DIR := $(BLD_DIR)/release
	CXXFLAGS += $(CFG_RELEASE_FLAGS)
else
	BLD_DIR := $(BLD_DIR)/debug
	CXXFLAGS += $(CFG_DEBUG_FLAGS)
endif

# ----------------------------------------------------------
CPP_BLD_DIR = $(CFG_PRJ_DIR)/$(CFG_BLD_OUT_DIR)/$(OS)
CPP_CLS_DIR = $(CFG_PRJ_DIR)/$(CFG_BLD_OUT_DIR)
CPP_BIN_DIR = $(CPP_BLD_DIR)/$(CFG_BIN_OUT_DIR)
CPP_OBJ_DIR = $(CPP_BLD_DIR)/$(CFG_OBJ_OUT_DIR)
CPP_LIB_DIR = $(CPP_BLD_DIR)/$(CFG_LIB_OUT_DIR)
CPP_INS_DIR = $(CPP_BLD_DIR)/$(CFG_INS_OUT_DIR)
CPP_EXT_DIR = $(CPP_BLD_DIR)/$(CFG_EXT_OUT_DIR)
SRCS := $(sort $(shell find $(CFG_SRC_DIR) -name $(CFG_SRC_FILES)))
INCS := -I$(CFG_INC_DIR) -I$(CFG_SRC_DIR) $(CFG_OS_INCLUDES)
OBJS := $(SRCS:$(CFG_SRC_DIR)/%.cpp=$(CPP_OBJ_DIR)/%.o)
DEPS := $(OBJS:.o=.d)
CPPFLAGS += $(INCS)

# --------------------------------------------------------------------------------
.PHONY: all
all: setup_project compile link setup_resources
	@echo "$(BLUE) INFO:$(RESET) Build Successful"
	@echo ""

# --------------------------------------------------------------------------------
.PHONY: setup_project
setup_project:
	@echo "$(BLUE) INFO:$(RESET) Setting up the project."
	@echo "$(BLUE) INFO:$(RESET) Create dir: $(CPP_BIN_DIR)"
	@mkdir -p $(CPP_BIN_DIR)
	@echo "$(BLUE) INFO:$(RESET) Create dir: $(CPP_OBJ_DIR)"
	@mkdir -p $(CPP_OBJ_DIR)
	@echo "$(BLUE) INFO:$(RESET) Create dir: $(CPP_LIB_DIR)"
	@mkdir -p $(CPP_LIB_DIR)
	@echo "$(BLUE) INFO:$(RESET) Create dir: $(CPP_INS_DIR)"
	@mkdir -p $(CPP_INS_DIR)
	@echo "$(BLUE) INFO:$(RESET) Create dir: $(CPP_EXT_DIR)"
	@mkdir -p $(CPP_EXT_DIR)
	@echo "$(BLUE) INFO:$(RESET) Setup Successful"
	@echo "$(BLUE) INFO:$(RESET) Project Details" 
	@echo "$(BLUE) INFO:$(RESET) Compiler flags: $(CPPFLAGS) $(CXXFLAGS)"
	@echo "$(BLUE) INFO:$(RESET) Linker flags  : $(LDFLAGS)"
	@echo "$(BLUE) INFO:$(RESET) Link Libraries: $(LDLIBS)"
	@echo "$(BLUE) INFO:$(RESET) project name  : $(EXE_NAME)"
	@echo "$(BLUE) INFO:$(RESET) host system   : $(OS)"
	
# --------------------------------------------------------------------------------
.PHONY: compile
compile: setup_project 
	@echo "$(BLUE) INFO:$(RESET) Compling Sources Files"
	@$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $(SRCS) -o $(OBJS)
	@echo "$(BLUE) INFO:$(RESET) Compilation Successful"

# --------------------------------------------------------------------------------
.PHONY: link
link: compile
	@echo "$(BLUE) INFO:$(RESET) Linking object to executable"
	@$(CXX) $(LDFLAGS) $(OBJS) $(LDLIBS) -o $(CPP_BIN_DIR)/$(EXE_NAME)
	@echo "$(BLUE) INFO:$(RESET) Linking Successful"

# --------------------------------------------------------------------------------
.PHONY: run
run: all
	@echo "$(BLUE) INFO:$(RESET) Executing program: $(CPP_BIN_DIR)/$(EXE_NAME)"
	@cd $(CPP_BIN_DIR); ./$(EXE_NAME); cd $(CFG_PRJ_DIR)
	@echo "$(BLUE) INFO:$(RESET) Program finished"

# --------------------------------------------------------------------------------
.PHONY: clean
clean:
	@echo "$(BLUE) INFO:$(RESET) Try to clean up build directory $(CPP_CLS_DIR)"

	@if [ "$(shell dirname $(CPP_CLS_DIR))" = "$(CFG_PRJ_DIR)" ]; then \
		echo "$(BLUE) INFO:$(RESET) Removing build directory $(CPP_CLS_DIR)"; \
		rm -rf $(CPP_CLS_DIR); \
		echo "$(BLUE) INFO:$(RESET) Cleaning done."; \
	else \
		echo "$(RED) ERROR:$(RESET) Invalid build directory specified: $(CPP_CLS_DIR)"; \
	fi

# --------------------------------------------------------------------------------
.PHONY: install
install: all setup_resources
	@echo "$(BLUE) INFO:$(RESET) Packaging program to $(CPP_INS_DIR)"
	@mkdir -p $(CPP_INS_DIR); cp -r $(CPP_BIN_DIR)/. $(CPP_INS_DIR)
	@echo "$(BLUE) INFO:$(RESET) Packaging done."

# --------------------------------------------------------------------------------
.PHONY: setup_resources
setup_resources:
	@echo "$(BLUE) INFO:$(RESET) Copying resources from $(CFG_RES_DIR) to $(CPP_BIN_DIR)"
	@mkdir -p $(CPP_BIN_DIR)
	@cp -r $(CFG_RES_DIR)/. $(CPP_BIN_DIR)/
	@cp -r $(CFG_RES_DIR)/. $(CPP_BIN_DIR)/ 2> /dev/null || :	
	@echo "$(BLUE) INFO:$(RESET) Resources copied."

# --------------------------------------------------------------------------------
.PHONY: help
help: 
	@echo " "
	@echo "Usage: $(MAGENTA)make$(RESET) $(GREEN)[target]$(RESET) $(YELLOW)[options]$(RESET)"
	@echo " "
	@echo "Targets:"
	@echo "  $(GREEN)all     $(RESET)- (default) compiles and links the program"
	@echo "  $(GREEN)setup   $(RESET)- creates the build directory structure"
	@echo "  $(GREEN)compile $(RESET)- compiles the source files"
	@echo "  $(GREEN)link    $(RESET)- links the object files"
	@echo "  $(GREEN)run     $(RESET)- runs the program"
	@echo "  $(GREEN)clean   $(RESET)- removes the build directory"
	@echo "  $(GREEN)install $(RESET)- packages the program to the install directory"
	@echo "  $(GREEN)help    $(RESET)- prints this help message"
	@echo " "
	@echo "Options:"
	@echo "  $(YELLOW)release=1 $(RESET) - compiles the program in release mode"
	@echo " "
	@echo "Examples:"
	@echo " $(MAGENTA)make $(RESET)"
	@echo " $(MAGENTA)make $(RESET)$(GREEN)all       $(RESET)"
	@echo " $(MAGENTA)make $(RESET)$(GREEN)release=1 $(RESET)"
	@echo " $(MAGENTA)make $(RESET)$(GREEN)clean     $(RESET)"
	@echo " $(MAGENTA)make $(RESET)$(GREEN)install   $(RESET)"
	@echo " $(MAGENTA)make $(RESET)$(GREEN)help      $(RESET)"
	@echo " $(MAGENTA)make $(RESET)$(GREEN)run       $(RESET)"
	@echo " $(MAGENTA)make $(RESET)$(GREEN)setup     $(RESET)"
	@echo " "

# --------------------------------------------------------------------------------