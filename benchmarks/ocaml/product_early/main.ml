
exception Done of int

let rec product = function
  | [] -> 0
  | (y :: ys) -> if y = 0 then raise (Done 0) else y * product ys

let rec enumerate i =
  if i < 0
    then []
    else i :: enumerate (i - 1)

let run_product xs =
  try
    product xs
  with
  | (Done r) -> r

let rec run n =
  let xs = enumerate 1000 in
  let rec loop i a =
    if i = 0
      then a
      else loop (i - 1) (a + run_product xs)
  in
  loop n 0

let main () =
  let n = try int_of_string (Sys.argv.(1)) with _ -> 5 in
  let r = run n in
  Printf.printf "%d\n" r

let _ = main ()

