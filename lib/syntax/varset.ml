module Varset =
  Set.Make
    (struct
      type t = Common.var
      let compare = compare
    end)
include Varset

let (@@@) s1 s2 = union s1 s2;;

(* Similar to List.concat_map *)
let union_map (f : 'a -> Varset.t) (l : 'a list) : Varset.t =
  List.fold_left (fun s1 s2 -> s1 @@@ (f s2)) empty l

