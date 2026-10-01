param(
    [string]$Target = "examples/hello.exe",
    [string]$OutputDir = ""
)

$ErrorActionPreference = "Stop"

# Normalize target
if ($Target -like "example/*") {
    $Target = "examples/" + $Target.Substring(8)
}
if ($Target -notlike "*.*") {
    $Target = "examples/$Target.exe"
}

$appName = [System.IO.Path]::GetFileNameWithoutExtension($Target)
if ([string]::IsNullOrEmpty($OutputDir)) {
    $OutputDir = "dist\$appName"
}

Write-Host "=== Bundling $appName for Windows Distribution ===" -ForegroundColor Cyan

# 1. Detect Qt bin directory
$qtBin = ""
if ($env:QTDIR -and (Test-Path "$env:QTDIR\bin\windeployqt.exe")) {
    $qtBin = "$env:QTDIR\bin"
} elseif (Test-Path "C:\msys64\ucrt64\bin\windeployqt.exe") {
    $qtBin = "C:\msys64\ucrt64\bin"
} elseif (Test-Path "C:\msys64\mingw64\bin\windeployqt.exe") {
    $qtBin = "C:\msys64\mingw64\bin"
} else {
    Write-Error "Could not find windeployqt.exe. Please ensure Qt 6 is installed via MSYS2 or set QTDIR."
}

# 2. Add Opam and Qt to PATH for build
$opamBin = "$env:LOCALAPPDATA\opam\default\bin"
if (Test-Path $opamBin) {
    $env:PATH = "$opamBin;$env:PATH"
}
$env:PATH = "$qtBin;$env:PATH"

# 3. Build the executable
Write-Host "Building $Target with Dune..." -ForegroundColor Gray
dune build $Target

$builtExe = "_build\default\$Target"
if (-not (Test-Path $builtExe)) {
    Write-Error "Built executable not found at $builtExe"
}

# 4. Prepare distribution directory
if (Test-Path $OutputDir) {
    Remove-Item -Recurse -Force $OutputDir
}
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$destExe = Join-Path $OutputDir "$appName.exe"
Copy-Item $builtExe -Destination $destExe

# 5. Run windeployqt
Write-Host "Deploying Qt 6 runtime dependencies with windeployqt..." -ForegroundColor Gray
$windeployqt = Join-Path $qtBin "windeployqt.exe"
& $windeployqt --no-translations --compiler-runtime $destExe

# 6. Ensure MinGW C++ runtime DLLs are present
$runtimeDlls = @("libstdc++-6.dll", "libgcc_s_seh-1.dll", "libwinpthread-1.dll")
foreach ($dll in $runtimeDlls) {
    $src = Join-Path $qtBin $dll
    $dst = Join-Path $OutputDir $dll
    if ((Test-Path $src) -and (-not (Test-Path $dst))) {
        Copy-Item $src -Destination $dst
    }
}

Write-Host "`nSuccessfully created standalone bundle in: $OutputDir" -ForegroundColor Green
Write-Host "You can zip this folder and run $appName.exe on any Windows 10/11 machine without OCaml or Qt installed.`n"
