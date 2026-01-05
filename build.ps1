$oldLocation = Get-Location

if (Test-Path -Path "thirdparty\lib\libLIEF.a") {
    exit 0
}

mkdir -Force "thirdparty"
mkdir -Force "thirdparty\include"
mkdir -Force "thirdparty\lib"

Set-Location $PSScriptRoot

$includeDir = Join-Path $oldLocation "thirdparty"
$libDir = Join-Path $oldLocation "thirdparty\lib"

if (Test-Path -Path ".\build\libLIEF.a") {
    cp ".\build\libLIEF.a" $libDir
    cp -Recurse -Force ".\include" $includeDir
    cp -Recurse -Force ".\build\include" $includeDir
    Set-Location $oldLocation
    exit 0
}

cp -Recurse -Force include $includeDir

mkdir -Force build
cd build

cmake -DCMAKE_TOOLCHAIN_FILE="../zig.toolchain.cmake" -G Ninja -DCMAKE_BUILD_TYPE=Release ..
cmake --build . --target LIB_LIEF --config Release

cp -Force libLIEF.a $libDir
cp -Recurse -Force include $includeDir

Set-Location $oldLocation
