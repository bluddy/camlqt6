# Windows Testing & Setup Guide for CamlQt6

This document provides step-by-step instructions for building, running tests, and executing interactive GUI demos of **CamlQt6** natively on **Windows 11 / Windows 10**.

---

## 1. Supported Windows Toolchains

CamlQt6 supports both major C++ toolchains on Windows:
1. **MSVC (Visual Studio 2022 / 2019):** Recommended for native Windows development.
2. **MinGW-w64 (GCC / UCRT64 / MSYS2):** Recommended if using a GCC-based Windows OCaml toolchain.

---

## 2. Prerequisites

### 2.1 OCaml 5.x on Windows
You need an active OCaml 5.x environment on Windows. Any of the following setups work:
- **Official Opam 2.2+ for Windows:** Configured with MSVC or MinGW compiler switch.
- **DkML (Diskuv OCaml):** Provides a pre-configured MSVC-compatible OCaml 5 environment.

Verify your environment in a terminal:
```cmd
ocaml --version
dune --version
```

---

### 2.2 Qt 6 Development Libraries

#### Option A: Official Qt Online Installer (Recommended for MSVC)
1. Install Qt 6 (version 6.5, 6.7, or 6.8) using the official [Qt Online Installer](https://www.qt.io/download-qt-installer).
2. Under the Qt version selection, choose **MSVC 2022 64-bit** (e.g. `Qt 6.8.0 -> MSVC 2022 64-bit`).
3. Note the installation path, typically:
   ```
   C:\Qt\6.8.0\msvc2022_64
   ```

*Alternative (automated CLI via `aqtinstall`):*
```powershell
pip install aqtinstall
aqt install-qt windows desktop 6.8.0 win64_msvc2022_64 -O C:\Qt
```

#### Option B: MSYS2 / UCRT64 (For MinGW-w64)
If using an MSYS2 / MinGW-w64 OCaml environment:
```bash
pacman -S mingw-w64-ucrt-x86_64-qt6-base mingw-w64-ucrt-x86_64-pkgconf
```

---

## 3. Configuring Environment Variables

### 3.1 For MSVC (Command Prompt / Developer PowerShell)

Open a **x64 Native Tools Command Prompt for VS 2022** (or your developer shell) and set `QTDIR`:

#### In `cmd.exe`:
```cmd
:: 1. Point QTDIR to your Qt 6 installation directory
set QTDIR=C:\Qt\6.8.0\msvc2022_64

:: 2. Add Qt bin directory to PATH so dynamic libraries (Qt6Core.dll, Qt6Widgets.dll) are found
set PATH=%QTDIR%\bin;%PATH%
```

#### In PowerShell:
```powershell
$env:QTDIR = "C:\Qt\6.8.0\msvc2022_64"
$env:PATH = "$env:QTDIR\bin;$env:PATH"
```

> [!NOTE]
> `config/discover.ml` will automatically detect `QTDIR`, inspect `include/` and `lib/`, and configure the appropriate MSVC flags (`/std:c++17`, `/EHsc`, `/LIBPATH`, and `.lib` files).

---

### 3.2 Manual Environment Variable Overrides (Optional)

If your Qt 6 installation is in a custom location, you can explicitly provide compile and link flags via `CamlQt6_CFLAGS` and `CamlQt6_LIBS`:

#### For MSVC:
```cmd
set CamlQt6_CFLAGS=-I"C:\Qt\6.8.0\msvc2022_64\include" -I"C:\Qt\6.8.0\msvc2022_64\include\QtCore" -I"C:\Qt\6.8.0\msvc2022_64\include\QtGui" -I"C:\Qt\6.8.0\msvc2022_64\include\QtWidgets"
set CamlQt6_LIBS=/LIBPATH:"C:\Qt\6.8.0\msvc2022_64\lib" Qt6Widgets.lib Qt6Gui.lib Qt6Core.lib
```

#### For MinGW:
```cmd
set CamlQt6_CFLAGS=-IC:/Qt/6.8.0/mingw_64/include -IC:/Qt/6.8.0/mingw_64/include/QtCore -IC:/Qt/6.8.0/mingw_64/include/QtGui -IC:/Qt/6.8.0/mingw_64/include/QtWidgets
set CamlQt6_LIBS=-LC:/Qt/6.8.0/mingw_64/lib -lQt6Widgets -lQt6Gui -lQt6Core
```

---

## 4. Building & Running the Tests

`config/discover.ml` automatically searches standard Windows locations (MSYS2 UCRT64 `C:\msys64\ucrt64`, MinGW64 `C:\msys64\mingw64`, and official Qt installs).

### 4.1 Build
```powershell
dune build
```

### 4.2 Automated Headless Test Suite
Run the 34-case test suite in headless offscreen mode:
```powershell
$env:QT_QPA_PLATFORM = "offscreen"
dune runtest
```

Expected output:
```
=== Starting CamlQt6 Test Suite ===
Entering QApplication event loop...
Timer callback executed successfully in event loop!
Event loop exited cleanly.
Testing memory model and object lifetime tracking...
=== All CamlQt6 Tests Passed Successfully! ===
```

---

## 5. Running the Interactive GUI Demos

On Windows, Qt runtime DLLs must be located at runtime. Use the convenient zero-config runner scripts:

### Using PowerShell:
```powershell
.\run.ps1 hello
.\run.ps1 declarative_todo
.\run.ps1 workbench_demo
.\run.ps1 table_view_demo
.\run.ps1 drawing_canvas
.\run.ps1 kitchen_sink
```

### Using Command Prompt (cmd.exe):
```cmd
run.bat hello
run.bat declarative_todo
run.bat workbench_demo
```

---

## 6. Creating Standalone Windows Application Bundles

To share your CamlQt6 application with Windows users who **do not have OCaml, Opam, or Qt installed**:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\bundle_windows.ps1 hello
```

This runs Qt's `windeployqt` tool to copy all required Qt 6 DLLs, plugins, and MinGW C++ runtimes into `dist\hello\`. The resulting folder is 100% self-contained: users can simply unzip and run `hello.exe` on any 64-bit Windows 10/11 system.

---

## 7. Troubleshooting & Windows Gotchas

### 6.1 `The code execution cannot proceed because Qt6Widgets.dll was not found`
- **Cause:** Windows runtime linker cannot find Qt DLLs.
- **Solution:** Add the Qt binary directory to your `PATH` in the active shell:
  ```cmd
  set PATH=%QTDIR%\bin;%PATH%
  ```

### 6.2 `<windows.h>` `min` and `max` Macro Conflicts
- **Cause:** Standard Windows SDK headers define `min(a,b)` and `max(a,b)` as preprocessor macros, which break C++ `std::min`, `std::max`, and Qt member functions.
- **Solution:** `src/CamlQt6_stubs.h` already defines `#define NOMINMAX` before any includes to prevent this issue.

### 6.3 Mixed Slashes in Paths
- When specifying paths in environment variables with MSVC, either backslashes (`\`) or forward slashes (`/`) work, but avoid trailing slashes before quotes (e.g. use `-I"C:\path"` instead of `-I"C:\path\"`).

### 6.4 Missing C++ Runtime Symbols with MinGW
- If linking fails with unresolved C++ standard library symbols when using MinGW, `config/discover.ml` automatically adds `-lstdc++`. Ensure you are using the same GCC version that compiled Qt.
