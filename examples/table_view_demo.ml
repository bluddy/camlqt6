open Oqt6

type employee = {
  id : int;
  name : string;
  department : string;
  role : string;
  salary : int;
}

let initial_employees = [
  { id = 101; name = "Ada Lovelace"; department = "Engineering"; role = "Pioneer / Lead"; salary = 185000 };
  { id = 102; name = "Alan Turing"; department = "Research"; role = "Chief Scientist"; salary = 190000 };
  { id = 103; name = "Grace Hopper"; department = "Systems"; role = "Compiler Architect"; salary = 175000 };
  { id = 104; name = "John McCarthy"; department = "AI Lab"; role = "Lisp Lead"; salary = 170000 };
  { id = 105; name = "Robin Milner"; department = "Language Design"; role = "Type Theorist"; salary = 165000 };
  { id = 106; name = "Xavier Leroy"; department = "Language Design"; role = "OCaml Architect"; salary = 180000 };
]

let () =
  let app = App.create () in
  let win = MainWindow.create () in
  Widget.set_window_title win "OQt6 Model/View Architecture Demo";
  Widget.resize win ~width:950 ~height:600;

  let central = Widget.create ~parent:win () in
  MainWindow.set_central_widget win central;

  let root_layout = Layout.VBox.create ~parent:central () in
  Widget.set_layout central root_layout;

  (* Form toolbar to add new employees *)
  let form_box = Widget.create ~parent:central () in
  let form_layout = Layout.HBox.create ~parent:form_box () in
  Widget.set_layout form_box form_layout;
  Layout.add_widget root_layout form_box;

  let lbl_name = Label.create ~text:"Name:" ~parent:form_box () in
  Layout.add_widget form_layout lbl_name;
  let edit_name = LineEdit.create ~parent:form_box () in
  LineEdit.set_placeholder_text edit_name "Full name...";
  Layout.add_widget form_layout edit_name;

  let lbl_dept = Label.create ~text:"Dept:" ~parent:form_box () in
  Layout.add_widget form_layout lbl_dept;
  let combo_dept = ComboBox.create ~parent:form_box () in
  ComboBox.add_items combo_dept ["Engineering"; "Research"; "Systems"; "Language Design"; "AI Lab"];
  Layout.add_widget form_layout combo_dept;

  let lbl_role = Label.create ~text:"Role:" ~parent:form_box () in
  Layout.add_widget form_layout lbl_role;
  let edit_role = LineEdit.create ~parent:form_box () in
  LineEdit.set_placeholder_text edit_role "Role title...";
  Layout.add_widget form_layout edit_role;

  let lbl_salary = Label.create ~text:"Salary:" ~parent:form_box () in
  Layout.add_widget form_layout lbl_salary;
  let spin_salary = SpinBox.create ~parent:form_box () in
  SpinBox.set_range spin_salary ~min:50000 ~max:500000;
  SpinBox.set_single_step spin_salary 5000;
  SpinBox.set_value spin_salary 150000;
  SpinBox.set_prefix spin_salary "$";
  Layout.add_widget form_layout spin_salary;

  let btn_add = Button.create ~text:"Add Record" ~parent:form_box () in
  Layout.add_widget form_layout btn_add;

  let btn_remove = Button.create ~text:"Delete Selected" ~parent:form_box () in
  Layout.add_widget form_layout btn_remove;

  (* Employees state *)
  let employees = ref (Array.of_list initial_employees) in
  let next_id = ref 107 in

  (* Create functional table model *)
  let table_model = TableModel.create
    ~parent:central
    ~row_count:(fun () -> Array.length !employees)
    ~col_count:(fun () -> 5)
    ~data:(fun row col ->
      if row >= 0 && row < Array.length !employees then
        let emp = (!employees).(row) in
        match col with
        | 0 -> string_of_int emp.id
        | 1 -> emp.name
        | 2 -> emp.department
        | 3 -> emp.role
        | 4 -> Printf.sprintf "$%d" emp.salary
        | _ -> ""
      else
        "")
    ~header_data:(fun sec orient ->
      if orient = `Horizontal then
        match sec with
        | 0 -> "ID"
        | 1 -> "Name"
        | 2 -> "Department"
        | 3 -> "Role"
        | 4 -> "Salary"
        | _ -> ""
      else
        string_of_int (sec + 1))
    ()
  in

  (* Main Table View *)
  let table_view = TableView.create ~parent:central () in
  TableView.set_model table_view table_model;
  TableView.set_selection_behavior table_view `Select_rows;
  TableView.set_selection_mode table_view `Single_selection;
  TableView.set_alternating_row_colors table_view true;
  TableView.set_sorting_enabled table_view true;

  let h_header = TableView.horizontal_header table_view in
  HeaderView.set_stretch_last_section h_header true;
  HeaderView.set_section_resize_mode h_header ~section:1 `Stretch;
  HeaderView.set_section_resize_mode h_header ~section:2 `Resize_to_contents;
  HeaderView.set_section_resize_mode h_header ~section:3 `Resize_to_contents;

  Layout.add_widget root_layout ~stretch:1 table_view;

  let status_bar = MainWindow.status_bar win in
  StatusBar.show_message status_bar "Ready. 6 employee records loaded in zero-copy functional table model.";

  (* Selection changed handling *)
  let sel_model = TableView.selection_model table_view in
  ItemSelectionModel.on_current_changed sel_model (fun row _col ->
    if row >= 0 && row < Array.length !employees then
      let emp = (!employees).(row) in
      let msg = Printf.sprintf "Selected: #%d - %s | %s | %s | $%d"
        emp.id emp.name emp.department emp.role emp.salary in
      StatusBar.show_message status_bar msg
  );

  (* Add employee action *)
  Button.on_clicked btn_add (fun () ->
    let name = LineEdit.text edit_name in
    let dept = ComboBox.current_text combo_dept in
    let role = LineEdit.text edit_role in
    let salary = SpinBox.value spin_salary in
    if String.trim name = "" then
      MessageBox.warning ~parent:win ~title:"Validation Error" ~text:"Please enter an employee name." ()
    else begin
      let new_emp = { id = !next_id; name; department = dept; role; salary } in
      incr next_id;
      employees := Array.append !employees [| new_emp |];
      TableModel.notify_reset table_model;
      LineEdit.set_text edit_name "";
      LineEdit.set_text edit_role "";
      StatusBar.show_message status_bar (Printf.sprintf "Added %s successfully." name)
    end
  );

  (* Delete employee action *)
  Button.on_clicked btn_remove (fun () ->
    let rows = ItemSelectionModel.selected_rows sel_model in
    match rows with
    | [] ->
        MessageBox.information ~parent:win ~title:"Notice" ~text:"Please select a row to delete." ()
    | row :: _ ->
        if row >= 0 && row < Array.length !employees then begin
          let emp = (!employees).(row) in
          let confirm = MessageBox.question ~parent:win ~title:"Confirm Delete"
            ~text:(Printf.sprintf "Are you sure you want to remove %s?" emp.name) () in
          if confirm then begin
            let list = Array.to_list !employees in
            let filtered = List.filteri (fun i _ -> i <> row) list in
            employees := Array.of_list filtered;
            TableModel.notify_reset table_model;
            StatusBar.show_message status_bar (Printf.sprintf "Removed record #%d." emp.id)
          end
        end
  );

  Widget.show win;
  exit (App.exec app)
