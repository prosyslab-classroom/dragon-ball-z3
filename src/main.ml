module F = Format

let main argv =
  let usageMsg =
    "[Error] Usage: assemble [ NUM_PAPERS ] [ PREFERENCE_CSV ]"
  in
  match argv with
  | [| _; num_papers; pref_csv_file |] ->
      let num_papers = int_of_string num_papers in
      Solver.solve num_papers pref_csv_file;
      Solver.report Solver.z3opt
  | _ ->
      prerr_endline usageMsg;
      exit 1

let _ = main Sys.argv
