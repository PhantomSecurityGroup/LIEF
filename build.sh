#!/usr/bin/env bash
set -euo pipefail

# Destination root: first argument or current directory (absolute path)
if [[ $# -gt 0 ]]; then
    dest="$(cd "$1" && pwd)"
else
    dest="$(pwd)"
fi

# Early exit if the library already exists at the destination
if [[ -f "$dest/thirdparty/lib/libLIEF.a" ]]; then
    exit 0
fi

# Create required directories
mkdir -p "$dest/thirdparty"
mkdir -p "$dest/thirdparty/include"
mkdir -p "$dest/thirdparty/lib"

# Change to the directory where this script resides
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

includeDir="$dest/thirdparty"
libDir="$dest/thirdparty/lib"

# Fast path: reuse existing build output
if [[ -f "./build/libLIEF.a" ]]; then
    cp -f "./build/libLIEF.a" "$libDir"
    cp -r -f "./include" "$includeDir"
    cp -r -f "./build/include" "$includeDir"
    exit 0
fi

# Copy headers before building
cp -r -f include "$includeDir"

# Build directory
mkdir -p build
cd build

# Configure and build with CMake + Ninja
cmake \
  -DCMAKE_TOOLCHAIN_FILE="../zig.toolchain.cmake" \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  ..

cmake --build . --target LIB_LIEF --config Release

# Copy built library and headers
cp -f libLIEF.a "$libDir"
cp -r -f include "$includeDir"
