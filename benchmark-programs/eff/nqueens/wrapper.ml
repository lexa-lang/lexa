let n = try int_of_string Sys.argv.(1) with _ -> 5

let _ = Printf.printf "%d\n" (Generated.run n)
