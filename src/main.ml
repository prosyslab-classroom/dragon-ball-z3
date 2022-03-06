module F = Format

let main argv =
  let usageMsg =
    "[Error] Usage: assemble [ NUM_STUDENTS ] [ NUM_PAPERS ] [ PREFERENCE_CSV ]"
  in
  match argv with
  | [| _; num_students; num_papers; pref_csv_file |] ->
      Solver.solve num_students num_papers pref_csv_file;
      Solver.report Solver.z3opt
  | _ ->
      prerr_endline usageMsg;
      exit 1

let _ = main Sys.argv
