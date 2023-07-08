let n = try int_of_string Sys.argv.(1) with _ -> 300

let _ = Printf.printf "%d\n" (Generated.run n n)
