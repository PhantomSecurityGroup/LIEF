#!/usr/bin/env bash
set -euo pipefail

# Destination root: first argument or current directory
dest="${1:-$(pwd)}"

# Early exit if the library already exists at the destination
if [[ -f "thirdparty/lib/libLIEF.a" ]]; then
    exit 0
fi

# Ensure directory structure (relative to destination)
mkdir -p "thirdparty"
mkdir -p "thirdparty/include"
mkdir -p "thirdparty/lib"

# Switch to the directory where this script lives
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

# Copy headers before build
cp -r -f include "$includeDir"

# Configure and build
mkdir -p build
cd build

cmake \
  -DCMAKE_TOOLCHAIN_FILE="../zig.toolchain.cmake" \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  ..

cmake --build . --target LIB_LIEF --config Release

# Install outputs
cp -f libLIEF.a "$libDir"
cp -r -f include "$includeDir"
