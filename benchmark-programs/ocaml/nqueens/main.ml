
effect Pick : int -> int
exception Fail

let rec safe queen diag xs =
  match xs with
  | [] -> true
  | q :: qs -> if (queen <> q && queen <> q + diag && queen <> q - diag)
    then safe queen (diag + 1) qs
    else false

let rec place size column : int list =
  if column = 0
    then []
    else begin
      let rest = place size (column - 1) in
      let next = perform (Pick size) in
      if safe next 1 rest
        then next :: rest
        else raise Fail
    end

let run n =
  match place n n with
  | _x -> 1
  | exception Fail -> 0
  | effect (Pick size) k ->
      let rec loop i a =
        if i = size then (a + continue k i)
        else loop (i+1) (a + continue (Obj.clone_continuation k) i)
      in loop 1 0

let main () =
  let n = try int_of_string Sys.argv.(1) with _ -> 5 in
  let r = run n in
  Printf.printf "%d\n" r

let _ = main()

