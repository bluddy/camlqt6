# Windows Testing & Setup Guide for OQt6

This document provides step-by-step instructions for building, running tests, and executing interactive GUI demos of **OQt6** natively on **Windows 11 / Windows 10**.

---

## 1. Supported Windows Toolchains

OQt6 supports both major C++ toolchains on Windows:
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

If your Qt 6 installation is in a custom location, you can explicitly provide compile and link flags via `OQT6_CFLAGS` and `OQT6_LIBS`:

#### For MSVC:
```cmd
set OQT6_CFLAGS=-I"C:\Qt\6.8.0\msvc2022_64\include" -I"C:\Qt\6.8.0\msvc2022_64\include\QtCore" -I"C:\Qt\6.8.0\msvc2022_64\include\QtGui" -I"C:\Qt\6.8.0\msvc2022_64\include\QtWidgets"
set OQT6_LIBS=/LIBPATH:"C:\Qt\6.8.0\msvc2022_64\lib" Qt6Widgets.lib Qt6Gui.lib Qt6Core.lib
```

#### For MinGW:
```cmd
set OQT6_CFLAGS=-IC:/Qt/6.8.0/mingw_64/include -IC:/Qt/6.8.0/mingw_64/include/QtCore -IC:/Qt/6.8.0/mingw_64/include/QtGui -IC:/Qt/6.8.0/mingw_64/include/QtWidgets
set OQT6_LIBS=-LC:/Qt/6.8.0/mingw_64/lib -lQt6Widgets -lQt6Gui -lQt6Core
```

---

## 4. Building & Running the Tests

Once `QTDIR` and `PATH` are configured:

### 4.1 Build
```cmd
dune build
```

### 4.2 Automated Headless Test Suite
Run the 34-case test suite in headless offscreen mode:
```cmd
dune runtest
```

Expected output:
```
=== Starting OQt6 Test Suite ===
Entering QApplication event loop...
Timer callback executed successfully in event loop!
Event loop exited cleanly.
Testing memory model and object lifetime tracking...
=== All OQt6 Tests Passed Successfully! ===
```

---

## 5. Running the Interactive GUI Demos

You can run any of the interactive desktop demos directly on your Windows desktop:

### 1. Declarative To-Do & Reactive Dashboard (Phase 5)
```cmd
dune exec examples/declarative_todo.exe
```

### 2. Developer Workbench (Phase 4)
```cmd
dune exec examples/workbench_demo.exe
```

### 3. High-Performance TableView & Model Demo (Phase 3)
```cmd
dune exec examples/table_view_demo.exe
```

### 4. 2D Vector Drawing Canvas (Phase 2)
```cmd
dune exec examples/drawing_canvas.exe
```

### 5. Kitchen Sink Widget Catalog (Phase 1)
```cmd
dune exec examples/kitchen_sink.exe
```

---

## 6. Troubleshooting & Windows Gotchas

### 6.1 `The code execution cannot proceed because Qt6Widgets.dll was not found`
- **Cause:** Windows runtime linker cannot find Qt DLLs.
- **Solution:** Add the Qt binary directory to your `PATH` in the active shell:
  ```cmd
  set PATH=%QTDIR%\bin;%PATH%
  ```

### 6.2 `<windows.h>` `min` and `max` Macro Conflicts
- **Cause:** Standard Windows SDK headers define `min(a,b)` and `max(a,b)` as preprocessor macros, which break C++ `std::min`, `std::max`, and Qt member functions.
- **Solution:** `src/oqt6_stubs.h` already defines `#define NOMINMAX` before any includes to prevent this issue.

### 6.3 Mixed Slashes in Paths
- When specifying paths in environment variables with MSVC, either backslashes (`\`) or forward slashes (`/`) work, but avoid trailing slashes before quotes (e.g. use `-I"C:\path"` instead of `-I"C:\path\"`).

### 6.4 Missing C++ Runtime Symbols with MinGW
- If linking fails with unresolved C++ standard library symbols when using MinGW, `config/discover.ml` automatically adds `-lstdc++`. Ensure you are using the same GCC version that compiled Qt.
