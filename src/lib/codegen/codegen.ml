open Syntax__Closure
open Syntax__Common
open Printf
open Primitive

module Varset = Syntax__Varset

type operation_type = hdl_anno
type eff_sig_env = (var * string list) list
(* TODO: Rename type names *)
type eff_type_env_key = {obj_name : var; op_name : var}
type eff_type_env = (eff_type_env_key * operation_type) list
type fun_type_env = var list (* list of functions that are handler bodies *)
type env = {eff_sig : eff_sig_env; eff_type : eff_type_env; fun_type : fun_type_env; toplevel_closure : (string * string) list}

(* Map the constructors to the name of the type *)
type type_con_map = (var * var list) list

exception UndefinedOperation of string
exception UndefinedSignature of string
exception ParameterMismatch of string
exception NestedFunction of string
exception UnexpectedResume of string
exception InvalidHandleBody of string

exception UndefinedTypeCon of string

let get_eff_sig_env (e : env) = e.eff_sig
let get_eff_type_env (e : env) = e.eff_type
let get_fun_type_env (e : env) = e.fun_type
let get_toplevel_func_env (e : env) = e.toplevel_closure
let env : env ref = ref {eff_sig = []; eff_type = []; fun_type = []; toplevel_closure = []}

(* is tail optimization enabled *)
let tail_call_opt : bool ref = ref false

(* Not sure if this is a good way... *)
let cur_toplevel : var ref = ref ""

let type_con_map : type_con_map ref = ref []

(* Get the annotation of a handler operation *)
let lookup_operation_type (obj_name : var) (op_name : var) (env : eff_type_env) : string =
  match (List.find_opt 
    (fun ({obj_name = obj_name'; op_name = op_name'}, _) -> 
      obj_name = obj_name' && op_name = op_name')
    env) with
  | None -> raise (UndefinedOperation op_name)
  | Some (_, op_type) -> 
      (match op_type with
      | HDef -> "TAIL"
      | HExc -> "ABORT"
      | HHdl1 -> "SINGLESHOT"
      | HHdls -> "MULTISHOT")

let lookup_eff_sig_dcls (sig_name : var) (sig_env : eff_sig_env) : string list =
  match (List.find_opt (fun (s, _) -> s = sig_name) sig_env) with
    | None -> raise (UndefinedSignature sig_name)
    | Some (_, dcl_list) -> dcl_list

let lookup_type_name (con_name : var) : var =
  let res = List.find_opt (fun (_, cons) -> List.mem con_name cons) !type_con_map in
  match res with
  | Some (type_name, _) -> type_name
  | None -> raise (UndefinedTypeCon con_name)

let rec list_repeat n s =
  if n = 0 then [] else
  s :: list_repeat (n - 1) s

let gen_arith = function
| AAdd -> "+"
| AMult -> "*"
| ASub -> "-"
| ADiv -> "/"
| AMod -> "%"

let gen_barith = function
| BConj -> "&&"
| BDisj -> "||"

let gen_cmp = function
| CEq -> "=="
| CNeq -> "!="
| CLt -> "<"
| CGt -> ">"

type c_type =
  | CTI64 (* i64 *)
  | CTI64P (* i64* *)
  | CTInt (* int *)
  | CTVoidPP (* void** *)
  | CTCharP (* char* *)

type c_annotation =
  | CAFastSwitch
  | CANone

type c_keyword =
| CKStatic
| CKNone

type c_dec = 
  | CDec of c_annotation * c_keyword * c_type * var * c_type list

type c_def = 
  | CDef of c_annotation * c_keyword * c_type * var * (c_type * var) list * Syntax__Closure.t

let c_decs : (var * c_dec) list ref = ref []

let gen_c_keyword = function
  | CKStatic -> "static"
  | CKNone -> ""

let gen_c_type = function
| CTI64 -> "i64"
| CTInt -> "int"
| CTI64P -> "i64*"
| CTVoidPP -> "void**"
| CTCharP -> "char*"

let gen_c_annotation = function
| CAFastSwitch -> "FAST_SWITCH_DECORATOR\n"
| CANone -> ""

let rec gen_c_def ?(do_tail = false) (def : c_def) : string = 
  match def with
  | CDef (annotation, keyword, t_return, name, params, body) ->
    sprintf "%s%s %s %s(%s) {\nreturn(%s);\n}\n" 
      (gen_c_annotation annotation)
      (gen_c_keyword keyword)
      (gen_c_type t_return) 
      name 
      (gen_params params)
      (gen_expr body ~is_tail:(!tail_call_opt && do_tail))

