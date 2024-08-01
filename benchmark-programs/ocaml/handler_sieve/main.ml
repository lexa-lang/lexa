open Effect
open Effect.Deep

type _ Effect.t += Prime: int -> bool t

let rec primes i n a =
  if (i >= n)
    then a
    else
      if perform (Prime i)
        then
          try
            primes (i + 1) n (a + i)
          with
          | effect (Prime e), k ->
            if (e mod i = 0)
              then continue k false
              else continue k (perform (Prime e))
        else
          primes (i + 1) n a

let run n =
  try
    primes 2 n 0
  with
  | effect (Prime e), k -> continue k true

let main () =
  let n = try int_of_string (Sys.argv.(1)) with _ -> 10 in
  let r = run n in
  Printf.printf "%d\n" r

let _ = main ()