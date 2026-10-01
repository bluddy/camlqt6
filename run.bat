@echo off
setlocal
if not defined QTDIR (
    if exist C:\msys64\ucrt64 set QTDIR=C:\msys64\ucrt64
    if exist C:\msys64\mingw64 if not defined QTDIR set QTDIR=C:\msys64\mingw64
)
if defined QTDIR set PATH=%QTDIR%\bin;%PATH%
if exist "%LOCALAPPDATA%\opam\default\bin" set PATH=%LOCALAPPDATA%\opam\default\bin;%PATH%

set TARGET=%~1
if "%TARGET%"=="" set TARGET=examples/hello.exe
if "%TARGET:~0,8%"=="example/" set TARGET=examples/%TARGET:~8%
if "%TARGET:~0,9%"=="examples/" goto run

set TARGET=examples/%TARGET%
if not "%TARGET:~-4%"==".exe" set TARGET=%TARGET%.exe

:run
echo Running: dune exec %TARGET%
dune exec %TARGET%
