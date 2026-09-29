module C = Configurator.V1

let split_ws s =
  s |> String.split_on_char ' '
  |> List.map String.trim
  |> List.filter (fun s -> String.length s > 0)

let is_macos () =
  try
    let ic = Unix.open_process_in "uname -s" in
    let s = input_line ic in
    close_in ic;
    String.trim s = "Darwin"
  with _ -> false

let () =
  let cxxflags_path = ref "cxxflags.sexp" in
  let clibs_path = ref "clibs.sexp" in
  let args = [
    ("-cxxflags", Arg.Set_string cxxflags_path, "Output file for C++ flags");
    ("-clibs", Arg.Set_string clibs_path, "Output file for C/C++ linker flags");
  ] in
  Arg.parse args ignore "Discover Qt 6 configuration";

  C.main ~name:"oqt6-discover" (fun c ->
    let ccomp_type =
      match C.ocaml_config_var c "ccomp_type" with
      | Some s -> s
      | None -> if Sys.os_type = "Win32" then "msvc" else "cc"
    in
    let is_msvc = ccomp_type = "msvc" in

    let default_cxxflags =
      if is_msvc then
        ["/std:c++17"; "/EHsc"; "/Zc:__cplusplus"]
      else if Sys.os_type = "Win32" then
        ["-std=c++17"]
      else
        ["-std=c++17"; "-fPIC"]
    in

    let default_cpp_runtime =
      if is_msvc then
        []
      else if is_macos () then
        ["-lc++"]
      else
        ["-lstdc++"]
    in

    let cxxflags, clibs =
      match Sys.getenv_opt "OQT6_CFLAGS", Sys.getenv_opt "OQT6_LIBS" with
      | Some cflags, Some libs ->
        (default_cxxflags @ split_ws cflags, split_ws libs @ default_cpp_runtime)
      | _ ->
        (* Check QTDIR or Qt6_DIR environment variable *)
        let qtdir_opt =
          match Sys.getenv_opt "QTDIR" with
          | Some dir when String.length dir > 0 -> Some dir
          | _ -> Sys.getenv_opt "Qt6_DIR"
        in
        match qtdir_opt with
        | Some dir when Sys.file_exists (Filename.concat dir "include") ->
          let inc_dir = Filename.concat dir "include" in
          let lib_dir = Filename.concat dir "lib" in
          let flags = [
            "-I" ^ inc_dir;
            "-I" ^ Filename.concat inc_dir "QtCore";
            "-I" ^ Filename.concat inc_dir "QtGui";
            "-I" ^ Filename.concat inc_dir "QtWidgets";
          ] in
          let libs =
            if is_msvc then
              ["/LIBPATH:" ^ lib_dir; "Qt6Widgets.lib"; "Qt6Gui.lib"; "Qt6Core.lib"]
            else
              ["-L" ^ lib_dir; "-lQt6Widgets"; "-lQt6Gui"; "-lQt6Core"]
          in
          (default_cxxflags @ flags, libs @ default_cpp_runtime)
        | _ ->
          let pc_conf =
            match C.Pkg_config.get c with
            | None -> None
            | Some pc -> C.Pkg_config.query pc ~package:"Qt6Widgets"
          in
          match pc_conf with
          | Some { cflags; libs } ->
            (default_cxxflags @ cflags, libs @ default_cpp_runtime)
          | None ->
            C.die "Failed to discover Qt 6 configuration.\n\
                   Please ensure Qt 6 development libraries are installed and do one of:\n\
                   1. Set QTDIR=<path_to_qt6_prefix> (e.g., C:\\Qt\\6.8.0\\msvc2022_64)\n\
                   2. Ensure pkg-config can find Qt6Widgets (pkg-config --modversion Qt6Widgets)\n\
                   3. Explicitly set OQT6_CFLAGS and OQT6_LIBS environment variables."
    in

    C.Flags.write_sexp !cxxflags_path cxxflags;
    C.Flags.write_sexp !clibs_path clibs
  )
