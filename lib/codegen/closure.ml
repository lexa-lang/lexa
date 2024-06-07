open Syntax__Closure
open Syntax__Common

let extra_toplevels = ref []

(* l1 minus l2 *)
let set_substract l1 l2 = 
  List.filter (fun x -> not (List.mem x l2)) l1

let%test _ = (set_substract [1;2;3;4] [2;3]) = [1;4]

let counter = ref 0

let gen_lifted_name name =
  incr counter;
  Printf.sprintf "__%s_lifted_%d__" name !counter

(* A helper function to remove duplicates in a list *)
let remove_dup xs = 
  let uniq_cons x xs = if List.mem x xs then xs else x :: xs in
  List.fold_right uniq_cons xs []

let rec free_var (e : Syntax.expr) = 
  remove_dup (match e with
  | Syntax.Var x -> [x]
  | Syntax.Int _ | Syntax.Bool _ | Syntax.Prim _ -> []
  | Syntax.Arith (e1, _, e2) -> free_var e1 @ free_var e2
  | Syntax.Cmp (e1, _, e2) -> free_var e1 @ free_var e2
  | Syntax.Let (x, e1, e2) -> set_substract (free_var e1 @ free_var e2) [x]
  | Syntax.If (e1, e2, e3) -> free_var e1 @ free_var e2 @ free_var e3
  | Syntax.App (e, args) -> free_var e @ (List.concat_map (fun x -> free_var x) args)
  | Syntax.New hv -> List.concat_map (fun x -> free_var x) hv
  | Syntax.Get (e1, e2) -> free_var e1 @ free_var e2
  | Syntax.Set (e1, e2, e3) -> free_var e1 @ free_var e2 @ free_var e3
  | Syntax.Raise (stub, _, args) -> stub :: List.concat_map (fun x -> free_var x) args
  | Syntax.Resume (k, e) | Syntax.ResumeFinal (k, e) -> k :: free_var e
  | Hdl (xs, _, _, _) ->
    xs
  | Syntax.Letrec (name, params, body, e) ->
     (set_substract (free_var body) (name :: params)) @ (set_substract (free_var e) [name]))
    
  
let rec convert_expr ( e : Syntax.expr ) =
  match e with
  | Syntax.Var x -> Var x
  | Syntax.Int i -> Int i
  | Syntax.Bool b -> Bool b
  | Syntax.Prim p -> Prim p
  | Syntax.Arith (e1, op, e2) -> Arith (convert_expr e1, op, convert_expr e2)
  | Syntax.Cmp (e1, op, e2) -> Cmp (convert_expr e1, op, convert_expr e2)
  | Syntax.New es -> New (List.map convert_expr es)
  | Syntax.Get (e1, e2) -> Get (convert_expr e1, convert_expr e2)
  | Syntax.Set (e1, e2, e3) -> Set (convert_expr e1, convert_expr e2, convert_expr e3)
  | Syntax.Raise (v1, v2, es) -> Raise (v1, v2, List.map convert_expr es)
  | Syntax.Resume (v, e) -> Resume (v, convert_expr e)
  | Syntax.ResumeFinal (v, e) -> ResumeFinal (v, convert_expr e)
  | Syntax.Hdl (env_vars, stub, hdl_name, body) -> Hdl (env_vars, stub, hdl_name, body)
  | Syntax.Let (x, e1, e2) -> Let (x, convert_expr e1, convert_expr e2)
  | Syntax.If (e1, e2, e3) -> If (convert_expr e1, convert_expr e2, convert_expr e3)
  | Syntax.Letrec (x, params, body, e) ->
    let body' = convert_expr body in
    let func_fvs = set_substract (free_var body) (x :: params) in
    let e' = convert_expr e in
    let params' = "__env__" :: params in
    (* open up env *)
    let rec open_env fv index = 
      (match fv with
      | [] -> body'
      | x :: xs -> 
        Let (x, Get (Var "__env__", Int index), open_env xs (index + 1)))
    in
    let body_fv_opened = open_env func_fvs 0 in
    let fresh_name = gen_lifted_name x in
    let lifted_func = TLAbs (fresh_name, params', body_fv_opened) in
    extra_toplevels := lifted_func :: !extra_toplevels;
    MkClosure (x, {entry = fresh_name; fv = func_fvs}, e')
  | Syntax.App (e, es) -> AppClosure(convert_expr e, List.map convert_expr es)

let rec handle_bodies_tl (tl : Syntax.top_level) : var list =
  match tl with
  | Syntax.TLAbs (_, _, body) -> handle_bodies_e body
  | Syntax.TLEffSig (_, _) -> []
  | Syntax.TLObj (_, _, l) -> 
    List.concat_map (fun (_, _, _, body) -> handle_bodies_e body) l

(* Identify all the handle bodies, as they do not have the additional
    environment parameter *)
and handle_bodies_e (e : Syntax.expr) : var list =
  match e with
  | Syntax.Arith (e1, _, e2) -> handle_bodies_e e1 @ handle_bodies_e e2
  | Syntax.Cmp (e1, _, e2) -> handle_bodies_e e1 @ handle_bodies_e e2
  | Syntax.Let (_, e1, e2) -> handle_bodies_e e1 @ handle_bodies_e e2
  | Syntax.If (e1, e2, e3) -> handle_bodies_e e1 @ handle_bodies_e e2 @ handle_bodies_e e3
  | Syntax.App (e, args) -> handle_bodies_e e @ (List.concat_map (fun x -> handle_bodies_e x) args)
  | Syntax.New hv -> List.concat_map (fun x -> handle_bodies_e x) hv
  | Syntax.Get (e1, e2) -> handle_bodies_e e1 @ handle_bodies_e e2
  | Syntax.Set (e1, e2, e3) -> handle_bodies_e e1 @ handle_bodies_e e2 @ handle_bodies_e e3
  | Syntax.Raise (stub, _, args) -> stub :: List.concat_map (fun x -> handle_bodies_e x) args
  | Syntax.Resume (k, e) | ResumeFinal (k, e) -> k :: handle_bodies_e e
  | Syntax.Letrec (_, _, body, e) -> 
    handle_bodies_e body @ handle_bodies_e e
  | Syntax.Hdl (_, body, _, _) -> [body]
  | _ -> []

let closure_convert_toplevels (tls : Syntax.top_level list) =
  let handle_bodies = List.concat_map (fun x -> handle_bodies_tl x) tls in
  let toplevel_closures = ref [] in
  let closure_convert_toplevel tl =
    match tl with
    | Syntax.TLAbs (name, params, body) ->
      if name = "main" then
        TLAbs (name, params, convert_expr body)
      else
        (* Closures for toplevel functions except for handle bodies (before closure conversion) *)
        if List.mem name handle_bodies then
          TLAbs (name, params, convert_expr body) 
        else
          let func_name = gen_lifted_name name in
          toplevel_closures := (name, func_name) :: !toplevel_closures;
          TLAbs (func_name, ("__env__" :: params), convert_expr body)
    | Syntax.TLEffSig (name, dcls) ->
      TLEffSig (name, dcls)
    | Syntax.TLObj (name, obj_params, hdls) ->
      let hdls_converted (anno, name, params, body) = (anno, name, params, convert_expr body) in
      TLObj (name, obj_params, List.map hdls_converted hdls)
  in
  let converted_original_toplevels = (List.map closure_convert_toplevel tls) in
  (!extra_toplevels @ converted_original_toplevels, !toplevel_closures)
      