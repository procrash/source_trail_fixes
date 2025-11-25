#!/bin/bash
# Setup script for initializing git submodules
# Run this after cloning the repository

set -e

echo "====================================="
echo "Sourcetrail Submodule Setup"
echo "====================================="
echo ""

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "Error: Not in a git repository!"
    echo "Please run this script from the root of the sourcetrail repository."
    exit 1
fi

# Initialize and update submodules
echo "Step 1: Initializing submodules..."
git submodule init

echo ""
echo "Step 2: Updating submodules (this may take a few minutes)..."
echo "  - Sourcetrail"
echo "  - LLVM/Clang 11.0.0"
git submodule update --recursive --progress

echo ""
echo "Step 3: Verifying submodule status..."
git submodule status

echo ""
echo "====================================="
echo "Submodules initialized successfully!"
echo "====================================="
echo ""
echo "Directory structure:"
echo "  - Sourcetrail/                (Main source code)"
echo "  - 3rdParty/src/llvm-project/  (LLVM/Clang)"
echo ""
echo "Next steps:"
echo "  1. Review README.md for build prerequisites"
echo "  2. Run ./compile.sh to build all dependencies and Sourcetrail"
echo ""
echo "Note: Boost and Qt will be downloaded automatically by compile.sh"
echo "====================================="
