open Effect
open Effect.Deep

type _ Effect.t += Yield: unit -> unit t

type tree =
| Leaf
| Node of tree * int * tree

let operator x y = abs (x - (503 * y) + 37) mod 1009

let rec make = function
  | 0 -> Leaf
  | n -> 
      let t = make (n-1) in Node (t,n,t)

let run n =
  let tree = make n in
  let state = ref 0 in
  let storage: (unit, int) continuation option ref = ref None in
  let yield_f action =
    match action () with
    | x -> x
    | effect (Yield ()), k ->
      let peer = !storage in
      storage := Some (k);
      match peer with
      | None -> 0
      | Some k -> continue k ()
  in
  let rec explore t rev =
    perform (Yield ());
    match t with
    | Leaf -> !state
    | Node (l, v, r) ->
      state := operator !state v;
      if rev
        then v + explore l rev + explore r rev
        else v + explore r rev + explore l rev
  in
  let search () =
    yield_f (fun () -> explore tree true);
    yield_f (fun () -> explore tree false)
  in
  let rec loop i =
    if i = 0
      then !state
      else (
        state := search ();
        loop (i - 1)
      )
  in
  loop 1000

let main () =
  let n = try int_of_string (Sys.argv.(1)) with _ -> 5 in
  let r = run n in
  Printf.printf "%d\n" r

let _ = main ()