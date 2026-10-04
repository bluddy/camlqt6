@echo off
setlocal
if not defined QTDIR (
    rem Probe for a real Qt 6 installation, not merely a directory that exists.
    rem C:\msys64\ucrt64\include is present even when Qt is not installed, and
    rem setting QTDIR from that used to hand config/discover.ml bogus flags.
    if exist C:\msys64\ucrt64\include\qt6\QtWidgets\QWidget set QTDIR=C:\msys64\ucrt64
    if not defined QTDIR if exist C:\msys64\ucrt64\include\QtWidgets\QWidget set QTDIR=C:\msys64\ucrt64
    if not defined QTDIR if exist C:\msys64\mingw64\include\qt6\QtWidgets\QWidget set QTDIR=C:\msys64\mingw64
    if not defined QTDIR if exist C:\msys64\clang64\include\qt6\QtWidgets\QWidget set QTDIR=C:\msys64\clang64
)
if defined QTDIR if exist "%QTDIR%\bin" set PATH=%QTDIR%\bin;%PATH%

rem Locate dune via opam's switch root rather than assuming %LOCALAPPDATA%\opam\default.
if not exist "%LOCALAPPDATA%\opam\default\bin\dune.exe" (
    echo [camlqt6] dune not found in %LOCALAPPDATA%\opam\default\bin.
    echo [camlqt6] Install opam and run "opam install dune", or put dune on PATH.
    exit /b 1
)
set PATH=%LOCALAPPDATA%\opam\default\bin;%PATH%

set TARGET=%~1
if "%TARGET%"=="" set TARGET=examples/hello.exe
if "%TARGET:~0,8%"=="example/" set TARGET=examples/%TARGET:~8%
if not "%TARGET:~0,9%"=="examples/" set TARGET=examples/%TARGET%
rem Append .exe only after the examples/ rewrite, so `run.bat examples/hello`
rem works as well as `run.bat hello`. Previously the goto jumped past this.
if not "%TARGET:~-4%"==".exe" set TARGET=%TARGET%.exe

echo Running: dune exec %TARGET%
dune exec %TARGET%
if errorlevel 1 (
    echo [camlqt6] dune exec failed with exit code %errorlevel%.
    exit /b %errorlevel%
)
endlocal