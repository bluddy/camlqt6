param(
    [string]$Target = "examples/hello.exe"
)

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

# Auto-detect QTDIR if not set
if (-not $env:QTDIR) {
    if (Test-Path "C:\msys64\ucrt64\bin") {
        $env:QTDIR = "C:\msys64\ucrt64"
    } elseif (Test-Path "C:\msys64\mingw64\bin") {
        $env:QTDIR = "C:\msys64\mingw64"
    }
}

if ($env:QTDIR) {
    $env:PATH = "$env:QTDIR\bin;$env:PATH"
}

$opamBin = "$env:LOCALAPPDATA\opam\default\bin"
if (Test-Path $opamBin) {
    $env:PATH = "$opamBin;$env:PATH"
}

Write-Host "Running: dune exec $Target" -ForegroundColor Cyan
dune exec $Target
