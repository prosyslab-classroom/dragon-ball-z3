module F = Format

let z3ctx = Z3.mk_context []
let z3opt = Z3.Optimize.mk_opt z3ctx

let get_num_students csv_file =
  csv_file |> Constraint.PreferenceTuple.of_file |> List.length

let solve num_papers pref_csv_file =
  let num_students = get_num_students pref_csv_file in
  (* Make variables *)
  let vars = Constraint.Variables.make z3ctx num_students num_papers in
  (* Add constraints *)
  let constraints = Constraint.make z3ctx vars in
  Z3.Optimize.add z3opt constraints;
  (* Run solver *)
  let objective = Constraint.make_objective z3ctx pref_csv_file vars in
  let _ = Z3.Optimize.maximize z3opt objective in
  vars

let eval model vars =
  let one = Z3.Arithmetic.Integer.mk_numeral_i z3ctx 1 in
  List.iteri
    (fun sid papers ->
      List.iteri
        (fun pid v ->
          match Z3.Model.eval model v false with
          | Some e ->
              if Z3.Expr.equal e one then
                F.fprintf F.std_formatter "Student %d -> Paper %d\n" (sid + 1)
                  (pid + 1)
          | None -> ())
        papers)
    vars;
  let objective = z3opt |> Z3.Optimize.get_objectives |> Fun.flip List.nth 0 in
  let max =
    Z3.Model.eval model objective false
    |> Option.get |> Z3.Arithmetic.Integer.numeral_to_string |> int_of_string
    |> abs
  in
  F.fprintf F.std_formatter "Max score: %d\n" max

let report z3opt vars =
  match Z3.Optimize.check z3opt with
  | Z3.Solver.SATISFIABLE -> (
      print_endline "SATISFIABLE";
      match Z3.Optimize.get_model z3opt with
      | Some model -> eval model vars
      | None -> failwith "Impossible")
  | Z3.Solver.UNSATISFIABLE -> print_endline "UNSATISFIABLE"
  | Z3.Solver.UNKNOWN ->
      z3opt |> Z3.Optimize.get_reason_unknown
      |> Format.fprintf Format.std_formatter "UNKNOWN ERROR\nReason:\n%s\n"
