effect Choose : unit -> bool

type tree =
| Leaf
| Node of tree * int * tree

let operator x y = abs (x - (503 * y) + 37) mod 1009

let rec make = function
  | 0 -> Leaf
  | n -> let t = make (n-1) in Node (t,n,t)

let run n =
  let tree = make n in
  let state = ref 0 in

  let rec explore t =
    match t with
    | Leaf -> !state
    | Node (l, v, r) ->
      let next = if (perform (Choose ())) then l else r in
      state := operator !state v;
      operator v (explore next) in

  let paths () =
    match explore tree with
    | _x -> [_x]
    | effect (Choose ()) k ->
      let l = continue (Obj.clone_continuation k) true in
      let r = continue k false in
      l @ r in

  let rec loop i =
    if i = 0
      then !state
      else (
        state := List.fold_left max 0 (paths ());
        loop (i - 1)
      ) in

  loop 10

let main () =
  let n = try int_of_string (Sys.argv.(1)) with _ -> 5 in
  let r = run n in
  Printf.printf "%d\n" r

let _ = main ()

