# Cross platform CPP Make file template

This is a C++ project template with a Makefile to automate the build process. It provides a convenient structure to organize C++ projects and supports both debug and release modes. It it usefull for small prototype projects.

## Prerequisites

- C++ compiler (e.g., g++)
- Make (build tool)

## Getting Started

1. Clone or download this repository to your local machine.
2. Navigate to the project directory.

## Project Structure

The project has the following directory structure:

- `include/`: Place your header files here.
- `source/`: Place your C++ source files here.
- `resources/`: Place any resource files (e.g., images, data files) here.
- `test/`: Optional directory for test files.
- `build/`: This directory will be created by the Makefile and contains the build artifacts.

## How to Use

To build and run the project, open a terminal and navigate to the project directory. Use the following commands:

- To print the help for the command available use the following command:
    ```bash
    make help
    ```
    
- To build the project in release mode (with optimizations and without debug symbols):
    ```bash
    make release=1
    ```

- To run the compiled executable:
    ```bash
    make run
    ```
- To clean the build artifacts:
    ```bash
    make clean
    ```
- Installing the Program.
To package the program for installation, use the following command:

    ```bash
    make install
    ```

This will create an install directory in the project folder containing the compiled executable and any resource files. You can then distribute this directory as needed.

## Configuration

By default, the project uses g++ as the C++ compiler. If you wish to use a different compiler, modify the CFG_CXX_COMP variable in the Makefile. The project detects the operating system automatically and sets appropriate flags. If you encounter issues with unsupported OSes, you may need to modify the OS-specific settings in the Makefile.

There are other configuration Variables:

* __CFG_PRJ_DIR__: The project directory.
* __CFG_INC_DIR__: The directory containing header files.
* __CFG_SRC_DIR__: The directory containing source files.
* __CFG_RES_DIR__: The directory containing resource files.
* __CFG_TST_DIR__: The directory containing test files.
* __CFG_BLD_OUT_DIR__: The build output directory.
* __CFG_EXT_OUT_DIR__: The external output directory.
* __CFG_OBJ_OUT_DIR__: The object output directory.
* __CFG_BIN_OUT_DIR__: The binary output directory.
* __CFG_LIB_OUT_DIR__: The library output directory.
* __CFG_RES_OUT_DIR__: The resource output directory.
* __CFG_INS_OUT_DIR__: The install output directory.
* __CFG_EXE_NAME__: The name of the executable file.
* __CFG_CXX_COMP__: The C++ compiler to use.

## Compiler and Linker Settings:

* __CPPFLAGS__: C preprocessor flags, including -MMD and -MP for dependency tracking.
* __CXXFLAGS__: C++ compiler flags, including the C++ version to use (-std=c++2b) and optimization level (-O3 for release, -O0 -g for debug).
* __LDFLAGS__: Linker flags, including -Wall, -Wpedantic, and -Wextra for additional warning flags.
* __LDLIBS__: Libraries to link, including -lpthread and -lm.


# Target Mode (Debug or Release):

The Makefile supports both debug and release modes. The user can specify release=1 as an option to build in release mode, which includes optimizations and disables debug symbols.

Variables for Build Directories and Object Files:

* __CPP_BLD_DIR__: The C++ build directory.
* __CPP_BIN_DIR__: The C++ binary output directory.
* __CPP_OBJ_DIR__: The C++ object output directory.
* __CPP_LIB_DIR__: The C++ library output directory.
* __CPP_INS_DIR__: The C++ install output directory.
* __CPP_EXT_DIR__: The C++ external output directory.

# Targets:

* __all__: Default target to build the entire project.
* __setup__: Creates the necessary build directory structure.
* __compile__: Compiles the source files into object files.
* __link__: Links the object files to create the executable.
* __run__: Builds and runs the program.
* __clean__: Removes the build directory.
* __install__: Packages the program into the install directory.
* __setup_resources__: Copies resource files to the binary output directory.
* __help__: Displays help information about available targets and options.

> Note that the Makefile assumes that there are source files in CFG_SRC_DIR, header files in CFG_INC_DIR, and resource files in CFG_RES_DIR. Additionally, it dynamically detects the operating system and sets appropriate flags and directories accordingly.
