

open Effect
open Effect.Deep

type _ Effect.t += Yield : int -> unit t

type tree =
| Leaf
| Node of tree * int * tree

type generator =
| Empty
| Thunk of int * (unit -> generator)

let rec make = function
  | 0 -> Leaf
  | n -> let t = make (n-1) in Node (t, n, t)

let rec iterate = function
  | Leaf -> ()
  | Node (l, v, r) -> iterate l; perform (Yield v); iterate r

let rec generate f =
  match f () with
    | () -> Empty
    | effect (Yield v), k -> Thunk (v, fun () -> continue k ())

let rec sum a = function
  | Empty -> a
  | Thunk (v, f) -> sum (v + a) (f ())

let run n =
  sum 0 (generate (fun () -> iterate (make n)))

let main () =
  let n = try int_of_string (Sys.argv.(1)) with _ -> 25 in
  let r = run n in
  Printf.printf "%d\n" r

let _ = main ()

