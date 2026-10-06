(* Qt 6 discovery for dune-configurator.
 *
 * Resolution order:
 *   1. CAMLQT6_CFLAGS / CAMLQT6_LIBS (either may be given alone)
 *   2. QTDIR
 *   3. Qt6_DIR (accepts both prefix-style and CMake-style values)
 *   4. Platform-standard prefixes, filtered by compiler/toolchain compatibility
 *   5. pkg-config Qt6Widgets
 *   6. qmake6 -query
 *
 * Every candidate must be validated by looking for an actual QtWidgets header.
 * Checking only that an "include" directory exists is not enough: on MSYS2 that
 * directory is present even when Qt is not installed, which used to produce
 * bogus -I flags and a confusing "QtCore/QObject: No such file" build error. *)

module C = Configurator.V1

(* A successful discovery either names a prefix to build flags from, or hands
   back a flag pair produced directly by pkg-config. *)
type result = Prefix of string | Flags of string list * string list | No_qt

(* ------------------------------------------------------------------ *)
(* Flag parsing                                                         *)
(* ------------------------------------------------------------------ *)

(* Split on whitespace but keep double-quoted runs intact, so paths such as
   -I"C:/Program Files/Qt/6.8.0/msvc2022_64/include" survive. *)
let split_flags s =
  let n = String.length s in
  let buf = Buffer.create n in
  let acc = ref [] in
  let flush () =
    if Buffer.length buf > 0 then begin
      acc := Buffer.contents buf :: !acc;
      Buffer.clear buf
    end
  in
  let in_quotes = ref false in
  for i = 0 to n - 1 do
    match s.[i] with
    | '"' -> in_quotes := not !in_quotes
    | c when (c = ' ' || c = '\t') && not !in_quotes -> flush ()
    | c -> Buffer.add_char buf c
  done;
  flush ();
  List.rev !acc

(* ------------------------------------------------------------------ *)
(* Validation                                                          *)
(* ------------------------------------------------------------------ *)

(* True when [dir] looks like a usable Qt 6 prefix, i.e. it really contains
   QtWidgets headers. *)
let is_qt6_prefix dir =
  let inc = Filename.concat dir "include" in
  List.exists
    (fun rel ->
      let base = Filename.concat inc rel in
      List.exists
        (fun leaf ->
          Sys.file_exists
            (Filename.concat (Filename.concat base "QtWidgets") leaf))
        [ "QWidget"; "qwidget.h" ])
    [ ""; "qt6"; "Qt6" ]

(* Normalise a directory to a Qt prefix.
   - "<prefix>"                       -> "<prefix>"
   - "<prefix>/lib/cmake/Qt6"         -> "<prefix>"   (CMake-style Qt6_DIR)
   - "<prefix>/lib64/cmake/Qt6"       -> "<prefix>" *)
let normalise_prefix dir =
  let dir =
    if String.length dir > 1 && dir.[String.length dir - 1] = '/' then
      String.sub dir 0 (String.length dir - 1)
    else dir
  in
  (* CMake package dirs live at <prefix>/<lib|lib64>/cmake/Qt6, so walk up three
     levels from <prefix>/lib/cmake/Qt6 to recover <prefix>. *)
  let find_cmake base =
    [ "lib"; "lib64" ]
    |> List.concat_map (fun l ->
           let dir = Filename.concat base (Filename.concat l "cmake") in
           if not (Sys.file_exists dir) then []
           else
             Sys.readdir dir |> Array.to_list
             |> List.filter (fun e ->
                    String.length e >= 2 && e.[0] = 'Q' && e.[1] = 't'))
  in
  let rec up base depth =
    if depth > 4 then None
    else
      match find_cmake base with
      | _ :: _ -> Some base
      | [] ->
        let parent = Filename.concat base ".." in
        if parent = base then None else up parent (depth + 1)
  in
  match up dir 0 with Some prefix -> prefix | None -> dir

(* Classify a candidate prefix by the toolchain its binaries were built with, so
   we never hand MSVC-style linker flags to a MinGW Qt (or vice versa). *)
let prefix_toolchain dir =
  let d = String.lowercase_ascii dir in
  let has s =
    let m = String.length s in
    let rec go i = i + m <= String.length d && (String.sub d i m = s || go (i + 1)) in
    m > 0 && go 0
  in
  if has "msvc" then `Msvc
  else if has "llvm-mingw" then `Llvm_mingw
  else if has "ucrt64" || has "mingw64" || has "mingw32" then `Mingw
  else `Unknown

let toolchain_compatible ~is_msvc ~qt =
  match qt with
  | `Unknown -> true
  | `Msvc -> is_msvc
  | `Mingw | `Llvm_mingw -> not is_msvc

(* ------------------------------------------------------------------ *)
(* Candidate prefixes                                                  *)
(* ------------------------------------------------------------------ *)

