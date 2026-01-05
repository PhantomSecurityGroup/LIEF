#!/usr/bin/env bash
set -euo pipefail

# Save the original working directory
oldLocation="$(pwd)"

# Early exit if the library already exists
if [[ -f "thirdparty/lib/libLIEF.a" ]]; then
    exit 0
fi

# Create directory structure
mkdir -p thirdparty
mkdir -p thirdparty/include
mkdir -p thirdparty/lib

# Change to the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

includeDir="$oldLocation/thirdparty"
libDir="$oldLocation/thirdparty/lib"

# If build output already exists, just copy it
if [[ -f "./build/libLIEF.a" ]]; then
    cp -f "./build/libLIEF.a" "$libDir"
    cp -r -f "./include" "$includeDir"
    cp -r -f "./build/include" "$includeDir"
    cd "$oldLocation"
    exit 0
fi

# Copy headers
cp -r -f include "$includeDir"

# Build
mkdir -p build
cd build

cmake \
  -DCMAKE_TOOLCHAIN_FILE="../zig.toolchain.cmake" \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  ..

cmake --build . --target LIB_LIEF --config Release

# Copy outputs
cp -f libLIEF.a "$libDir"
cp -r -f include "$includeDir"

# Restore original directory
cd "$oldLocation"