and gen_c_dec (dec : c_dec) : string =
  match dec with
  | CDec (annotation, keyword, t_return, name, t_params) ->
    sprintf "%s%s %s %s(%s);"
      (gen_c_annotation annotation)
      (gen_c_keyword keyword)
      (gen_c_type t_return) name
      (String.concat "," (List.map (fun t -> gen_c_type t) t_params))

and gen_params params =
  String.concat "," (List.map (fun (t, v) -> ((gen_c_type t) ^ " " ^ v)) params)

and gen_args ?(cast = false) l =
  if cast then
    sprintf "(%s)" 
      (String.concat ", " (List.map (fun x -> "(i64)" ^ (gen_expr x)) l))
  else
    "(" ^ String.concat "," (List.map (fun x -> gen_expr x) l) ^ ")"

and gen_expr ?(is_tail = false) (e : Syntax__Closure.t) =
  let s = (match e with
    | Var x -> x
    | Int i -> string_of_int i
    | Float f -> string_of_float f
    | Bool b -> if b then "1" else "0"
    | Str s -> sprintf "({i64* __s__ = (i64*) xmalloc(%d*sizeof(char));strcpy((char*)__s__, \"%s\"); __s__;})" ((String.length s) + 1) s
    | Char c -> "\'" ^ Char.escaped c ^ "\'"
    | Prim prim ->
        String.sub prim 1 ((String.length prim) - 1)
    | Arith (e1, op, e2) ->
      sprintf "%s %s %s" (gen_expr e1 ~is_tail:false) (gen_arith op) (gen_expr e2 ~is_tail:false)
    | BArith (e1, op, e2) ->
      sprintf "%s %s %s" (gen_expr e1 ~is_tail:false) (gen_barith op) (gen_expr e2 ~is_tail:false)
    | Neg e -> sprintf "!%s" (gen_expr e)
    | Cmp (e1, op, e2) ->
      sprintf "%s %s %s" (gen_expr e1 ~is_tail:false) (gen_cmp op) (gen_expr e2 ~is_tail:false)
    | Let (x, e1, e2) ->
        sprintf "{i64 %s = (i64)%s;\n%s;}" x (gen_expr e1 ~is_tail:false) (gen_expr e2 ~is_tail:is_tail)
    | App (e1, args) ->
        let s =
          (match e1 with
          | Prim _ -> 
            let name = gen_expr e1 in (* name is prim with leading ~ stripped *)
            (* The name here should have ~ stripped *)
            (* TODO: Remove duplicate code here and in AppClosure *)
            let cast_args (name : string) (args : t list) : string list =
              match List.assoc_opt name prim_env with
              | None -> raise (UndefinedPrimitive name)
              | Some param_types -> 
                  let rec cast args pt =
                    (match args, pt with
                    | [], [] -> []
                    | args_h :: args_t, pt_h :: pt_t ->
                      ((gen_prim_type pt_h) ^ (gen_expr args_h)) :: (cast args_t pt_t)
                    | _, _ -> raise (InvalidPrimitiveCall name)) in
                  cast args param_types in
            let casted_args = cast_args name args in
            sprintf "((i64)(%s(%s)))" name (String.concat ", " casted_args) 
          | _ -> 
            let rec list_repeat n s =
              if n = 0 then [] else
              s :: list_repeat (n - 1) s in
            let cast_func_str =
              sprintf "i64(*)(%s)" (String.concat ", " (list_repeat (List.length args) "i64")) in
            sprintf "((%s)%s)%s" cast_func_str (gen_expr e1) (gen_args args)) in
        let do_tail = is_tail && (match e1 with
        | Var callee_name -> callee_name = !cur_toplevel
        | _ -> false) in 
        (* Need a value after return to solve return type error by clang *)
        if do_tail then sprintf "({__attribute__((musttail))\n return %s; 0;})" s else s
    | If (v, e1, e2) ->
        sprintf "%s ? %s : %s" (gen_expr v) (gen_expr e1 ~is_tail:is_tail) (gen_expr e2 ~is_tail:is_tail)
    | New fields ->
        let size = List.length fields in
        (* Strictly follow the order of evaluation *)
        let init_fields = String.concat "" 
          (List.mapi (fun i v -> sprintf "i64 __field_%d__ = (i64)%s;" i (gen_expr v)) fields)
        in let assign_fields = String.concat "" 
          (List.mapi (fun i _ -> sprintf "__newref__[%d] = __field_%d__;" i i) fields)
        in
        sprintf "({%s\ni64* __newref__ = xmalloc(%d * sizeof(i64));\n%s\n(i64)__newref__;})"
          init_fields size assign_fields
    | Get (e1, e2) ->
        sprintf "((i64*)%s)[%s]" (gen_expr e1) (gen_expr e2)
    | Set (e1, e2, e3) ->
        sprintf "((i64*)%s)[%s] = %s" (gen_expr e1) (gen_expr e2) (gen_expr e3) 
    | Handle {env = handle_env; body_name; obj_name; sig_name} ->
        let hdl_list = lookup_eff_sig_dcls sig_name (get_eff_sig_env !env) in
        let gen_operation_arg operation_name =
          let operation_type = lookup_operation_type obj_name operation_name (get_eff_type_env !env) in
          let full_operation_name = obj_name ^ "_" ^ operation_name in
          (sprintf "{%s, %s}" operation_type full_operation_name)
        in
        let hdl_str = "(" ^ (String.concat ", " (List.map gen_operation_arg hdl_list)) ^ ")" in
        let env_str = sprintf "(%s)" 
          (String.concat ", " (List.map (fun x -> "(i64)" ^ x) handle_env)) in
        sprintf "HANDLE(%s, %s, %s)" body_name hdl_str env_str
    | Raise (stub, hdl, args) ->
        sprintf "RAISE(%s, %s, %s)" (gen_expr stub) hdl (gen_args args ~cast:true)
    | Resume (k, e) -> sprintf "THROW(%s, %s)" (gen_expr k) (gen_expr e)
    | ResumeFinal (k, e) -> sprintf "FINAL_THROW(%s, %s)" (gen_expr k) (gen_expr e)
    | Closure ({ entry = entry_name; fv = free_vars }) ->
      let fv_creation : string =
        if Varset.is_empty free_vars then
          "__c__->env = (i64)NULL;"
        else
          sprintf "__c__->env = (i64)xmalloc(%d * sizeof(i64));" (Varset.cardinal free_vars)
      in
      let copy_fv : string =
        String.concat "\n" (List.mapi 
          (fun i x -> sprintf "((i64*)(__c__->env))[%d] = (i64)%s;" i x)
          (Varset.to_list free_vars))
      in
      let closure_creation : string =
        sprintf 
{|({closure_t* __c__ = xmalloc(sizeof(closure_t));
__c__->func_pointer = (i64)%s;
%s
%s
(i64)__c__;})|}
        entry_name fv_creation copy_fv
      in
      closure_creation
    | AppClosure (e, args) ->
      (match e with
        | Prim _ -> 
          let name = gen_expr e in (* name is prim with leading ~ stripped *)
          (* The name here should have ~ stripped *)
          let cast_args (name : string) (args : Syntax__Closure.t list) : string list =
            match List.assoc_opt name prim_env with
            | None -> raise (UndefinedPrimitive name)
            | Some param_types -> 
                let rec cast args pt =
                  (match args, pt with
                  | [], [] -> []
                  | args_h :: args_t, pt_h :: pt_t ->
                    ((gen_prim_type pt_h) ^ (gen_expr args_h)) :: (cast args_t pt_t)
                  | _, _ -> raise (InvalidPrimitiveCall name)) in
                cast args param_types in
          let casted_args = cast_args name args in
          sprintf "((i64)(%s(%s)))" name (String.concat ", " casted_args) 
        | _ ->
          let rec list_repeat n s =
            if n = 0 then [] else
            s :: list_repeat (n - 1) s in
          let cast_func_str =
            sprintf "i64(*)(%s)" 
              (String.concat ", " (list_repeat ((List.length args) + 1) "i64")) in
          sprintf 
{|({closure_t* __clo__ = (closure_t*)%s;
i64 __f__ = (i64)(__clo__->func_pointer);
i64 __env__ = (i64)(__clo__->env);
((%s)__f__)%s;
})|}
          (gen_expr e) cast_func_str (gen_args (Var "__env__" :: args)))
    | Stmt (e1, e2) ->
      sprintf "{%s;\n%s;}" (gen_expr e1) (gen_expr e2 ~is_tail:is_tail)
    | Recdef (clo_map, e) -> 
      let malloc_closures = String.concat "" 
        (List.map 
          (fun (x, _) -> sprintf "closure_t* %s = xmalloc(sizeof(closure_t));\n" x) 
          clo_map)
      in
      let closure_creation (name, {entry; fv}) =
        if Varset.is_empty fv then
          sprintf "%s->env = (i64)NULL;\n" name
        else
          sprintf "%s->env = (i64)xmalloc(%d * sizeof(i64));\n" name (Varset.cardinal fv)
        ^
        String.concat "" (List.mapi 
          (fun i x -> sprintf "((i64*)(%s->env))[%d] = (i64)%s;\n" name i x)
          (Varset.to_list fv))
        ^
        sprintf "%s->func_pointer = (i64)%s;\n" name entry
      in
      sprintf "{%s\n%s\n%s;}"
        malloc_closures
        (String.concat "\n" (List.map closure_creation clo_map))
        (gen_expr e ~is_tail:is_tail)
    | Typecon (con_name, args) ->
      (* Find the type name *)
      let type_name = lookup_type_name con_name in
      (* Strictly follow the order of evaluation *)
      let compute_args = String.concat "" 
        (List.mapi (fun i arg -> sprintf "i64 __arg_%d__ = (i64)%s;\n" i (gen_expr arg)) args)
      in
      let assign_args = String.concat 
        ""
        (List.mapi 
          (fun i _ -> sprintf "__t__->%s[%d] = __arg_%d__;\n" con_name i i)
          args)
      in
      sprintf
{|({
%s
%s* __t__ = (%s*)xmalloc(sizeof(%s));
__t__->tag = %s;
%s
(i64)__t__;})
|} compute_args type_name type_name type_name con_name assign_args
    | Match (expr, clauses) ->
      let type_name = (match clauses with
      | [] -> failwith "Unreachable"
      | (x, _, _) :: _ -> lookup_type_name x) in
      (* generate for a single clause *)
      let gen_match_clause (i : int) (con_name, args, clause_body) =
        let clause_body_str = 
          (* __expr_res__ is already casted *)
          let bind_args_str = String.concat ""
            (List.mapi (fun i arg_name -> sprintf "i64 %s = (i64)(__expr_res__->%s[%d]);\n" arg_name con_name i) args) in
          sprintf "{%s\n%s;}"
            bind_args_str
            (gen_expr clause_body)
        in
        if i = 0 then
          sprintf "if (__expr_res__->tag == %s) {__match_res__=(%s);}" con_name clause_body_str
        else
          sprintf "else if (__expr_res__->tag == %s) {__match_res__=(%s);}" con_name clause_body_str
      in
      let match_cases_str = String.concat "\n" (List.mapi gen_match_clause clauses) in
      sprintf "({i64 __match_res__;%s* __expr_res__=(%s*)%s;\n%s\n__match_res__;})" 
      type_name type_name (gen_expr expr) match_cases_str
  )
  in
  (match e with
  | Var _ | Int _ | Bool _ | Prim _ -> s
  | _ -> sprintf "(%s)" s)

