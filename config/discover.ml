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
    let default_cxxflags =
      if Sys.os_type = "Win32" then
        ["/std:c++17"]
      else
        ["-std=c++17"; "-fPIC"]
    in
    let default_cpp_runtime =
      if Sys.os_type = "Win32" then
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
        let pc_conf =
          match C.Pkg_config.get c with
          | None -> None
          | Some pc -> C.Pkg_config.query pc ~package:"Qt6Widgets"
        in
        match pc_conf with
        | Some { cflags; libs } ->
          (default_cxxflags @ cflags, libs @ default_cpp_runtime)
        | None ->
          (* Fallback: Try qtpaths6 or error *)
          C.die "Failed to discover Qt6Widgets via pkg-config and OQT6_CFLAGS/OQT6_LIBS not set"
    in

    C.Flags.write_sexp !cxxflags_path cxxflags;
    C.Flags.write_sexp !clibs_path clibs
  )
