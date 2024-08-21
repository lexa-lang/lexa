open Syntax__Closure
open Syntax__Common

module Varset = Syntax__Varset

exception UnboundVariable of string

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
  | Syntax.Int _ | Syntax.Float _ | Syntax.Bool _ | Syntax.Prim _ 
  | Syntax.Str _ | Syntax.Char _ -> Varset.empty
  | Syntax.Arith (e1, _, e2) -> Varset.union (free_var e1) (free_var e2)
  | Syntax.BArith (e1, _, e2) -> Varset.union (free_var e1) (free_var e2)
  | Syntax.Neg e -> free_var e
  | Syntax.Cmp (e1, _, e2) -> Varset.union (free_var e1) (free_var e2)
  | Syntax.Let (x, e1, e2) -> Varset.(diff ((free_var e1) @@@ (free_var e2)) (singleton x))
  | Syntax.If (e1, e2, e3) -> Varset.((free_var e1) @@@ (free_var e2) @@@ (free_var e3))
  | Syntax.App (e, args) -> Varset.((free_var e) @@@ (union_map free_var args))
  | Syntax.New hv -> Varset.union_map free_var hv
  | Syntax.Get (e1, e2) -> Varset.union (free_var e1) (free_var e2)
  | Syntax.Set (e1, e2, e3) -> Varset.((free_var e1) @@@ (free_var e2) @@@ (free_var e3))
  | Syntax.Raise (stub, _, args) -> Varset.((union_map free_var args) @@@ (free_var stub))
  | Syntax.Resume (k, e) | Syntax.ResumeFinal (k, e) -> Varset.(free_var e @@@ (free_var k))
  | Syntax.Handle {handle_body; stub; handler_defs; _} ->
    let handler_fvs = Varset.union_map 
      (fun (_, _, params, hdl_body) -> Varset.(diff (free_var hdl_body) (of_list params))) handler_defs in
    let hdler_names = List.map (fun (_, name, _, _) -> name) handler_defs in
    Varset.((diff (free_var handle_body) (of_list (stub :: hdler_names))) @@@ handler_fvs)
  | Syntax.Fun (params, body) -> Varset.(diff (free_var body) (of_list params))
  | Syntax.Stmt (e1, e2) -> Varset.union (free_var e1) (free_var e2)
  | Syntax.Recdef (fundefs, e) ->
    let names = List.map (fun (f : Syntax.fundef) -> f.name) fundefs in
    (* TODO: Does each function need its individual free variable? *)
    let fvs = Varset.union_map  
      (fun ({params; body; _} : Syntax.fundef) -> Varset.(diff (free_var body) (union (of_list names) (of_list params))))
      fundefs in
    Varset.(fvs @@@ (diff (free_var e) (of_list names)))
  | Syntax.Typecon (_, args) -> Varset.(union_map free_var args)
  | Syntax.Match (e, clauses) -> 
    let fv_match_clause (_, args, clause_body) = Varset.(diff (free_var clause_body) (of_list args)) in
    Varset.((union_map fv_match_clause clauses) @@@ (free_var e))
    

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
  | Syntax.Float f -> Float f
  | Syntax.Bool b -> Bool b
  | Syntax.Str s -> Str s
  | Syntax.Char c -> Char c
  | Syntax.Prim p -> Prim p
  | Syntax.Arith (e1, op, e2) -> Arith (convert_expr e1 env, op, convert_expr e2 env)
  | Syntax.BArith (e1, op, e2) -> BArith (convert_expr e1 env, op, convert_expr e2 env)
  | Syntax.Neg e -> Neg (convert_expr e env)
  | Syntax.Cmp (e1, op, e2) -> Cmp (convert_expr e1 env, op, convert_expr e2 env)
  | Syntax.New es -> New (List.map (fun x -> convert_expr x env) es)
  | Syntax.Get (e1, e2) -> Get (convert_expr e1 env, convert_expr e2 env)
  | Syntax.Set (e1, e2, e3) -> Set (convert_expr e1 env, convert_expr e2 env, convert_expr e3 env)
  | Syntax.Raise (s, v2, es) -> Raise (convert_expr s env, v2, List.map (fun x -> convert_expr x env) es)
  | Syntax.Resume (k, e) -> Resume (convert_expr k env, convert_expr e env)
  | Syntax.ResumeFinal (k, e) -> ResumeFinal (convert_expr k env, convert_expr e env)
  | Syntax.Handle {handle_body; stub; sig_name; handler_defs} -> 
    let handle_body' = convert_expr handle_body Varset.(env |> add stub) in
    let body_lifted_name = gen_lifted_name "handle_body" in
    let obj_lifted_name = gen_lifted_name stub in
    let fvs = free_var e in
    let body_fv_opened = open_env (Varset.to_list fvs) handle_body' in
    let lifted_body = TLAbs (body_lifted_name, ["__env__"; stub], body_fv_opened) in
    extra_toplevels := lifted_body :: !extra_toplevels;

    let convert_hdl (anno, hdl_name, params, hdl_body) =
      (anno, hdl_name, params, open_env (Varset.to_list fvs) (convert_expr hdl_body Varset.(union (of_list params) env))) in
    let handler_defs' = List.map convert_hdl handler_defs in
    let lifted_obj = TLObj (obj_lifted_name, ["__env__"], handler_defs') in
    extra_toplevels := lifted_obj :: !extra_toplevels;
    Handle { env = Varset.to_list fvs; 
             body_name = body_lifted_name;
             obj_name = obj_lifted_name;
             sig_name }
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
    let names = List.map (fun (f : Syntax.fundef) -> f.name) funs in
    let clo_map = List.map (fun ({name; params; body} : Syntax.fundef) ->
      let fresh_name = gen_lifted_name name in
      let fv = Varset.(diff (free_var body) (of_list params)) in
      (name, {entry = fresh_name; fv})
      ) funs in
    
    let convert_fun ({name = name; params = params; body = body} : Syntax.fundef) =
      let clo = List.assoc name clo_map in
      let {entry; fv} = clo in
      let body' = convert_expr body Varset.(union (of_list names) env) in
      let body' = open_env (Varset.to_list fv) body' in
      let params' = "__env__" :: params in
      let lifted_func = TLAbs (entry, params', body') in
      extra_toplevels := lifted_func :: !extra_toplevels;
      (name, clo) in
    Recdef (List.map convert_fun funs, convert_expr e Varset.(union (of_list names) env))
  | Syntax.App (e, es) -> 
    (match e with
    | Var name -> if not (Varset.mem name env) then
        (* Function name is not in the environment, callee must be a top level function *)
        let lifted_name = 
          (match (List.assoc_opt name !toplevel_lifted_name_map) with
          | Some n -> n
          | None -> raise (UnboundVariable name))
        in
        (* Pass 0 as the closure environment argument *)
        App (Var lifted_name, Int 0 :: (List.map (fun x -> convert_expr x env) es))
      else
        AppClosure(convert_expr e env, List.map (fun x -> convert_expr x env) es)
    | _ -> AppClosure(convert_expr e env, List.map (fun x -> convert_expr x env) es))
  | Syntax.Typecon (con_name, args) ->
    Typecon (con_name, List.map (fun x -> convert_expr x env) args)
  | Syntax.Match (e, clauses) -> 
    let convert_clause (con_name, args, clause_body) = 
      (con_name, args, (convert_expr clause_body Varset.(env @@@ (of_list args)))) in
    Match ((convert_expr e env), List.map convert_clause clauses)
    
let closure_convert_toplevels (tls : Syntax.top_level list) =
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
        let lifted_name = (List.assoc name !toplevel_lifted_name_map) in
        toplevel_closures := (name, lifted_name) :: !toplevel_closures;
        TLAbs (lifted_name, ("__env__" :: params), convert_expr body (Varset.of_list params))
    | Syntax.TLEffSig (name, dcls) ->
      TLEffSig (name, dcls)
    | Syntax.TLType typedefs -> TLType typedefs
    | Syntax.TLOpen filename -> TLOpen filename
  in
  let converted_original_toplevels = (List.map closure_convert_toplevel tls) in
  (converted_original_toplevels @ !extra_toplevels, !toplevel_closures)
      