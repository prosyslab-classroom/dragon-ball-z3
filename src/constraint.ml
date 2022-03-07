module PreferenceTuple = struct
  type t = { sid : int; preferences : (int * int) list }

  let of_file filename =
    let file_ic = open_in filename in
    let rec parse ic sid acc =
      match input_line ic with
      | line ->
          let toks = String.split_on_char ',' line in
          let first = List.nth toks 0 |> int_of_string in
          let second = List.nth toks 1 |> int_of_string in
          let third = List.nth toks 2 |> int_of_string in
          let new_acc =
            { sid; preferences = [ (first, 5); (second, 3); (third, 1) ] }
            :: acc
          in
          parse ic (sid + 1) new_acc
      | exception End_of_file -> acc |> List.rev
    in
    parse file_ic 0 []

  let to_objective z3ctx paper_vars t =
    t.preferences
    |> List.map (fun (wish, happiness) ->
           let x = List.nth paper_vars wish in
           let w = Z3.Arithmetic.Integer.mk_numeral_i z3ctx happiness in
           Z3.Arithmetic.mk_mul z3ctx [ w; x ])
    |> Z3.Arithmetic.mk_add z3ctx
end

let make_objective z3ctx pref_csv_file vars =
  let pref_tuples = PreferenceTuple.of_file pref_csv_file in
  List.map
    (fun ptup ->
      let paper_vars = List.nth vars ptup.PreferenceTuple.sid in
      PreferenceTuple.to_objective z3ctx paper_vars ptup)
    pref_tuples
  |> Z3.Arithmetic.mk_add z3ctx

module Variables = struct
  type t = Z3.Expr.expr list list

  let make z3ctx num_students num_papers =
    let rec loop i n f acc =
      if i > n then assert false;
      if i = n then acc else loop (i + 1) n f (f i acc)
    in
    loop 0 num_students
      (fun sid matrix ->
        let sid = string_of_int sid in
        let row =
          loop 0 num_papers
            (fun pid row ->
              let pid = string_of_int pid in
              Z3.Arithmetic.Integer.mk_const_s z3ctx ("x" ^ sid ^ pid) :: row)
            []
          |> List.rev
        in
        row :: matrix)
      []
    |> List.rev

  let get sid pid vars =
    try
      let row = List.nth vars sid in
      List.nth row pid
    with _ -> failwith "Variables: index not available"
end

let make_vars_zero_or_one z3ctx vars =
  let zero = Z3.Arithmetic.Integer.mk_numeral_i z3ctx 0 in
  let one = Z3.Arithmetic.Integer.mk_numeral_i z3ctx 1 in
  List.fold_left
    (fun constraints row ->
      List.fold_left
        (fun cs v ->
          Z3.Arithmetic.mk_ge z3ctx v zero
          :: Z3.Arithmetic.mk_le z3ctx v one
          :: cs)
        constraints row)
    [] vars

let make_unique_paper_selection z3ctx vars =
  let one = Z3.Arithmetic.Integer.mk_numeral_i z3ctx 1 in
  let sums =
    List.fold_left
      (fun acc row ->
        if acc = [] then row
        else
          List.fold_left2
            (fun new_acc col_sum v ->
              Z3.Arithmetic.mk_add z3ctx [ col_sum; v ] :: new_acc)
            [] acc row
          |> List.rev)
      [] vars
  in
  List.fold_left
    (fun constraints sum ->
      Z3.Arithmetic.mk_ge z3ctx sum one
      :: Z3.Arithmetic.mk_le z3ctx sum one
      :: constraints)
    [] sums

let make_single_choice z3ctx vars =
  let one = Z3.Arithmetic.Integer.mk_numeral_i z3ctx 1 in
  List.fold_left
    (fun acc row ->
      let sum = Z3.Arithmetic.mk_add z3ctx row in
      Z3.Arithmetic.mk_ge z3ctx sum one
      :: Z3.Arithmetic.mk_le z3ctx sum one
      :: acc)
    [] vars

let make z3ctx vars =
  let c_vars_zero_or_one = make_vars_zero_or_one z3ctx vars in
  let c_unique_paper_selection = make_unique_paper_selection z3ctx vars in
  let c_single_choice = make_single_choice z3ctx vars in
  c_vars_zero_or_one @ c_unique_paper_selection @ c_single_choice
