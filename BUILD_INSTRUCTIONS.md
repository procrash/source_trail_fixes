# Sourcetrail Build Instructions

This directory contains a script to build Sourcetrail with full language support (C++, Java, Python) using locally-installed dependencies.

## Prerequisites

Before running the build script, ensure you have the following system packages installed:

### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    python3 \
    libssl-dev \
    libx11-dev \
    libxext-dev \
    libxfixes-dev \
    libxi-dev \
    libxrender-dev \
    libxcb1-dev \
    libx11-xcb-dev \
    libxcb-glx0-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    ninja-build
```

### For Java Support (Optional)
To enable Java language indexing, install JDK:

```bash
sudo apt-get install -y openjdk-11-jdk maven
```

**Note:** Java support will be automatically detected and enabled if JDK is available. If not installed, the build will continue with C++ and Python support only.

## Building Sourcetrail

### One-Line Installation

Simply run:

```bash
bash compile.sh
```

The script will:
1. Download all required dependencies (Boost, Qt, LLVM/Clang)
2. Build and install them locally in the `3rdParty` subdirectory
3. Configure and build Sourcetrail with all language support

### Build Time Estimates

- **Boost**: ~10-15 minutes
- **Qt**: ~30-60 minutes (longest step)
- **LLVM/Clang**: ~60-90 minutes
- **Sourcetrail**: ~5-10 minutes

**Total**: Approximately 2-3 hours on a modern multi-core system.

### Resumable Builds

The script is designed to be resumable. If the build is interrupted:
- Already-built dependencies are detected and skipped
- You can simply re-run `bash compile.sh` to continue

## After Building

Once the build completes successfully, you'll find:

- **Main application**: `Sourcetrail/build/Release/app/Sourcetrail`
- **Indexer**: `Sourcetrail/build/Release/app/sourcetrail_indexer`
- **All dependencies**: `3rdParty/install/`

### Running Sourcetrail

```bash
cd Sourcetrail/build/Release/app
./Sourcetrail
```

## Language Support

The build enables:
- **C/C++**: Always enabled (requires LLVM/Clang)
- **Java**: Enabled if JDK 1.8+ and Maven are detected
- **Python**: Always enabled (uses pre-built indexer)

## Disk Space Requirements

Ensure you have sufficient disk space:
- Source downloads: ~5 GB
- Build artifacts: ~15 GB
- Final installation: ~3 GB
- **Total recommended**: ~25 GB free space

## Troubleshooting

### Build Fails During Qt Compilation

Qt is the most complex dependency. If it fails:
1. Check that you have all required development libraries installed
2. Try reducing parallel jobs: Edit `compile.sh` and change `PARALLEL_JOBS` to a lower number

### Out of Memory

If the build runs out of memory:
1. Close other applications
2. Reduce parallel jobs in `compile.sh`
3. Consider adding swap space

### Clean Build

To start from scratch:
```bash
rm -rf 3rdParty Sourcetrail/build
bash compile.sh
```

## Deployment to Another System

To deploy on another system with the same architecture:

1. Copy the entire directory to the target system
2. Run `bash compile.sh` (it will skip building dependencies if they exist)
3. Or manually copy just the necessary files:
   ```bash
   # Copy the built application and dependencies
   cp -r Sourcetrail/build/Release/app /path/to/deployment/
   ```

## Directory Structure

```
.
├── compile.sh                          # Main build script
├── BUILD_INSTRUCTIONS.md               # This file
├── 3rdParty/                          # Local dependencies (created by script)
│   ├── src/                           # Downloaded source code
│   ├── build/                         # Build directories
│   └── install/                       # Installed libraries
│       ├── boost/
│       ├── qt/
│       └── llvm/
└── Sourcetrail/                       # Sourcetrail source code
    └── build/Release/                 # Build output
        └── app/                       # Final binaries here
```

## Additional Notes

- All dependencies are statically linked where possible
- The build is completely self-contained in this directory
- No system-wide installation of dependencies is performed
- The script uses `wget` for downloads and requires internet connectivity
