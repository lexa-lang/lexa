effect Emit : int -> unit
effect Get : unit -> int

type node =
| Constant
| While of node * node
| If of node * node * node

let constant = 0
let newline = 10
let space = 32
let star = 42
let question = 63

let rec make = function
  | 0 -> Constant
  | n -> While (Constant, make (n - 1))

let indent n =
  let rec loop i =
    if i < n then (
      perform (Emit space);
      loop (i + 1)
    ) in
  loop 0

let rec visit n =
  let l = perform (Get ()) in
  indent l;
  match 
    (match n with
    | Constant ->
      perform (Emit constant)
    | While (cond, body) ->
      perform (Emit star);
      visit cond;
      perform (Emit newline);
      visit body
    | If (cond, then_br, else_br) ->
      perform (Emit question);
      visit cond;
      perform (Emit newline);
      visit then_br;
      perform (Emit newline);
      visit else_br);
    perform (Emit newline)
  with
  | () -> ()
  | effect (Get _) k ->
    continue k (l + 1)

let run n =
  let result = ref 0 in
  let ast = make n in
  (match visit ast with
  | () -> ()
  | effect (Emit i) k ->
    result := !result + i;
    continue k ()
  | effect (Get _) k ->
    continue k 0);
  !result

let repeat n =
  let rec loop i acc =
    if i = 0 then
      acc
    else
      let r = run n in
      loop (i - 1) (acc + r) in
  loop 300 0

let main () =
  let n = try int_of_string (Sys.argv.(1)) with _ -> 5 in
  let r = repeat n in
  Printf.printf "%d\n" r

let _ = main ()