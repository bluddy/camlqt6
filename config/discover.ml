module C = Configurator.V1

let split_ws s =
  s |> String.split_on_char ' '
  |> List.map String.trim
  |> List.filter (fun s -> String.length s > 0)

let is_macos () =
  if Sys.os_type = "Win32" then false
  else
    try
      let ic = Unix.open_process_in "uname -s" in
      let s = input_line ic in
      close_in ic;
      String.trim s = "Darwin"
    with _ -> false

let find_standard_qt () =
  if Sys.os_type = "Win32" then
    let win_candidates = [
      "C:\\msys64\\ucrt64";
      "C:\\msys64\\mingw64";
      "C:\\msys64\\clang64";
    ] in
    let exists d = Sys.file_exists (Filename.concat d "include") in
    match List.find_opt exists win_candidates with
    | Some d -> Some d
    | None ->
      if Sys.file_exists "C:\\Qt" then
        try
          let entries = Sys.readdir "C:\\Qt" |> Array.to_list in
          let qt6_dirs = List.filter (fun e -> String.length e >= 2 && e.[0] = '6' && e.[1] = '.') entries in
          let sub_toolchains = ["msvc2022_64"; "mingw_64"; "llvm-mingw_64"] in
          let found = ref None in
          List.iter (fun ver ->
            List.iter (fun tc ->
              let cand = Filename.concat (Filename.concat "C:\\Qt" ver) tc in
              if !found = None && exists cand then found := Some cand
            ) sub_toolchains
          ) qt6_dirs;
          !found
        with _ -> None
      else None
  else if is_macos () then
    let mac_candidates = [
      "/opt/homebrew/opt/qt@6";
      "/opt/homebrew/opt/qt";
      "/usr/local/opt/qt@6";
      "/usr/local/opt/qt";
      "/opt/local/libexec/qt6";
    ] in
    List.find_opt (fun d -> Sys.file_exists (Filename.concat d "include")) mac_candidates
  else
    None

let () =
  let cxxflags_path = ref "cxxflags.sexp" in
  let clibs_path = ref "clibs.sexp" in
  let args = [
    ("-cxxflags", Arg.Set_string cxxflags_path, "Output file for C++ flags");
    ("-clibs", Arg.Set_string clibs_path, "Output file for C/C++ linker flags");
  ] in
  Arg.parse args ignore "Discover Qt 6 configuration";

  C.main ~name:"camlqt6-discover" (fun c ->
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

    let get_env_flags name fallback =
      match Sys.getenv_opt name with
      | Some s -> Some s
      | None -> Sys.getenv_opt fallback
    in
    let cxxflags, clibs =
      match get_env_flags "CAMLQT6_CFLAGS" "OQT6_CFLAGS",
            get_env_flags "CAMLQT6_LIBS" "OQT6_LIBS" with
      | Some cflags, Some libs ->
        (default_cxxflags @ split_ws cflags, split_ws libs @ default_cpp_runtime)
      | _ ->
        (* Check QTDIR, Qt6_DIR, or standard platform locations *)
        let qtdir_opt =
          match Sys.getenv_opt "QTDIR" with
          | Some dir when String.length dir > 0 -> Some dir
          | _ ->
            (match Sys.getenv_opt "Qt6_DIR" with
             | Some dir when String.length dir > 0 -> Some dir
             | _ -> find_standard_qt ())
        in
        match qtdir_opt with
        | Some dir when Sys.file_exists (Filename.concat dir "include") ->
          let inc_dir = Filename.concat dir "include" in
          let lib_dir = Filename.concat dir "lib" in
          let inc_sub = Filename.concat inc_dir "qt6" in
          let inc_base = if Sys.file_exists inc_sub then inc_sub else inc_dir in
          let flags = [
            "-I" ^ inc_dir;
            "-I" ^ inc_base;
            "-I" ^ Filename.concat inc_base "QtCore";
            "-I" ^ Filename.concat inc_base "QtGui";
            "-I" ^ Filename.concat inc_base "QtWidgets";
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
                   3. Explicitly set CAMLQT6_CFLAGS and CAMLQT6_LIBS environment variables."
    in

    C.Flags.write_sexp !cxxflags_path cxxflags;
    C.Flags.write_sexp !clibs_path clibs
  )