(* Pass through the top levels to keep track of effect signatures. *)
let rec sig_pass (toplevel : top_level list) : eff_sig_env =
  match toplevel with
  | [] -> []
  | (TLEffSig (sig_name, dcl_list)) :: tail ->
      (sig_name, dcl_list) :: (sig_pass tail)
  | _ :: tail -> sig_pass tail

(* Pass through the top levels keep track of effect types. *)
let rec eff_type_pass (toplevel : top_level list) : eff_type_env =
  match toplevel with
  | [] -> []
  | (TLObj (obj_name, _, operation_list)) :: tail ->
      (List.map (fun (op_anno, op_name, _, _) -> ({obj_name; op_name}, op_anno)) operation_list)
      @ (eff_type_pass tail)
  | _ :: tail -> eff_type_pass tail

let rec fun_type_pass (toplevel : top_level list) : fun_type_env =
  let rec get_handle_bodies t = (* Name of functions that are handlers *)
    match t with
    | Let (_, t1, t2) -> (get_handle_bodies t1) @ (get_handle_bodies t2)
    | If (_, t1, t2) -> (get_handle_bodies t1) @ (get_handle_bodies t2)
    | Handle {body_name; _} -> [body_name]
    | _ -> []
  in
  match toplevel with
  | [] -> []
  | (TLAbs (_, _, t)) :: tail ->
    get_handle_bodies t @ (fun_type_pass tail)
  | _ :: tail -> fun_type_pass tail

