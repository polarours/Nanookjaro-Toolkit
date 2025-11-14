#!/bin/bash

# Build script for Nanookjaro Frontend

set -e

BUILD_TYPE=${BUILD_TYPE:-Release}
CORE_LIB_PATH=${CORE_LIB_PATH:-../build/core/libnanookjaro_core.so}

echo "Building Nanookjaro Frontend..."

# Navigate to Flutter app directory
cd frontend/flutter

# Get dependencies
flutter pub get

# Build for Linux
flutter build linux --release

echo "Frontend build completed successfully!"
echo "Application location: build/linux/x64/release/bundle/nanookjaro_frontend"