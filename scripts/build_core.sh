#!/bin/bash

# Build script for Nanookjaro Core library

set -e

BUILD_TYPE=${BUILD_TYPE:-Release}
BUILD_DIR=${BUILD_DIR:-build}

echo "Building Nanookjaro Core library..."

# Create build directory
mkdir -p ${BUILD_DIR}

# Configure with CMake
cd ${BUILD_DIR}
cmake .. \
  -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
  -DNANOOKJARO_BUILD_CLI=OFF \
  -DNANOOKJARO_ENABLE_INSTALL=ON

# Build
cmake --build . --config ${BUILD_TYPE} -j$(nproc)

echo "Build completed successfully!"
echo "Library location: ${BUILD_DIR}/backend/libnanookjaro_core.so"