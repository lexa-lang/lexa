
open Queue
effect Yield : unit -> unit
effect Fork : (unit -> unit) -> unit
effect Tick : unit -> unit

effect Exc : unit -> unit
let rec driver q =
  try
    let k = Queue.pop q in
    continue k ();
    driver q
  with
  | Queue.Empty -> ()
  | effect (Exc ()) k ->
      ()

let rec spawn f (q: (unit, 'b) continuation Queue.t) =
  try
    f ()
  with
  | effect (Yield ()) k ->
      Queue.push k q
  | effect (Fork f) k ->
      Queue.push k q;
      spawn f q

let scheduler f =
  let q = Queue.create () in
  spawn f q;
  driver q

let job () = perform (Yield ())

let rec jobs n_jobs =
  if (n_jobs == 0)
    then ()
    else (
      perform (Fork job);
      perform (Tick ());
      jobs (n_jobs - 1))

let run n_jobs =
  let c = ref (0 : int) in
  let _ = 
    try
      scheduler(fun () -> jobs n_jobs)
    with
    | effect (Tick ()) k -> c := !c + 1; continue k ()
  in
  !c

let rec step i acc n_jobs =
  if i = 0
    then acc
    else 
      let r = run n_jobs in
      step (i - 1) (acc + r) n_jobs

let repeat n_jobs =
  step 100 0 n_jobs

let main () =
  let n = try int_of_string (Sys.argv.(1)) with _ -> 5 in
  let r = repeat n in
  Printf.printf "%d\n" r

let _ = main ()

