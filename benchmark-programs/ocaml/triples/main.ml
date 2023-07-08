
effect Flip : unit -> bool
exception Fail

let rec choice n =
  if (n < 1)
    then raise Fail
    else if (perform (Flip ()))
      then n
      else choice (n - 1)

let triple n s =
  let i = choice n in
  let j = choice (i - 1) in
  let k = choice (j - 1) in
  if (i + j + k = s)
    then (i, j, k)
    else raise Fail

let hash (a,b,c) =
  (53 * a + 2809 * b + 148877 * c) mod 1000000007 (* 2089 = 53 * 53, 148877 = 53 * 2089  *)

let run n s =
  try
  try
    hash (triple n s)
  with
  | Fail ->
     0
  with
  | effect (Flip ()) k ->
    let l = continue (Obj.clone_continuation k) true in
    let r = continue k false in
    (l + r) mod 1000000007

let main () =
  let n = try int_of_string (Sys.argv.(1)) with _ -> 10 in
  let r = run n n in
  Printf.printf "%d\n" r

let _ = main ()

