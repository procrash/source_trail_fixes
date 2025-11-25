#!/bin/bash
set -e  # Exit on error

# Sourcetrail Compilation Script with Local Dependencies
# This script builds Sourcetrail with C++ support and installs all dependencies
# locally in the 3rdParty subdirectory

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THIRD_PARTY_DIR="${SCRIPT_DIR}/3rdParty"
SOURCE_DIR="${SCRIPT_DIR}/Sourcetrail"
BUILD_DIR="${SOURCE_DIR}/build/Release"
INSTALL_DIR="${THIRD_PARTY_DIR}/install"
PARALLEL_JOBS=$(nproc 2>/dev/null || echo 4)

echo "============================================"
echo "Sourcetrail Compilation Script"
echo "============================================"
echo "Script directory: ${SCRIPT_DIR}"
echo "3rd party directory: ${THIRD_PARTY_DIR}"
echo "Source directory: ${SOURCE_DIR}"
echo "Build directory: ${BUILD_DIR}"
echo "Parallel jobs: ${PARALLEL_JOBS}"
echo ""

# Create directory structure
echo "Step 1/6: Creating directory structure..."
mkdir -p "${THIRD_PARTY_DIR}"/{src,build,install}
mkdir -p "${BUILD_DIR}"

# Function to download file if not exists
download_if_needed() {
    local url=$1
    local output=$2
    if [ ! -f "${output}" ]; then
        echo "Downloading $(basename ${output})..."
        wget -O "${output}" "${url}"
    else
        echo "$(basename ${output}) already exists, skipping download..."
    fi
}

# Step 2: Build Boost 1.67
echo ""
echo "Step 2/6: Building Boost 1.67..."
BOOST_VERSION="1.67.0"
BOOST_VERSION_UNDERSCORE="1_67_0"
BOOST_DIR="${THIRD_PARTY_DIR}/src/boost_${BOOST_VERSION_UNDERSCORE}"
BOOST_INSTALL_DIR="${INSTALL_DIR}/boost"

if [ ! -d "${BOOST_INSTALL_DIR}" ]; then
    cd "${THIRD_PARTY_DIR}/src"
    download_if_needed \
        "https://sourceforge.net/projects/boost/files/boost/${BOOST_VERSION}/boost_${BOOST_VERSION_UNDERSCORE}.tar.gz/download" \
        "boost_${BOOST_VERSION_UNDERSCORE}.tar.gz"

    if [ ! -d "${BOOST_DIR}" ]; then
        echo "Extracting Boost..."
        tar -xzf "boost_${BOOST_VERSION_UNDERSCORE}.tar.gz"
    fi

    cd "${BOOST_DIR}"
    echo "Bootstrapping Boost..."
    ./bootstrap.sh --prefix="${BOOST_INSTALL_DIR}" \
        --with-libraries=filesystem,program_options,system,date_time

    echo "Building Boost (this may take a while)..."
    ./b2 -j${PARALLEL_JOBS} \
        --prefix="${BOOST_INSTALL_DIR}" \
        link=static \
        variant=release \
        threading=multi \
        runtime-link=static \
        cxxflags=-fPIC \
        install

    echo "Boost installed to ${BOOST_INSTALL_DIR}"
else
    echo "Boost already installed, skipping..."
fi

# Step 3: Build Qt 5.12.3
echo ""
echo "Step 3/6: Building Qt 5.12.3..."
QT_VERSION="5.12.3"
QT_VERSION_SHORT="5.12"
QT_DIR="${THIRD_PARTY_DIR}/src/qt-everywhere-src-${QT_VERSION}"
QT_BUILD_DIR="${THIRD_PARTY_DIR}/build/qt"
QT_INSTALL_DIR="${INSTALL_DIR}/qt"

if [ ! -d "${QT_INSTALL_DIR}" ]; then
    cd "${THIRD_PARTY_DIR}/src"
    download_if_needed \
        "https://download.qt.io/archive/qt/${QT_VERSION_SHORT}/${QT_VERSION}/single/qt-everywhere-src-${QT_VERSION}.tar.xz" \
        "qt-everywhere-src-${QT_VERSION}.tar.xz"

    if [ ! -d "${QT_DIR}" ]; then
        echo "Extracting Qt (this may take a while)..."
        tar -xf "qt-everywhere-src-${QT_VERSION}.tar.xz"
    fi

    # Fix Qt 5.12.3 compilation issue with GCC 11+
    echo "Applying Qt compatibility patch for GCC 11+..."
    sed -i '1i #include <limits>' "${QT_DIR}/qtbase/src/corelib/global/qendian.h"
    sed -i '/#include <algorithm>/a #include <limits>' "${QT_DIR}/qtbase/src/corelib/global/qglobal.h"

    mkdir -p "${QT_BUILD_DIR}"
    cd "${QT_BUILD_DIR}"

    echo "Configuring Qt (this may take a while)..."
    "${QT_DIR}/configure" \
        -prefix "${QT_INSTALL_DIR}" \
        -opensource \
        -confirm-license \
        -release \
        -static \
        -nomake examples \
        -nomake tests \
        -skip qtwebengine \
        -skip qt3d \
        -skip qtserialbus \
        -qt-zlib \
        -qt-libpng \
        -qt-libjpeg \
        -qt-pcre \
        -no-opengl \
        -no-icu

    echo "Building Qt (this will take a long time, 30+ minutes)..."
    make -j${PARALLEL_JOBS}
    make install

    echo "Qt installed to ${QT_INSTALL_DIR}"
else
    echo "Qt already installed, skipping..."
fi

