let z3ctx = Z3.mk_context []
let z3opt = z3ctx |> Z3.Optimize.mk_opt

let solve _ _ _ =
  (* Make variables *)
  let x = Z3.Arithmetic.Integer.mk_const_s z3ctx "x" in
  let y = Z3.Arithmetic.Integer.mk_const_s z3ctx "y" in
  let zero = Z3.Arithmetic.Integer.mk_numeral_i z3ctx 0 in
  let one = Z3.Arithmetic.Integer.mk_numeral_i z3ctx 1 in
  let sum = Z3.Arithmetic.mk_add z3ctx [ x; y ] in
  (* Add constraints *)
  Z3.Optimize.add z3opt
    [ Z3.Arithmetic.mk_lt z3ctx x zero; Z3.Arithmetic.mk_lt z3ctx y one ];
  Z3.Optimize.maximize z3opt sum |> ignore

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
