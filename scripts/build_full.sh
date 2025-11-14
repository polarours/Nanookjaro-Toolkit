#!/bin/bash

# Full build script for Nanookjaro Toolkit

set -e

BUILD_TYPE=${BUILD_TYPE:-Release}
BUILD_DIR=${BUILD_DIR:-build}

echo "Building full Nanookjaro Toolkit..."

# Build core library
./scripts/build_core.sh

# Build CLI
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}
cmake .. \
  -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
  -DNANOOKJARO_BUILD_CLI=ON \
  -DNANOOKJARO_ENABLE_INSTALL=ON
  
cmake --build . --config ${BUILD_TYPE} -j$(nproc)

# Build frontend
cd ..
./scripts/build_frontend.sh

echo "Full build completed successfully!"

echo "Artifacts:"
echo "- Core library: ${BUILD_DIR}/backend/libnanookjaro_core.so"
echo "- CLI tool: ${BUILD_DIR}/cli/nanookjaro-cli"
echo "- Frontend app: frontend/flutter/build/linux/x64/release/bundle/nanookjaro_frontend"