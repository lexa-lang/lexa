open Syntax__Closure
open Syntax__Common

module Varset = Syntax__Varset

let extra_toplevels = ref []

(* Map toplevel functions' original name to lifted name *)
let toplevel_lifted_name_map = ref []

let counter = ref 0

let gen_lifted_name name =
  incr counter;
  Printf.sprintf "__%s_lifted_%d__" name !counter

let rec free_var (e : Syntax.expr) : Varset.t = 
  match e with
  | Syntax.Var x -> Varset.singleton x
  | Syntax.Int _ | Syntax.Bool _ | Syntax.Prim _ -> Varset.empty
  | Syntax.Arith (e1, _, e2) -> Varset.union (free_var e1) (free_var e2)
  | Syntax.Cmp (e1, _, e2) -> Varset.union (free_var e1) (free_var e2)
  | Syntax.Let (x, e1, e2) -> Varset.(diff ((free_var e1) @@@ (free_var e2)) (singleton x))
  | Syntax.If (e1, e2, e3) -> Varset.((free_var e1) @@@ (free_var e2) @@@ (free_var e3))
  | Syntax.App (e, args) -> Varset.((free_var e) @@@ (union_map free_var args))
  | Syntax.New hv -> Varset.union_map free_var hv
  | Syntax.Get (e1, e2) -> Varset.union (free_var e1) (free_var e2)
  | Syntax.Set (e1, e2, e3) -> Varset.((free_var e1) @@@ (free_var e2) @@@ (free_var e3))
  | Syntax.Raise (stub, _, args) -> Varset.((union_map free_var args) |> add stub)
  | Syntax.Resume (k, e) | Syntax.ResumeFinal (k, e) -> Varset.(free_var e |> add k)
  | Syntax.Hdl (xs, _, _, _) -> Varset.of_list xs
  | Syntax.Fun (params, body) -> Varset.(diff (free_var body) (of_list params))
  | Syntax.Stmt (e1, e2) -> Varset.union (free_var e1) (free_var e2)
  | Syntax.Recdef (fundefs, e) ->
    let names = List.map (fun (f : Syntax.fundef) -> f.name) fundefs in
    (* TODO: Does each function need its individual free variable? *)
    let fvs = Varset.union_map  
      (fun ({params; body; _} : Syntax.fundef) -> Varset.(diff (free_var body) (union (of_list names) (of_list params))))
      fundefs in
    Varset.(fvs @@@ (diff (free_var e) (of_list names)))

(* Open the environment at the start of a function body *)
let open_env (fv : var list) (body : Syntax__Closure.t) : Syntax__Closure.t = 
  let rec f fv index =
    (match fv with
    | [] -> body
    | x :: xs -> 
      Let (x, Get (Var "__env__", Int index), f xs (index + 1))) in
  f fv 0

let rec convert_expr (e : Syntax.expr) (env : Varset.t) =
  match e with
  | Syntax.Var x -> Var x
  | Syntax.Int i -> Int i
  | Syntax.Bool b -> Bool b
  | Syntax.Prim p -> Prim p
  | Syntax.Arith (e1, op, e2) -> Arith (convert_expr e1 env, op, convert_expr e2 env)
  | Syntax.Cmp (e1, op, e2) -> Cmp (convert_expr e1 env, op, convert_expr e2 env)
  | Syntax.New es -> New (List.map (fun x -> convert_expr x env) es)
  | Syntax.Get (e1, e2) -> Get (convert_expr e1 env, convert_expr e2 env)
  | Syntax.Set (e1, e2, e3) -> Set (convert_expr e1 env, convert_expr e2 env, convert_expr e3 env)
  | Syntax.Raise (v1, v2, es) -> Raise (v1, v2, List.map (fun x -> convert_expr x env) es)
  | Syntax.Resume (v, e) -> Resume (v, convert_expr e env)
  | Syntax.ResumeFinal (v, e) -> ResumeFinal (v, convert_expr e env)
  | Syntax.Hdl (env_vars, stub, hdl_name, body) -> Hdl (env_vars, stub, hdl_name, body)
  | Syntax.Let (x, e1, e2) -> Let (x, convert_expr e1 env, convert_expr e2 Varset.(env |> add x))
  | Syntax.If (e1, e2, e3) -> If (convert_expr e1 env, convert_expr e2 env, convert_expr e3 env)
  | Syntax.Stmt (e1, e2) -> Stmt (convert_expr e1 env, convert_expr e2 env)
  | Syntax.Fun (params, body) ->
    let body' = convert_expr body Varset.(union (of_list params) env) in
    let func_fvs = Varset.(diff (free_var body) (of_list params)) in
    let fresh_name = gen_lifted_name "fun" in
    let body_fv_opened = open_env (Varset.to_list func_fvs) body' in
    let lifted_func = TLAbs (fresh_name, "__env__" :: params, body_fv_opened) in
    extra_toplevels := lifted_func :: !extra_toplevels;
    Closure {entry = fresh_name; fv = func_fvs}
  | Syntax.Recdef (funs, e) ->
    let clo_map = List.map (fun ({name; _} : Syntax.fundef) ->
      let fresh_name = gen_lifted_name name in
      let names = List.map (fun (f : Syntax.fundef) -> f.name) funs in
      let fvs = Varset.union_map  
        (fun ({params; body; _} : Syntax.fundef) -> Varset.(diff (free_var body) (of_list (names @ params))))
      funs in
      (name, {entry = fresh_name; fv = fvs})
      ) funs in
    (* Binds all functions in recdef at the beginning of body *)
    let rec bind_closures (clo_map : (var * closure) list) body : Syntax__Closure.t =
      (match clo_map with
      | [] -> body
      | (name, clo) :: clo_map' -> 
        Let (name, Closure clo, bind_closures clo_map' body)
      )
    in
    let names = List.map (fun (x, _) -> x) clo_map in
    let rec convert funs =
      (match funs with
      | [] -> convert_expr e Varset.(union (of_list names) env)
      | ({name = name; params = params; body = body} : Syntax.fundef) :: funs' ->
        let clo = List.assoc name clo_map in
        let {entry; fv} = clo in
        let body' = convert_expr body Varset.(union (of_list names) env) in
        let body' = bind_closures clo_map body' in
        let body' = open_env (Varset.to_list fv) body' in
        let params' = "__env__" :: params in
        let lifted_func = TLAbs (entry, params', body') in
        extra_toplevels := lifted_func :: !extra_toplevels;
        Let (name, Closure clo, (convert funs')))
    in
    convert funs
  | Syntax.App (e, es) -> 
    (match e with
    | Var name -> if not (Varset.mem name env) then
        (* Function name is not in the environment, callee must be a top level function *)
        let lifted_name = (List.assoc name !toplevel_lifted_name_map) in
        (* Pass 0 as the closure environment argument *)
        App(Var lifted_name, Int 0 :: (List.map (fun x -> convert_expr x env) es))
      else
        AppClosure(convert_expr e env, List.map (fun x -> convert_expr x env) es)
    | _ -> AppClosure(convert_expr e env, List.map (fun x -> convert_expr x env) es))
    

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
  | Syntax.Raise (_, _, args) -> List.concat_map (fun x -> handle_bodies_e x) args
  | Syntax.Resume (_, e) | ResumeFinal (_, e) -> handle_bodies_e e
  | Syntax.Fun (_, e) ->
    handle_bodies_e e
  | Syntax.Recdef (fls, e) -> 
    (List.concat_map (fun ({body; _} : Syntax.fundef) -> handle_bodies_e body) fls) @ handle_bodies_e e
  | Syntax.Hdl (_, body, _, _) -> [body]
  | Syntax.Prim _ -> []
  | Syntax.Int _ -> []
  | Syntax.Bool _ -> []
  | Syntax.Var _ -> []
  | Syntax.Stmt (e1, e2) -> handle_bodies_e e1 @ handle_bodies_e e2

let closure_convert_toplevels (tls : Syntax.top_level list) =
  let handle_bodies = List.concat_map (fun x -> handle_bodies_tl x) tls in
  let toplevel_closures = ref [] in
  List.iter (fun tl -> (match tl with
  | Syntax.TLAbs (name, _, _) -> 
    toplevel_lifted_name_map := (name, gen_lifted_name name) :: !toplevel_lifted_name_map
  | _ -> ())) tls;
  let closure_convert_toplevel tl =
    match tl with
    | Syntax.TLAbs (name, params, body) ->
      if name = "main" then
        TLAbs (name, params, convert_expr body (Varset.of_list params))
      else
        (* Closures for toplevel functions except for handle bodies (before closure conversion) *)
        if List.mem name handle_bodies then
          TLAbs (name, params, convert_expr body (Varset.of_list params)) 
        else
          let lifted_name = (List.assoc name !toplevel_lifted_name_map) in
          toplevel_closures := (name, lifted_name) :: !toplevel_closures;
          TLAbs (lifted_name, ("__env__" :: params), convert_expr body (Varset.of_list params))
    | Syntax.TLEffSig (name, dcls) ->
      TLEffSig (name, dcls)
    | Syntax.TLObj (name, obj_params, hdls) ->
      let hdls_converted (anno, name, params, body) = 
        (anno, name, params, convert_expr body (Varset.of_list params)) in
      TLObj (name, obj_params, List.map hdls_converted hdls)
  in
  let converted_original_toplevels = (List.map closure_convert_toplevel tls) in
  (!extra_toplevels @ converted_original_toplevels, !toplevel_closures)
      