let win_candidates () =
  let roots = [ "C:\\msys64\\ucrt64"; "C:\\msys64\\mingw64"; "C:\\msys64\\clang64" ] in
  let from_msys2 = List.filter_map (fun r -> if is_qt6_prefix r then Some r else None) roots in
  let from_official =
    if not (Sys.file_exists "C:\\Qt") then []
    else
      let entries = Sys.readdir "C:\\Qt" |> Array.to_list in
      let versions =
        List.filter
          (fun e -> String.length e >= 2 && e.[0] = '6' && e.[1] = '.')
          entries
      in
      let toolchains =
        [ "msvc2022_64"; "msvc2019_64"; "mingw_64"; "llvm-mingw_64" ]
      in
      List.concat_map
        (fun ver ->
          List.filter_map
            (fun tc ->
              let cand = Filename.concat (Filename.concat "C:\\Qt" ver) tc in
              if is_qt6_prefix cand then Some cand else None)
            toolchains)
        versions
  in
  from_msys2 @ from_official

let mac_candidates () =
  (* Only Qt 6 formulae. "/opt/homebrew/opt/qt" and "/usr/local/opt/qt" are the
     Homebrew *Qt 5* formulae and used to be accepted here, producing Qt 5
     include paths that were then linked against -lQt6Widgets. *)
  let roots =
    [ "/opt/homebrew/opt/qt@6"; "/usr/local/opt/qt@6"; "/opt/homebrew/opt/qt6";
      "/usr/local/opt/qt6"; "/opt/local/libexec/qt6" ]
  in
  List.filter_map (fun r -> if is_qt6_prefix r then Some r else None) roots

let is_macos () =
  if Sys.os_type = "Win32" || Sys.os_type = "MacOS" then Sys.os_type = "MacOS"
  else
    try
      let ic = Unix.open_process_in "uname -s" in
      let s = input_line ic in
      ignore (Unix.close_process_in ic);
      String.trim s = "Darwin"
    with _ -> false

let standard_candidates () =
  if Sys.os_type = "Win32" then win_candidates ()
  else if is_macos () then mac_candidates ()
  else []

(* ------------------------------------------------------------------ *)
(* Flag construction                                                   *)
(* ------------------------------------------------------------------ *)

let read_env name = match Sys.getenv_opt name with
  | Some s when String.trim s <> "" -> Some s
  | _ -> None

let cpp_runtime ~is_msvc =
  if is_msvc then []
  else if is_macos () then [ "-lc++" ]
  else [ "-lstdc++" ]

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

    (* C++ standard: 17 by default, overridable. The docs previously advertised
       C++20 while the build hardcoded 17. *)
    let std = match read_env "CAMLQT6_CXXSTD" with Some s -> s | None -> "17" in