# Step 4: Build LLVM/Clang 11.0.0
echo ""
echo "Step 4/6: Building LLVM/Clang 11.0.0..."
LLVM_VERSION="11.0.0"
LLVM_DIR="${THIRD_PARTY_DIR}/src/llvm-project"
LLVM_BUILD_DIR="${THIRD_PARTY_DIR}/build/llvm"
LLVM_INSTALL_DIR="${INSTALL_DIR}/llvm"

if [ ! -d "${LLVM_INSTALL_DIR}" ]; then
    cd "${THIRD_PARTY_DIR}/src"

    if [ ! -d "${LLVM_DIR}" ]; then
        echo "Cloning LLVM repository..."
        git clone --depth 1 --branch llvmorg-${LLVM_VERSION} \
            https://github.com/llvm/llvm-project.git
    fi

    # Fix LLVM compilation issue with GCC 11+
    echo "Applying LLVM compatibility patch for GCC 11+..."
    sed -i '/#include <vector>/a #include <limits>' "${LLVM_DIR}/llvm/utils/benchmark/src/benchmark_register.h" 2>/dev/null || true

    mkdir -p "${LLVM_BUILD_DIR}"
    cd "${LLVM_BUILD_DIR}"

    echo "Configuring LLVM/Clang (this may take a while)..."
    cmake -G "Unix Makefiles" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${LLVM_INSTALL_DIR}" \
        -DLLVM_ENABLE_PROJECTS="clang" \
        -DLLVM_ENABLE_RTTI=ON \
        -DLLVM_TARGETS_TO_BUILD="X86" \
        -DLLVM_INCLUDE_TESTS=OFF \
        -DLLVM_INCLUDE_EXAMPLES=OFF \
        -DLLVM_INCLUDE_DOCS=OFF \
        "${LLVM_DIR}/llvm"

    echo "Building LLVM/Clang (this will take a very long time, 60+ minutes)..."
    make -j${PARALLEL_JOBS}
    make install

    echo "LLVM/Clang installed to ${LLVM_INSTALL_DIR}"
else
    echo "LLVM/Clang already installed, skipping..."
fi

# Step 5: Check Java and Maven for Java support
echo ""
echo "Step 5/7: Checking Java and Maven for Java language support..."
JAVA_SUPPORT=OFF
JAVA_HOME_PATH=""
if command -v java &> /dev/null && command -v javac &> /dev/null; then
    echo "Java found: $(java -version 2>&1 | head -n 1)"
    # Try to find JAVA_HOME
    if [ -n "$JAVA_HOME" ]; then
        JAVA_HOME_PATH="$JAVA_HOME"
    elif command -v javac &> /dev/null; then
        JAVA_HOME_PATH=$(readlink -f $(which javac) | sed "s:/bin/javac::")
    fi

    if [ -n "$JAVA_HOME_PATH" ]; then
        export JAVA_HOME="$JAVA_HOME_PATH"
        echo "JAVA_HOME set to: $JAVA_HOME"
        JAVA_SUPPORT=ON

        # Check for Maven
        if command -v mvn &> /dev/null; then
            echo "Maven found: $(mvn -version | head -n 1)"
            export M2_HOME=$(mvn -version | grep "Maven home:" | cut -d' ' -f3)
            export MAVEN_HOME="$M2_HOME"
        else
            echo "Warning: Maven not found. Java support may be limited."
        fi
    fi
else
    echo "Java not found. Java language support will be disabled."
    echo "To enable Java support, install JDK 1.8 or later."
fi

# Step 6: Configure Sourcetrail
echo ""
echo "Step 6/7: Configuring Sourcetrail..."
cd "${BUILD_DIR}"

# Configure with static linking for better portability
# Get GLib flags for Qt static linking
GLIB_LIBS="$(pkg-config --libs glib-2.0 gthread-2.0)"

cmake -DCMAKE_BUILD_TYPE="Release" \
    -DBoost_NO_BOOST_CMAKE=ON \
    -DBoost_NO_SYSTEM_PATHS=ON \
    -DBOOST_ROOT="${BOOST_INSTALL_DIR}" \
    -DBoost_INCLUDE_DIR="${BOOST_INSTALL_DIR}/include" \
    -DQt5_DIR="${QT_INSTALL_DIR}/lib/cmake/Qt5" \
    -DClang_DIR="${LLVM_INSTALL_DIR}/lib/cmake/clang" \
    -DBUILD_CXX_LANGUAGE_PACKAGE=ON \
    -DBUILD_JAVA_LANGUAGE_PACKAGE=${JAVA_SUPPORT} \
    -DBUILD_PYTHON_LANGUAGE_PACKAGE=ON \
    -DCMAKE_EXE_LINKER_FLAGS="-static-libgcc -static-libstdc++ ${GLIB_LIBS}" \
    -DCMAKE_SHARED_LINKER_FLAGS="${GLIB_LIBS}" \
    "${SOURCE_DIR}"

# Step 7: Build Sourcetrail
echo ""
echo "Step 7/7: Building Sourcetrail..."
make -j${PARALLEL_JOBS} Sourcetrail

echo ""
echo "============================================"
echo "Build Complete!"
echo "============================================"
echo "Sourcetrail binary location: ${BUILD_DIR}/app/Sourcetrail"
echo "Sourcetrail indexer location: ${BUILD_DIR}/app/sourcetrail_indexer"
echo ""
echo "Language support enabled:"
echo "  - C/C++: YES"
if [ "$JAVA_SUPPORT" == "ON" ]; then
    echo "  - Java: YES"
else
    echo "  - Java: NO (JDK not found)"
fi
echo "  - Python: YES"
echo ""
echo "To run Sourcetrail:"
echo "  cd ${BUILD_DIR}/app"
echo "  ./Sourcetrail"
echo ""
echo "All dependencies are installed in: ${THIRD_PARTY_DIR}/install"
echo "============================================"
