param(
    [string]$Target = "examples/hello.exe",
    [string]$OutputDir = ""
)

$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

# Normalize target. Match run.ps1: decide on the presence of a path separator,
# not on the presence of a dot, so both `hello` and `hello.exe` work. The old
# `-notlike "*.*"` guard broke on `bundle_windows.ps1 hello.exe`.
if ($Target -like "example/*") {
    $Target = "examples/" + $Target.Substring(8)
}
if ($Target -notlike "*/*" -and $Target -notlike "*\*") {
    $Target = "examples/$Target"
}
if (-not $Target.EndsWith(".exe")) {
    $Target = "$Target.exe"
}

$appName = [System.IO.Path]::GetFileNameWithoutExtension($Target)
if ([string]::IsNullOrEmpty($OutputDir)) {
    $OutputDir = "dist\$appName"
}

Write-Host "=== Bundling $appName for Windows Distribution ===" -ForegroundColor Cyan

# 1. Detect the Qt bin directory. Supports the official installer layout
#    (C:\Qt\<ver>\<toolchain>\bin), which config/discover.ml also supports and
#    which the docs recommend for MSVC, plus the MSYS2 prefixes.
$qtBin = ""
$qtCandidates = @()
if ($env:QTDIR) {
    $qtCandidates += (Join-Path $env:QTDIR "bin")
}
foreach ($p in @("C:\msys64\ucrt64", "C:\msys64\mingw64", "C:\msys64\clang64")) {
    $qtCandidates += (Join-Path $p "bin")
}
if (Test-Path "C:\Qt") {
    foreach ($ver in (Get-ChildItem "C:\Qt" -Directory -ErrorAction SilentlyContinue |
                     Where-Object { $_.Name -match '^6\.' })) {
        foreach ($tc in @("msvc2022_64", "msvc2019_64", "mingw_64", "llvm-mingw_64")) {
            $qtCandidates += (Join-Path (Join-Path $ver.FullName $tc) "bin")
        }
    }
}
foreach ($c in $qtCandidates) {
    if (Test-Path (Join-Path $c "windeployqt.exe")) { $qtBin = $c; break }
}
if ([string]::IsNullOrEmpty($qtBin)) {
    Write-Error "Could not find windeployqt.exe. Set QTDIR to a Qt 6 prefix, or install Qt 6 via MSYS2 / the official installer."
}

# 2. Add opam and Qt to PATH for the build.
$opamBin = "$env:LOCALAPPDATA\opam\default\bin"
if (Test-Path $opamBin) {
    $env:PATH = "$opamBin;$env:PATH"
}
$env:PATH = "$qtBin;$env:PATH"

# 3. Build the executable.
Write-Host "Building $Target with Dune..." -ForegroundColor Gray
dune build $Target
if ($LASTEXITCODE -ne 0) {
    Write-Error "dune build $Target failed with exit code $LASTEXITCODE."
}

$builtExe = "_build\default\$($Target -replace '/', '\')"
if (-not (Test-Path $builtExe)) {
    Write-Error "Built executable not found at $builtExe"
}

# A bytecode target would need dllcamlqt6_stubs.dll alongside the exe; the
# native exe links the static stub archive instead. Refuse to ship a bundle
# that is missing the DLL rather than producing one that will not start.
$stubDll = [System.IO.Path]::ChangeExtension($builtExe, ".dll")
$stubDllName = "dllcamlqt6_stubs.dll"
$needsStubDll = Test-Path $stubDll
if ($needsStubDll) {
    Write-Warning "$stubDllName found next to the exe: this looks like a bytecode build. The bundle will include it."
}

# 4. Prepare the distribution directory.
if (Test-Path $OutputDir) {
    Remove-Item -Recurse -Force $OutputDir
}
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$destExe = Join-Path $OutputDir "$appName.exe"
Copy-Item $builtExe -Destination $destExe
if ($needsStubDll) {
    Copy-Item $stubDll -Destination (Join-Path $OutputDir $stubDllName)
}

# 5. Run windeployqt and actually check its exit code. $ErrorActionPreference
#    does not apply to native executables, so a partial deploy used to be
#    reported as success.
Write-Host "Deploying Qt 6 runtime dependencies with windeployqt..." -ForegroundColor Gray
$windeployqt = Join-Path $qtBin "windeployqt.exe"
& $windeployqt --no-translations --compiler-runtime $destExe
if ($LASTEXITCODE -ne 0) {
    Write-Error "windeployqt failed with exit code $LASTEXITCODE. The bundle in $OutputDir is incomplete."
}

# 6. Ensure MinGW C++ runtime DLLs are present (not applicable to MSVC, where
#    --compiler-runtime above already copied the CRT).
$runtimeDlls = @("libstdc++-6.dll", "libgcc_s_seh-1.dll", "libwinpthread-1.dll")
foreach ($dll in $runtimeDlls) {
    $src = Join-Path $qtBin $dll
    $dst = Join-Path $OutputDir $dll
    if (Test-Path $src) {
        if (-not (Test-Path $dst)) { Copy-Item $src -Destination $dst }
    } elseif (-not (Test-Path $dst)) {
        Write-Warning "MinGW runtime DLL '$dll' was not found next to Qt and is not in the bundle. The app may fail to start on a clean machine (ignore this for an MSVC Qt build)."
    }
}

Write-Host "`nSuccessfully created standalone bundle in: $OutputDir" -ForegroundColor Green
Write-Host "Zip that folder and distribute $appName.exe alongside it.`n"