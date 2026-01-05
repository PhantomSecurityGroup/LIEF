$dest = if ($args.Length -gt 0) { $args[0] } else { Get-Location }

if (Test-Path -Path (Join-Path $dest "thirdparty\lib\libLIEF.a")) {
    exit 0
}

New-Item -Force -Path (Join-Path $dest "thirdparty\") -ItemType Directory
New-Item -Force -Path (Join-Path $dest "thirdparty\include") -ItemType Directory
New-Item -Force -Path (Join-Path $dest "thirdparty\lib") -ItemType Directory

Set-Location $PSScriptRoot

$includeDir = Join-Path $dest "thirdparty\"
$libDir = Join-Path $dest "thirdparty\lib\"

if (Test-Path -Path ".\build\libLIEF.a") {
    cp ".\build\libLIEF.a" $libDir
    cp -Recurse -Force ".\include" $includeDir
    cp -Recurse -Force ".\build\include" $includeDir
    exit 0
}

cp -Recurse -Force include $includeDir

mkdir -Force build
cd build

cmake -DCMAKE_TOOLCHAIN_FILE="../zig.toolchain.cmake" -G Ninja -DCMAKE_BUILD_TYPE=Release ..
cmake --build . --target LIB_LIEF --config Release

cp -Force libLIEF.a $libDir
cp -Recurse -Force include $includeDir

