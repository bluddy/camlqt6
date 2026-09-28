(** OQt6 Phase 5 Demo: Declarative & Reactive UI
    Showcases functional reactive state bindings, declarative UI trees,
    and automatic synchronization with zero boilerplate. *)

open Oqt6

let () =
  (* --- 1. Reactive State Definitions --- *)
  let input_text = State.create "" in
  let tasks = State.create [
    "Build cross-platform Qt 6 bindings in OCaml";
    "Implement safe memory model and QPointer tracking";
    "Create zero-copy functional TableModel";
    "Design reactive declarative UI DSL";
  ] in
  let filter_pro = State.create false in
  let progress_val = State.create 75 in
  let status_msg = State.create "Application initialized." in

  (* Derived reactive states *)
  let task_count = State.map List.length tasks in
  let task_count_text = State.map (fun n -> Printf.sprintf "Total Tasks Pending: %d" n) task_count in
  let can_add = State.map (fun s -> String.trim s <> "") input_text in
  let progress_summary = State.map (fun p -> Printf.sprintf "Overall Project Completion: %d%%" p) progress_val in

  (* Formatted task list representation *)
  let formatted_tasks = State.map (fun list ->
    let buf = Buffer.create 256 in
    List.iteri (fun idx task ->
      Buffer.add_string buf (Printf.sprintf " [%d] %s\n" (idx + 1) task)
    ) list;
    Buffer.contents buf
  ) tasks in

  (* Actions *)
  let add_task () =
    let text = String.trim (State.get input_text) in
    if text <> "" then begin
      State.update tasks (fun current -> current @ [text]);
      State.set input_text "";
      State.set status_msg (Printf.sprintf "Added task: \"%s\"" text)
    end
  in

  let clear_tasks () =
    State.set tasks [];
    State.set status_msg "Cleared all tasks."
  in

  (* --- 2. Declarative UI Component Tree --- *)
  let ui =
    Dsl.window ~title:"OQt6 Declarative Reactive Todo & Dashboard" ~width:720 ~height:600 ~status_bar:status_msg (
      Dsl.vbox ~spacing:12 ~margin:16 [
        (* Header banner *)
        Dsl.label ~style:"font-size: 16pt; font-weight: bold; color: #2c3e50;"
          "OQt6 Declarative Reactive Workbench";

        Dsl.label_s ~style:"font-size: 11pt; color: #7f8c8d;"
          task_count_text;

        (* Task Input Bar *)
        Dsl.hbox ~spacing:8 [
          Dsl.line_edit ~placeholder:"Enter a new task description..." ~text:input_text ();
          Dsl.button ~style:"background-color: #27ae60; color: white; padding: 6px 14px; font-weight: bold;"
            ~enabled_s:can_add ~on_click:add_task "Add Task";
          Dsl.button ~style:"background-color: #e74c3c; color: white; padding: 6px 14px;"
            ~on_click:clear_tasks "Clear All";
        ];

        (* Tabbed Views *)
        Dsl.tabs [
          ("Task View",
           Dsl.vbox ~spacing:8 [
             Dsl.label ~style:"font-weight: bold; color: #34495e;" "Active Task Roster:";
             Dsl.text_edit ~read_only:true ~text:formatted_tasks
               ~style:"font-family: monospace; font-size: 11pt; background: #fafafa; border: 1px solid #dcdcdc; border-radius: 4px;" ();
           ]
          );

          ("Reactive Dashboard",
           Dsl.vbox ~spacing:14 [
             (* Progress Group *)
             Dsl.group ~title:"Project Progress & Metrics" (
               Dsl.vbox ~spacing:10 [
                 Dsl.label_s ~style:"font-weight: bold; color: #2980b9;" progress_summary;
                 Dsl.progress_bar ~min:0 ~max:100 ~value:progress_val ~format:"%p%" ();
                 Dsl.hbox ~spacing:10 [
                   Dsl.label "Adjust via Slider:";
                   Dsl.slider ~min:0 ~max:100 ~orientation:`Horizontal ~value:progress_val ();
                   Dsl.label "or SpinBox:";
                   Dsl.spin_box ~min:0 ~max:100 ~suffix:"%" ~value:progress_val ();
                 ];
               ]
             );

             (* Reactive Conditional View *)
             Dsl.group ~title:"Conditional Reactive Views" (
               Dsl.vbox ~spacing:8 [
                 Dsl.check_box ~checked:filter_pro "Enable Pro Features & Advanced Diagnostics";
                 Dsl.cond filter_pro
                   ~true_node:(
                     Dsl.hbox ~spacing:8 [
                       Dsl.label ~style:"color: #27ae60; font-weight: bold;" "Status: PRO UNLOCKED";
                       Dsl.button ~on_click:(fun () -> State.set status_msg "Diagnostic scan complete: All subsystems nominal.")
                         "Run Diagnostics";
                     ]
                   )
                   ~false_node:(
                     Dsl.label ~style:"color: #95a5a6; font-style: italic;"
                       "Pro features disabled. Check the box above to reveal advanced options."
                   );
               ]
             );

             Dsl.stretch ();
           ]
          );
        ];

        Dsl.stretch ();
      ]
    )
  in

  (* --- 3. Mount and Execute --- *)
  exit (Dsl.run ui)