(* /permissive- is mandatory for Qt 6.8+ on MSVC, not a style preference.
   QtCore/qcompilerdetection.h contains

     static_assert(__cpp_consteval >= 201811L ||
                   !(defined(_MSVC_LANG) ...),
                   "On MSVC you must pass the /permissive- option to the compiler.");

   and fails with error C2338 without it. MSVC's default (/permissive) also then
   produces a cascade of bogus errors inside Qt's own headers, notably C2666 on
   QByteArray::comparesEqual and C2139 'QString': an undefined class is not
   allowed as an argument to __is_convertible_to. Those are all consequences of
   the missing option, not separate problems, so do not chase them individually.
   Found by the Windows CI leg; it reproduces for any MSVC user on Qt >= 6.8. *)
    let default_cxxflags =
      if is_msvc then
        [ "/std:c++" ^ std; "/EHsc"; "/Zc:__cplusplus"; "/permissive-" ]
      else if Sys.os_type = "Win32" then [ "-std=c++" ^ std ]
      else [ "-std=c++" ^ std; "-fPIC" ]
    in

    let flags_for_prefix dir =
      let inc_dir = Filename.concat dir "include" in
      let lib_dir =
        if Sys.file_exists (Filename.concat dir "lib64") then Filename.concat dir "lib64"
        else Filename.concat dir "lib"
      in
      let base =
        let sub = Filename.concat inc_dir "qt6" in
        if Sys.file_exists sub then sub else inc_dir
      in
      let cflags = [
        "-I" ^ inc_dir; "-I" ^ base;
        "-I" ^ Filename.concat base "QtCore";
        "-I" ^ Filename.concat base "QtGui";
        "-I" ^ Filename.concat base "QtWidgets";
      ] in
      let libs =
        if is_msvc then
          [ "/LIBPATH:" ^ lib_dir; "Qt6Widgets.lib"; "Qt6Gui.lib"; "Qt6Core.lib" ]
        else
          [ "-L" ^ lib_dir; "-lQt6Widgets"; "-lQt6Gui"; "-lQt6Core" ]
      in
      (default_cxxflags @ cflags, libs @ cpp_runtime ~is_msvc)
    in

    let warn fmt = Printf.ksprintf (fun s -> prerr_endline ("[camlqt6-discover] warning: " ^ s)) fmt in

    let from_env_override =
      let cf = read_env "CAMLQT6_CFLAGS" in
      let lb = read_env "CAMLQT6_LIBS" in
      match cf, lb with
      | Some cflags, Some libs ->
        Some (default_cxxflags @ split_flags cflags, split_flags libs @ cpp_runtime ~is_msvc)
      | Some _, None ->
        warn "CAMLQT6_CFLAGS set but CAMLQT6_LIBS is not; ignoring the override";
        None
      | None, Some _ ->
        warn "CAMLQT6_LIBS set but CAMLQT6_CFLAGS is not; ignoring the override";
        None
      | None, None -> None
    in

    let from_qt_dirs () =
      let consider name =
        match read_env name with
        | None -> None
        | Some dir ->
          let norm = normalise_prefix dir in
          if is_qt6_prefix norm then Some norm
          else begin
            (* Distinguish "not a prefix" from "no QtWidgets headers here", which
               is the common case of a wrong QTDIR pointing at lib/cmake/Qt6. *)
            if Sys.file_exists (Filename.concat dir "include") then
              warn "%s=%s has an include/ dir but no QtWidgets headers; not a Qt 6 prefix"
                name dir
            else
              warn "%s=%s does not look like a Qt prefix (expected include/QtWidgets)"
                name dir;
            None
          end
      in
      match consider "QTDIR" with
      | Some d -> Some d
      | None -> consider "Qt6_DIR"
    in

    let from_pkg_config () =
      match C.Pkg_config.get c with
      | None ->
        warn "pkg-config not available";
        None
      | Some pc -> (
        try
          (* pkg-config already returns split flag lists, so they are used verbatim. *)
          match C.Pkg_config.query pc ~package:"Qt6Widgets" with
          | Some { cflags; libs } ->
            Some (default_cxxflags @ cflags, libs @ cpp_runtime ~is_msvc)
          | None ->
            warn "pkg-config cannot find Qt6Widgets";
            None
        with e ->
          warn "pkg-config query for Qt6Widgets failed: %s" (Printexc.to_string e);
          None)
    in

    let from_qmake () =
      let candidates =
        if Sys.os_type = "Win32" then [ "qmake6.exe"; "qmake6" ]
        else [ "qmake6"; "qmake-qt6" ]
      in
      let rec try_cmds = function
        | [] -> None
        | cmd :: rest -> (
          try
            let out = Filename.temp_file "qmake6" ".txt" in
            let rc = Sys.command (Printf.sprintf "%s -query QT_INSTALL_PREFIX > %s 2>NUL" cmd out) in
            let res =
              if rc <> 0 then None
              else
                let ic = open_in out in
                let prefix = input_line ic |> String.trim in
                close_in ic;
                if prefix = "" then None
                else
                  let norm = normalise_prefix prefix in
                  if is_qt6_prefix norm then Some norm else None
            in
            (try Sys.remove out with _ -> ());
            match res with Some _ as r -> r | None -> try_cmds rest
          with _ -> try_cmds rest)
      in
      try_cmds candidates
    in

    let resolve () =
      match from_qt_dirs () with
      | Some d -> Prefix d
      | None ->
        let cands = standard_candidates () in
        let compatible =
          List.filter (fun d -> toolchain_compatible ~is_msvc ~qt:(prefix_toolchain d)) cands
        in
        let rejected = List.length cands - List.length compatible in
        if rejected > 0 then
          warn
            "ignoring %d Qt prefix(es) built for a different toolchain than this OCaml \
             compiler (%s); set QTDIR explicitly to override"
            rejected ccomp_type;
        match compatible with
        | d :: _ -> Prefix d
        | [] -> (
          match from_pkg_config () with
          | Some (cf, lb) -> Flags (cf, lb)
          | None -> (
            match from_qmake () with
            | Some d -> Prefix d
            | None -> No_qt))
    in

    let cxxflags, clibs =
      match from_env_override with
      | Some r -> r
      | None -> (
        match resolve () with
        | Prefix d -> flags_for_prefix d
        | Flags (cf, lb) -> (cf, lb)
        | No_qt ->
          C.die
            "Failed to discover a Qt 6 installation.\n\
            Tried: CAMLQT6_CFLAGS/CAMLQT6_LIBS, QTDIR, Qt6_DIR, the standard platform prefixes, pkg-config Qt6Widgets, and qmake6 -query.\n\
            Install the Qt 6 development libraries, or point the build at a prefix explicitly:\n\
            \  1. QTDIR=<qt6 prefix>          (e.g. C:\\Qt\\6.8.0\\msvc2022_64, /opt/homebrew/opt/qt@6)\n\
            \  2. make pkg-config find Qt6Widgets (pkg-config --modversion Qt6Widgets)\n\
            \  3. set both CAMLQT6_CFLAGS and CAMLQT6_LIBS")
    in

    C.Flags.write_sexp !cxxflags_path cxxflags;
    C.Flags.write_sexp !clibs_path clibs)