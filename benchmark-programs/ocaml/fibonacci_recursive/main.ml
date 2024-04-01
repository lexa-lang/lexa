
let rec fibonacci n =
  if (n = 0)
    then 0
    else if (n = 1)
      then 1
      else fibonacci (n - 1) + fibonacci (n - 2)

let main () =
  let n = try int_of_string (Sys.argv.(1)) with _ -> 5 in
  let r = fibonacci n in
  Printf.printf "%d\n" r

let _ = main ()

