<h1 align="center">
  <br>
  <a href="#"><img src=".assets/logo.png" alt="logo" width="200"></a>
  <br>
  🧰 Cross-Platform C++ Makefile Template
  <br>
</h1>

<h4 align="center">A minimal template for cli apps</h4>

<p align="center">

<!-- Shields -->
[![Makefile CI](https://github.com/IvoBrandao/cpp-makefile-template/actions/workflows/makefile.yml/badge.svg)](https://github.com/IvoBrandao/cpp-makefile-template/actions/workflows/makefile.yml)

</p>

This is a C++ project template featuring a modern Makefile that automates the build process.
It’s designed for **quick prototyping**, **structured builds**, and **portable testing**, with support for **debug** and **release** modes.

---

### 🚀 Prerequisites

* A C++ compiler (e.g., `g++`)
* `make` build tool
* [GoogleTest](https://github.com/google/googletest) if you're using the test target (`libgtest`, `libgtest_main`)

---

### 🛠️ Getting Started

**1. Clone or download this repository**:

```sh
git clone git@github.com:IvoBrandao/cpp-makefile-template.git <YourProject>
```

**2. Navigate to the project folder**:

```sh
cd <YourProject>
```

**3. Run the help command to view available targets**:

```bash
make help
```

---

### 🗂️ Project Structure

```txt
<project>/
├── include/          # Header files
├── source/           # C++ source files
├── resources/        # Static files (images, data, etc.)
├── tests/            # Test cases (GoogleTest-based)
├── build/            # Auto-generated build output
├── Makefile          # Build automation
└── README.md         # This file
```

---

### ⚙️ How to Use

#### 🔍 View available commands:

```sh
make help
```

#### ⚙️ Build the project

**Release mode (optimized)**:

```sh
make release=1
  ```

**Debug mode (default)**:

```sh
make
```

### ▶️ Run the compiled app (with optional arguments)

```sh
make run ARGS="--help"
```

#### 🧪 Build and run tests

Compile tests:

```sh
make test
```

Compile **and run** all tests:

```sh
make run_tests
```

> Note: The tests are linked against all your source code **except** `main.cpp`.

### 🧹 Clean up build artifacts:

```sh
make clean
```

### 📦 Package for installation:

```sh
make install
```

---

## 🔧 Configuration

You can adjust the project by modifying variables in the `Makefile`. Below are the key ones:

### 📁 Directory Variables

* `CFG_INC_DIR`: Header files
* `CFG_SRC_DIR`: Source code
* `CFG_RES_DIR`: Static resources
* `CFG_TEST_DIR`: Unit test sources
* `CFG_BLD_OUT_DIR`: Base build output
* `CFG_OBJ_OUT_DIR`, `CFG_BIN_OUT_DIR`, etc.: Object, binary, and lib output folders
* `CFG_EXE_NAME`: Executable name

### 🧰 Compiler & Linker

* `CFG_CXX_COMP`: C++ compiler (default: `g++`)
* `CPPFLAGS`: Preprocessor flags (`-MMD -MP` for dependency tracking)
* `CXXFLAGS`: C++ flags (`-std=c++23`, optimization, debug info)
* `LDFLAGS`: Linker flags
* `LDLIBS`: Linked libraries (`-lpthread -lm`)

### 🖥️ Platform Detection

OS detection is automatic (`Linux`, `macOS`, `Windows`) and sets flags/output directories accordingly.

---

### 🎯 Build Targets

| Target      | Description                               |
| ----------- | ----------------------------------------- |
| `all`       | Build everything (default) 🛠️            |
| `compile`   | Compile source files 🧱                   |
| `link`      | Link object files into executable 🔗      |
| `test`      | Build unit tests 🧪                       |
| `run_tests` | Build & run all unit tests 🚦             |
| `run`       | Run the main app ▶️                       |
| `clean`     | Remove all build files 🧹                 |
| `install`   | Copy binaries/resources to install dir 📦 |
| `help`      | Show this help message 📘                 |

---

> ✅ Tip: You can pass `release=1` to any command to build with optimizations (e.g., `make run release=1`).

---

### 🧠 Notes

* The Makefile automatically links your test cases against all your source files **except `main.cpp`**.
* It handles dependency tracking with `-MMD` and `-MP`.
* Resource files in `resources/` are automatically copied to the build output.
