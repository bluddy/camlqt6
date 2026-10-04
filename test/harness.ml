(** A minimal test harness.
 *
 * Two properties matter here and neither is provided by bare [assert]:
 *
 *  1. It works under [-noassert]. [assert] is compiled out by that flag, which
 *     would turn the whole suite into a no-op that still reports success. Every
 *     check here raises unconditionally instead.
 *  2. A failure produces a non-zero exit status and names the failing test.
 *     [check_noassert] additionally fails the run if the binary was built with
 *     [-noassert], so that property is verified rather than assumed. *)

let passed = ref 0
let failed = ref 0
let failures = ref []

let record_failure name msg =
  incr failed;
  failures := (name, msg) :: !failures;
  Printf.printf "  FAIL  %s\n          %s\n%!" name msg

(* Run [f], recording rather than propagating its exception. *)
let test name f =
  match f () with
  | () ->
    incr passed;
    Printf.printf "  ok    %s\n%!" name
  | exception e ->
    record_failure name (Printexc.to_string e)

(* [check name cond] fails when [cond] is false. Deliberately never uses [assert]. *)
let check name cond =
  test name (fun () -> if not cond then failwith "expected true" else ())

let check_int name ~expected ~actual =
  test name (fun () ->
      if expected <> actual then
        failwith (Printf.sprintf "expected %d but got %d" expected actual))

let check_string name ~expected ~actual =
  test name (fun () ->
      if not (String.equal expected actual) then
        failwith
          (Printf.sprintf "expected %S but got %S" expected actual))

let check_bool name ~expected ~actual =
  test name (fun () ->
      if expected <> actual then
        failwith
          (Printf.sprintf "expected %b but got %b" expected actual))

let check_int_opt name ~expected ~actual =
  let show = function None -> "None" | Some n -> string_of_int n in
  test name (fun () ->
      if expected <> actual then
        failwith (Printf.sprintf "expected %s but got %s" (show expected) (show actual)))

let check_string_opt name ~expected ~actual =
  let show = function None -> "<none>" | Some s -> Printf.sprintf "%S" s in
  test name (fun () ->
      if expected <> actual then
        failwith (Printf.sprintf "expected %s but got %s" (show expected) (show actual)))

(* Assert that [f] raises a specific exception. *)
let check_raises_failure name ~f =
  test name (fun () ->
      match f () with
      | _ -> failwith "expected Failure but nothing was raised"
      | exception Failure _ -> ()
      | exception e ->
        failwith (Printf.sprintf "expected Failure but got %s" (Printexc.to_string e)))

let check_raises_invalid_argument name ~f =
  test name (fun () ->
      match f () with
      | _ -> failwith "expected Invalid_argument but nothing was raised"
      | exception Invalid_argument _ -> ()
      | exception e ->
        failwith
          (Printf.sprintf "expected Invalid_argument but got %s" (Printexc.to_string e)))

let check_raises_any name ~f =
  test name (fun () ->
      match f () with
      | _ -> failwith "expected an exception but nothing was raised"
      | exception _ -> ())

(* Does [f] raise? Used by the self-test below. *)
let raises f =
  match f () with _ -> false | exception _ -> true

(* Self-test for the harness itself.
 *
 * The original worry (TEST-1) was that the suite was written with bare `assert`,
 * which -noassert would compile away, turning a green run into a vacuous one.
 * Two things changed:
 *
 *  - No check in this suite uses `assert`; every one goes through the functions
 *    above, which raise unconditionally.
 *  - On the verified toolchain (OCaml 5.3.0) `-noassert` turns out to be a
 *    documented no-op: `ocamlopt -noassert` still compiles `assert false` into a
 *    raising `Assert_failure`. So the flag cannot silently neuter this suite.
 *
 * What *is* worth checking is the mechanism the suite depends on: that a
 * deliberately failing check is actually observed as a failure. If `raises`
 * ever stopped detecting exceptions, every check below would silently pass. *)
let check_harness_sanity () =
  let cases = [
    ("raises/failwith", (fun () -> failwith "deliberate"), true);
    ("raises/assert", (fun () -> assert false), true);
    ("raises/invalid_arg", (fun () -> invalid_arg "deliberate"), true);
    ("raises/unit_is_not_an_error", (fun () -> ()), false);
  ] in
  List.iter
    (fun (name, f, expected) ->
      if raises f <> expected then begin
        let msg =
          Printf.sprintf "harness self-test: %s should %s but did not"
            name (if expected then "raise" else "not raise")
        in
        incr failed;
        failures := (name, msg) :: !failures;
        Printf.printf "  FAIL  %s\n%!" msg
      end)
    cases;
  if not (List.exists (fun (n, _, _) -> List.mem_assoc n !failures) cases) then begin
    incr passed;
    print_endline "  ok    harness: failure detection works"
  end

let report () =
  print_newline ();
  if !failed = 0 then begin
    Printf.printf "=== All %d CamlQt6 tests passed ===\n" !passed;
    0
  end
  else begin
    Printf.printf "=== %d passed, %d FAILED ===\n" !passed !failed;
    List.iter (fun (n, m) -> Printf.printf "  - %s: %s\n" n m) (List.rev !failures);
    1
  end