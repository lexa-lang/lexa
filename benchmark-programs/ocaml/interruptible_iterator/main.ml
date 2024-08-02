open Effect
open Effect.Deep

type _ Effect.t += Replace : int -> unit t
type _ Effect.t += Behead : unit -> unit t
type _ Effect.t += Yield : int -> (unit -> unit) t

let rec loop (it : int list) : int list =
  let hd = ref (List.hd it)
  in
  let tl = List.tl it
  in
  let beheaded = ref false in
  try
    perform (Yield (!hd)) ();
    let newtl = match tl with
      | [] -> []
      | _ :: _ -> 
        (try
          loop(tl)
        with
        | effect (Behead ()), k -> (beheaded := true; continue k ()))
    in
    if !beheaded then !hd :: List.tl newtl
    else !hd :: newtl
  with
  | effect (Replace x), k -> (hd := x; continue k ())

let run n =
  let l = List.init (2 * n + 1) (fun i -> i - n) in
  let beheaded = ref false in
  try
    let res = loop l in
    if !beheaded then List.tl res
    else res
  with
  | effect (Yield x), k -> 
    if x < 0 then continue k (fun _ -> perform (Behead ()))
    else continue k (fun _ -> perform (Replace (x * 2)))
  | effect (Behead ()), k -> (beheaded := true; continue k ())

let rec step i acc n_jobs =
  if i = 0 then acc
  else step (i - 1) (acc + List.fold_left (+) 0 (run n_jobs)) n_jobs

let repeat n_jobs =
  (* loop count reduced from 1000 *)
  step 10 0 n_jobs

let main () =
  let n = try int_of_string Sys.argv.(1) with _ -> 5 in
  let r = repeat n in
  Printf.printf "%d\n" r

let _ = main ()