let type_con_map_pass (toplevels : top_level list) : unit =
  let update_map tl =
    (match tl with
    | TLType typedefs ->
        List.iter (fun {type_name; type_cons} -> 
          let cons_list = List.map (fun (x, _) -> x) type_cons in
          type_con_map := (type_name, cons_list) :: !type_con_map;
        ) typedefs
    | _ -> ())
  in
  List.iter update_map toplevels

let gen_top_level (tl : top_level) =
  match tl with 
  | TLAbs (name, params, body) ->
    cur_toplevel := name;
    let toplevel_func_closure = get_toplevel_func_env !env in
    let rec init_closures l = (match l with
    | [] -> ""
    | (original_name, lifted_name) :: xs -> 
(sprintf {|%s = xmalloc(sizeof(closure_t));
%s->func_pointer = (i64)%s;
%s->env = (i64)NULL;
|} original_name original_name lifted_name original_name) ^ init_closures xs) in  
    if name = "main" then
      sprintf 
{|int main(int argc, char *argv[]) {
init_stack_pool();
%s
i64 __res__ = %s;
destroy_stack_pool();
return((int)__res__);}|}
      (init_closures toplevel_func_closure) (gen_expr body)
    else
      let cdec = 
        CDec (CANone, CKStatic, CTI64, name, (List.map (fun _ -> CTI64) params)) in
      c_decs := (name, cdec) :: !c_decs;
      let cdef =
        CDef (CANone, CKStatic, CTI64, name, (List.map (fun p -> (CTI64, p)) params), body) in
      gen_c_def cdef ~do_tail:true
      (* sprintf "i64 %s(%s) {\nreturn(%s);\n}\n" name (genParams params) (gen_expr body) *)
  | TLEffSig (sig_name, sig_methods) ->
    sprintf "enum %s {%s};\n" sig_name (String.concat "," sig_methods)
  | TLObj (obj_name, obj_params, hdls) -> 
    let gen_hdl (hdl_anno, name, hdl_params, body) = 
      let concated_params = (List.map (fun x -> (CTI64P, x)) obj_params) 
        @ (List.map (fun x -> (CTI64, x)) hdl_params) in
      let annotation = (match hdl_anno with
      | HDef -> CANone
      | HExc -> CANone
      | _ -> CAFastSwitch) in
      let hdl_name = obj_name ^ "_" ^ name in
      let c_def = CDef (annotation, CKNone, CTI64, hdl_name, concated_params, body) in
      let c_dec = CDec (annotation, CKNone, CTI64, hdl_name, (List.map (fun (a, _) -> a) concated_params)) in
      c_decs := (hdl_name, c_dec) :: !c_decs;
      gen_c_def c_def
    in
    String.concat "\n" (List.map (fun x -> gen_hdl x) hdls)
  | TLType typedefs ->
    let gen_tag ({type_name; type_cons}: typedef) = 
      sprintf "enum %s {\n%s};\n" 
        (sprintf "__%s_tag__" type_name)
        (String.concat "" (List.map (fun (cons_name, _) -> cons_name ^ ",\n") type_cons))
    in
    let gen_cons (type_cons : (var * type_expr list) list) =
      let gen_con (con_name, con_args) =
        sprintf "i64 %s[%d];\n" con_name (List.length con_args)
      in
      String.concat "" (List.map gen_con type_cons)
    in
    let gen_struct ({type_name; type_cons} : typedef) =
      sprintf "typedef struct %s {\nenum %s tag;\nunion {\n%s};\n} %s;\n" 
        type_name 
        (sprintf "__%s_tag__" type_name) 
        (gen_cons type_cons)
        type_name
    in
    let gen_typedef (typedef : typedef) =
      sprintf "%s\n\n%s" (gen_tag typedef) (gen_struct typedef)
    in
    String.concat "\n" (List.map gen_typedef typedefs)
  | TLOpen _ -> ""

let gen_top_level_s ((toplevels, toplevel_closures) : ((top_level list) * (string * string) list)) ~tail =
  tail_call_opt := tail;
  let header = "#include <stdint.h>\n#include <stdlib.h>\n#include <stdio.h>\n#include <stdbool.h>\n#include <string.h>\n#include <stacktrek.h>\n#include <datastructure.h>\n"
  in
  let eff_sig_env = sig_pass toplevels in
  let eff_type_env = eff_type_pass toplevels in
  let fun_type_env = fun_type_pass toplevels in
  let toplevel_func_env = toplevel_closures in
  env := {eff_sig = eff_sig_env; eff_type = eff_type_env; fun_type = fun_type_env; toplevel_closure = toplevel_func_env};

  type_con_map_pass toplevels;

  let declare_closures = String.concat "\n" (List.map (fun (x, _) -> sprintf "static closure_t* %s;" x) toplevel_func_env) in
  let prog = (String.concat "\n" 
    (List.map 
      (fun x -> gen_top_level x)
      toplevels)) in
  let declarations = String.concat "\n" (List.map 
    (fun (_, d) -> gen_c_dec d) !c_decs) in
  sprintf "%s\n%s\n%s\n%s" header declarations declare_closures prog
