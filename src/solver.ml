let z3ctx = Z3.mk_context []
let z3opt = z3ctx |> Z3.Optimize.mk_opt

let get_num_students csv_file = csv_file |> Constraint.PreferenceTuple.of_file |> List.length

let solve num_papers pref_csv_file =
  let num_students = get_num_students pref_csv_file in
  (* Make variables *)
  let vars = Constraint.Variables.make z3ctx num_students num_papers in
  (* Add constraints *)
  let constraints = Constraint.make z3ctx vars in
  Z3.Optimize.add z3opt constraints;
  (* Run solver *)
  let objective = Constraint.make_objective z3ctx pref_csv_file vars in
  Z3.Optimize.maximize z3opt objective |> ignore

let report optimizer =
  optimizer |> Z3.Optimize.to_string
  |> Format.fprintf Format.std_formatter "[Debug] Optimize:\n%s\n";
  match Z3.Optimize.check z3opt with
  | Z3.Solver.SATISFIABLE -> (
      print_endline "SATISFIABLE";
      match Z3.Optimize.get_model z3opt with
      | Some model ->
          (* TODO: eval variables *)
          model |> Z3.Model.to_string
          |> Format.fprintf Format.std_formatter "MODEL:\n%s\n"
      | None -> failwith "Impossible")
  | Z3.Solver.UNSATISFIABLE -> print_endline "UNSATISFIABLE"
  | Z3.Solver.UNKNOWN ->
      z3opt |> Z3.Optimize.get_reason_unknown
      |> Format.fprintf Format.std_formatter "UNKNOWN ERROR\nReason:\n%s\n"
