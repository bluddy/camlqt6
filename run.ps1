param(
    [string]$Target = "examples/hello.exe"
)

$ErrorActionPreference = "Stop"

# Work regardless of the caller's current directory, so `.\run.ps1 hello` works
# from anywhere inside the repo.
Set-Location $PSScriptRoot

# Normalize singular 'example/' to 'examples/'
if ($Target -like "example/*") {
    $Target = "examples/" + $Target.Substring(8)
}

# If short name like 'hello' or 'workbench_demo', resolve to 'examples/<name>.exe'
if ($Target -notlike "*/*" -and $Target -notlike "*\*") {
    $Target = "examples/$Target"
}
if (-not $Target.EndsWith(".exe")) {
    $Target = "$Target.exe"
}

# Auto-detect QTDIR if not set. Probe for real Qt headers rather than for a bin
# directory: C:\msys64\ucrt64\bin exists on every MSYS2 install, with or without
# Qt, and setting QTDIR from it made config/discover.ml emit bogus -I flags.
if (-not $env:QTDIR) {
    $candidates = @(
        @{ prefix = "C:\msys64\ucrt64";  header = "include\qt6\QtWidgets\QWidget" },
        @{ prefix = "C:\msys64\ucrt64";  header = "include\QtWidgets\QWidget" },
        @{ prefix = "C:\msys64\mingw64"; header = "include\qt6\QtWidgets\QWidget" },
        @{ prefix = "C:\msys64\clang64"; header = "include\qt6\QtWidgets\QWidget" }
    )
    foreach ($c in $candidates) {
        if (Test-Path (Join-Path $c.prefix $c.header)) {
            $env:QTDIR = $c.prefix
            break
        }
    }
}

if ($env:QTDIR -and (Test-Path (Join-Path $env:QTDIR "bin"))) {
    $env:PATH = "$env:QTDIR\bin;$env:PATH"
}

# Locate dune via opam's switch root rather than assuming %LOCALAPPDATA%\opam\default.
$opamBin = "$env:LOCALAPPDATA\opam\default\bin"
if (Test-Path $opamBin) {
    $env:PATH = "$opamBin;$env:PATH"
}
if (-not (Get-Command dune -ErrorAction SilentlyContinue)) {
    Write-Error "dune was not found on PATH. Install opam and run 'opam install dune', or add dune to PATH."
}

Write-Host "Running: dune exec $Target" -ForegroundColor Cyan
dune exec $Target
if ($LASTEXITCODE -ne 0) {
    Write-Error "dune exec $Target failed with exit code $LASTEXITCODE."
}