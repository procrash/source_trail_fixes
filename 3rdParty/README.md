# Third-Party Dependencies

This directory contains the third-party dependencies required to build Sourcetrail.

## Directory Structure

```
3rdParty/
├── src/           # Source code for dependencies
├── build/         # Build artifacts (git-ignored)
└── install/       # Installed libraries (git-ignored)
```

## Dependencies

### 1. Boost 1.67.0
Boost is downloaded automatically by the compile.sh script.

**Manual Download:**
```bash
cd 3rdParty/src
wget https://sourceforge.net/projects/boost/files/boost/1.67.0/boost_1_67_0.tar.gz/download -O boost_1_67_0.tar.gz
tar -xzf boost_1_67_0.tar.gz
```

**Source:** https://www.boost.org/
**License:** Boost Software License 1.0

### 2. Qt 5.12.3
Qt is downloaded automatically by the compile.sh script.

**Manual Download:**
```bash
cd 3rdParty/src
wget https://download.qt.io/archive/qt/5.12/5.12.3/single/qt-everywhere-src-5.12.3.tar.xz
tar -xf qt-everywhere-src-5.12.3.tar.xz
```

**Source:** https://www.qt.io/
**License:** LGPL v3 / GPL v2 / GPL v3

### 3. LLVM/Clang 11.0.0 (Git Submodule)
LLVM is included as a git submodule.

**Clone:**
```bash
git submodule update --init --recursive
```

Or manually:
```bash
cd 3rdParty/src
git clone --depth 1 --branch llvmorg-11.0.0 https://github.com/llvm/llvm-project.git
```

**Source:** https://llvm.org/
**License:** Apache 2.0 with LLVM Exceptions

## Building Dependencies

Run the main build script from the root directory:

```bash
./compile.sh
```

This will:
1. Download Boost and Qt if not present
2. Build all dependencies locally
3. Build Sourcetrail with C++, Python support

## Build Locations

- **Source:** `3rdParty/src/<package>`
- **Build artifacts:** `3rdParty/build/<package>`
- **Installed libraries:** `3rdParty/install/<package>`

All build and install directories are excluded from git via `.gitignore`.

## Disk Space Requirements

- Full build requires approximately 15-20 GB of disk space
- Qt build takes the longest time (30+ minutes on typical hardware)
- LLVM build takes 60+ minutes on typical hardware

## Cleaning

To clean build artifacts:
```bash
rm -rf 3rdParty/build/*
rm -rf 3rdParty/install/*
```

To completely reset (including downloaded sources):
```bash
rm -rf 3rdParty/src/boost_1_67_0*
rm -rf 3rdParty/src/qt-everywhere-src-5.12.3*
rm -rf 3rdParty/build/*
rm -rf 3rdParty/install/*
```
