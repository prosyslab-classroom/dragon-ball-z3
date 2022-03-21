# Dragon Ball Z3: A Wish-granting Theorem Prover for Everyone
<img width="200" alt="dbz3" src="asset/dbz3.png">

## Input
Dragon Ball Z3 (DBZ3) takes a `csv` file as an input.
Each line contains a tuple `(wish-1, wish-2, wish-3)` where
`wish-N` is the id of the `N`th-preferred wish.
The line number corresponds to the student id (1 to N).
We assume 5, 3, or 1 happy points will be given if a student
is assigned to `with-1`, `with-2` or `with-3`, respectively.

## Output
DBZ3 prints out an assignment from `sid`s to `wish`s that maximizes the total
happiness score of all students.

## Setup
This project can be built on the provided OCaml environment (Docker image or KCLOUD vm) to students.
After running `make` under the project root directory, one can check `dbz3` generated.

## Run
```
./dbz3 [ NUM_PAPERS ] [ PREFERENCE_CSV ]
```
For example, `./dbz3 3 test/example1.csv` command assumes three papers and each student's wish
is denoted as a row of [test/example1.csv](test/example1.csv).
The number of students is the same as the number of lines of the csv file.
