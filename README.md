# Sourcetrail Build Environment

This repository contains Sourcetrail with a custom build system that compiles all dependencies locally for better portability.

## Overview

Sourcetrail is a free and open-source cross-platform source explorer that helps you get productive on unfamiliar source code. It uses static analysis to index your code and creates an interactive graph visualization.

**Original Repository:** https://github.com/CoatiSoftware/Sourcetrail

## Features

This build environment provides:
- Local compilation of all dependencies (Boost, Qt, LLVM/Clang)
- Static linking of major libraries for better portability
- Automated build process
- Support for C++, Python language indexing

## Prerequisites

### System Requirements
- Linux (tested on Ubuntu/Debian, ARM64/x86_64)
- At least 20 GB free disk space
- 8+ GB RAM recommended
- Build time: 60-120 minutes (depending on hardware)

### Required Packages

**Debian/Ubuntu:**
```bash
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    pkg-config \
    libglib2.0-dev \
    zlib1g-dev \
    python3
```

**Fedora/RHEL:**
```bash
sudo dnf install -y \
    gcc gcc-c++ \
    cmake \
    git \
    wget \
    pkg-config \
    glib2-devel \
    zlib-devel \
    python3
```

## Quick Start

### 1. Clone the Repository

```bash
git clone --recursive <your-repository-url>
cd sourcetrail
```

The `--recursive` flag will automatically clone the submodules (Sourcetrail and LLVM).

**If you forgot the `--recursive` flag**, use the provided setup script:
```bash
./setup_submodules.sh
```

Or manually:
```bash
git submodule update --init --recursive
```

### 2. Build Everything

```bash
chmod +x compile.sh
./compile.sh
```

This script will:
1. Download Boost 1.67.0 and Qt 5.12.3 (if not present)
2. Build Boost with required libraries
3. Build Qt with static linking
4. Build LLVM/Clang 11.0.0
5. Build Sourcetrail with C++ and Python support

### 3. Run Sourcetrail

After successful build:
```bash
cd Sourcetrail/build/Release/app
./Sourcetrail
```

Or use the indexer directly:
```bash
cd Sourcetrail/build/Release/app
./sourcetrail_indexer
```

## Build Structure

```
sourcetrail/
├── 3rdParty/              # Third-party dependencies
│   ├── src/              # Source code (Boost, Qt, LLVM)
│   ├── build/            # Build artifacts (git-ignored)
│   └── install/          # Installed libraries (git-ignored)
├── Sourcetrail/          # Main Sourcetrail source (submodule)
├── compile.sh            # Main build script
├── check_build_status.sh # Build status checker
└── BUILD_INSTRUCTIONS.md # Detailed build instructions
```

## Language Support

| Language | Status | Notes |
|----------|--------|-------|
| C/C++    | ✓ Enabled | Full support via Clang/LLVM |
| Python   | ✓ Enabled | Via SourcetrailPythonIndexer |
| Java     | ✗ Disabled | Requires JDK 8+ (configurable) |

To enable Java support:
1. Install JDK 8 or later and Maven
2. Edit `compile.sh` and the build will auto-detect Java

## Build Outputs

After building, executables are located at:
- **Main Application:** `Sourcetrail/build/Release/app/Sourcetrail`
- **Indexer:** `Sourcetrail/build/Release/app/sourcetrail_indexer`

Both executables are approximately 95 MB each.

## Configuration

### Build Options

Edit `compile.sh` to customize:
- `PARALLEL_JOBS`: Number of parallel compilation jobs (default: nproc)
- `BUILD_JAVA_LANGUAGE_PACKAGE`: Enable/disable Java support
- `BUILD_PYTHON_LANGUAGE_PACKAGE`: Enable/disable Python support
- `BUILD_CXX_LANGUAGE_PACKAGE`: Enable/disable C++ support

### CMake Options

The build uses these key CMake options:
- Static Boost, Qt, LLVM libraries
- C++17 standard
- Release build type
- Static linking of libgcc/libstdc++

## Troubleshooting

### Build Fails

1. **Check disk space:** Need at least 20 GB free
2. **Check RAM:** LLVM needs significant memory to build
3. **Check logs:** Build logs are saved as `*.log` files

### Missing Dependencies

If the build complains about missing system packages:
```bash
# Check what's missing
pkg-config --list-all | grep -E 'glib|zlib'

# Install missing packages
sudo apt-get install libglib2.0-dev zlib1g-dev
```

### Clean Build

To start fresh:
```bash
# Clean build artifacts only
rm -rf 3rdParty/build/* 3rdParty/install/*
rm -rf Sourcetrail/build/

# Complete clean (including downloads)
rm -rf 3rdParty/src/boost_* 3rdParty/src/qt-everywhere-*
rm -rf 3rdParty/build/* 3rdParty/install/*
rm -rf Sourcetrail/build/
```

## Development

### Git Submodules

This repository uses git submodules for:
- **Sourcetrail:** Main application source
- **LLVM:** Clang/LLVM libraries for C++ indexing

Update submodules:
```bash
git submodule update --remote --merge
```

### Dependencies

Boost and Qt are downloaded as tarballs (not submodules) because:
1. Official releases use tarballs, not git
2. Smaller download size
3. Known stable versions

See `3rdParty/README.md` for more details.

## Contributing

This is a custom build environment for Sourcetrail. For contributions to Sourcetrail itself, visit:
https://github.com/CoatiSoftware/Sourcetrail

## License

- **Sourcetrail:** GPLv3 - See Sourcetrail/LICENSE.txt
- **Boost:** Boost Software License 1.0
- **Qt:** LGPL v3 / GPL v2 / GPL v3
- **LLVM:** Apache 2.0 with LLVM Exceptions

## Credits

- **Sourcetrail:** Coati Software OG
- **Build Scripts:** Custom build environment for local dependency compilation

## Support

For Sourcetrail issues: https://github.com/CoatiSoftware/Sourcetrail/issues
For build environment issues: Check the logs and troubleshooting section above

## Version

- **Sourcetrail Version:** 2021.4.21
- **Boost:** 1.67.0
- **Qt:** 5.12.3
- **LLVM/Clang:** 11.0.0
