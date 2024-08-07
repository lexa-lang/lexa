
effect Yield : unit -> unit

let run n =
  let acc = ref 0 in
  let storage: (((unit, unit) continuation) option) ref = ref None in
  let work _ = (
    try
      for i = 1 to n do
        perform (Yield ());
      done
    with
    | effect (Yield ()) k -> 
        acc := !acc + 1;
        let peer = !storage in
        storage := Some k;
        match peer with
        | Some peer -> continue peer ()
        | None -> ()
  ) in
  work();
  work();
  !acc

let main () =
  let n = try int_of_string (Sys.argv.(1)) with _ -> 5 in
  let r = run n in
  Printf.printf "%d\n" r

let _ = main ()

