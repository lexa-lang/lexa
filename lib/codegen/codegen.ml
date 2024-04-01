open Syntax
open Printf
open Primitive

type handler_type = hdl_anno
type eff_sig_env = (var * string list) list
type eff_type_env = (var * handler_type) list
type fun_type_env = var list (* list of functions that are handler bodies *)
type env = eff_sig_env * eff_type_env * fun_type_env

exception UndefinedHandler of string
exception UndefinedSignature of string
exception ParameterMismatch of string
exception NestedFunction of string
exception UnexpectedResume of string

let get_eff_sig_env ((a, _, _) : env) = a
let get_eff_type_env ((_, b, _) : env) = b
let get_fun_type_env ((_, _, c) : env) = c

let env : env ref = ref ([], [], [])

let lookup_hdl_type (hdl_var : var) (env : eff_type_env) : string =
  match (List.find_opt (fun (s, _) -> s = hdl_var) env) with
  | None -> raise (UndefinedHandler hdl_var)
  | Some (_, hdl_type) -> 
      (match hdl_type with
      | HDef -> "TAIL"
      | HExc -> "ABORT"
      | HHdl1 -> "SINGLESHOT"
      | HHdls -> "MULTISHOT")
      
let lookup_hdl_index (hdl_var : var) (env : eff_sig_env) : int =
  match (List.find_opt (fun (_, dcls) -> List.mem hdl_var dcls) env) with
  | None -> raise (UndefinedHandler hdl_var)
  | Some (_, dcls) ->
    (match (List.find_index (fun x -> hdl_var = x) dcls) with
      | None -> raise (UndefinedHandler "unreachable")
      | Some i -> i)

let lookup_eff_sig_dcls (sig_name : var) (sig_env : eff_sig_env) : string list =
  match (List.find_opt (fun (s, _) -> s = sig_name) sig_env) with
    | None -> raise (UndefinedSignature sig_name)
    | Some (_, dcl_list) -> dcl_list

let rec list_repeat n s =
  if n = 0 then [] else
  s :: list_repeat (n - 1) s

(* Substitute all occurences of name in t with name_new *)
let rec subst_var (t : term) (name : var) (name_new : var) =
  let subst_value v =
    match v with
    | VVar x ->  (if x = name then (VVar name_new) else v)
    | _ -> v
  in
  match t with
  | TValue v -> TValue (subst_value v)
  | TArith (v1, op, v2) -> TArith (subst_value v1, op, subst_value v2)
  | TCmp (v1, op, v2) -> TCmp (subst_value v1, op, subst_value v2)
  | TLet (x, t1, t2) -> 
      TLet (x, (subst_var t1 name name_new), (subst_var t2 name name_new))
  | TIf (v, t1, t2) ->
      TIf (subst_value v, subst_var t1 name name_new, subst_var t2 name name_new)
  | TApp (v, vs) ->
      TApp (subst_value v, List.map (fun vv -> subst_value vv) vs)
  | TNew hv -> 
      TNew (List.map (fun vv -> subst_value vv) hv)
  | TGet (v, i) ->
      TGet (subst_value v, i)
  | TSet (v1, i, v2) ->
      TSet (subst_value v1, i, subst_value v2)
  | TRaise (hdl_stub, h, vs) ->
      TRaise ((if hdl_stub = name then name_new else hdl_stub), h,
        (List.map (fun vv -> subst_value vv) vs))
  | TResume (_, _) | TResumeFinal (_, _) -> raise (UnexpectedResume (""))
  | THdl (env, body, obj, sig_name) ->
      THdl ((List.map (fun var -> if var = name then name_new else var) env),
        body, obj, sig_name)

let genArith = function
| AAdd -> "+"
| AMult -> "*"
| ASub -> "-"
| ADiv -> "/"

let genCmp = function
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

type c_dec = c_type * var * c_type list
type c_def = c_type * var * (c_type * var) list * term

let gen_c_type = function
| CTI64 -> "i64"
| CTInt -> "int"
| CTI64P -> "i64*"
| CTVoidPP -> "void**"
| CTCharP -> "char*"

let rec gen_c_def (def : c_def) : string = 
  let (t_return, name, params, body) = def in
  sprintf "%s %s(%s) {\n %s \n}" 
    (gen_c_type t_return) 
    name 
    (gen_params params)
    (gen_term body)

and gen_c_dec (_ : c_dec) : string = ""

and gen_params params =
  String.concat "," (List.map (fun (t, v) -> ((gen_c_type t) ^ v)) params)
  
and gen_value = function
| VVar x -> x
| VInt i -> string_of_int i
| VBool b -> if b then "1" else "0"
| VAbs (name, params, body) -> 
  let genParams params =
    String.concat ", " (List.map (fun p -> "i64 " ^ p) params)
  in
  if name = "main" then
    sprintf "int main(int argc, char *argv[]) {\nreturn((int)%s);\n}\n" (gen_term body)
  else if (List.mem name (get_fun_type_env !env)) then
    (match params with
    | [env_var; stub] -> 
      sprintf "i64 %s(i64 %s) {\nreturn(%s);\n}\n" name stub 
        (gen_term (subst_var body env_var (sprintf "((meta_t*)%s)->%s" stub env_var))) 
    | _ -> raise (ParameterMismatch name))
  else 
    sprintf "i64 %s(%s) {\nreturn(%s);\n}\n" name (genParams params) (gen_term body)
| VEffSig _ -> ""
| VObj (_, obj_params, hdls) -> 
  let genParams hdl_params =
    String.concat ", " 
      ((List.map (fun obj_param -> "i64* " ^ obj_param) obj_params) 
        @ (List.map (fun hdl_param -> "i64 " ^ hdl_param) hdl_params))
  in
  let gen_hdl (_, name, hdl_params, body) = 
    sprintf "i64 %s(%s) {\nreturn(%s);\n}" name ((genParams hdl_params) ^ ", void** exc")
    (gen_term body)
  in
  String.concat "\n" (List.map (fun x -> gen_hdl x) hdls)
| VPrim prim ->
    String.sub prim 1 ((String.length prim) - 1)

and gen_args l =
  "(" ^ String.concat "," (List.map (fun x -> gen_value x) l) ^ ")"

(* final tells if resume is final *)
and gen_term = function
| TValue v -> gen_value v
| TArith (v1, op, v2) ->
    gen_value v1 ^ " " 
    ^ genArith op ^ " " ^ gen_value v2
| TCmp (v1, op, v2) ->
    gen_value v1 ^ " " 
    ^ genCmp op ^ " " ^ gen_value v2
| TLet (x, t1, t2) ->
    String.concat "\n"
      ["({";
        "i64 " ^ x ^ " = " ^ (gen_term t1) ^ ";";
        gen_term t2 ^ ";";
      "})"]
| TApp (v1, args) ->
    (match v1 with
    | VPrim _ -> 
      let name = gen_value v1 in (* name is prim with leading ~ stripped *)
      (* The name here should have ~ stripped *)
      let cast_args (name : string) (args : value list) : string list =
        match List.assoc_opt name prim_env with
        | None -> raise (UndefinedPrimitive name)
        | Some param_types -> 
            let rec cast args pt =
              (match args, pt with
              | [], [] -> []
              | args_h :: args_t, pt_h :: pt_t ->
                ((gen_prim_type pt_h) ^ (gen_value args_h)) :: (cast args_t pt_t)
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
      sprintf "((%s)%s)%s" cast_func_str (gen_value v1) (gen_args args))
| TIf (v, t1, t2) ->
    sprintf "(%s) ? (%s) : (%s)" (gen_value v) (gen_term t1) (gen_term t2)
| TNew value_list ->
    let size = List.length value_list in
    let init = sprintf "i64 temp = (i64)malloc(%d * sizeof(i64));" size
      ^ "\n"
      ^ String.concat "\n" (List.mapi (fun i v -> sprintf "((i64*)temp)[%d] = %s;" i (gen_value v)) value_list)
      ^ "\ntemp;\n" in
    sprintf "({%s})" init
| TGet (v, v2) ->
    sprintf "((i64*)%s)[%s]" (gen_value v) (gen_value v2)
| TSet (v1, v2, v3) ->
    sprintf "((i64*)%s)[%s] = %s" (gen_value v1) (gen_value v2) (gen_value v3) 
| THdl (env_list, body_var, _, effsig) ->
    let hdl_list = lookup_eff_sig_dcls effsig (get_eff_sig_env !env) in
    let hdl_str = "(" ^ (String.concat ", " (List.map 
      (fun hdl_name -> 
        let hdl_type = lookup_hdl_type hdl_name (get_eff_type_env !env) in
          (sprintf "{%s, %s}" hdl_type hdl_name)) hdl_list)) ^ ")" in
    let env_str = "(" ^ String.concat ", " env_list ^ ")" in
    sprintf "HANDLE(%s, %s, %s)" body_var hdl_str env_str
| TRaise (stub, hdl, args) ->
    let hdl_idx = lookup_hdl_index hdl (get_eff_sig_env !env) in
    sprintf "RAISE(((meta_t*)%s), %d, %s)" stub hdl_idx (gen_args args)
| TResume (k, v) -> sprintf "THROW(%s, %s)" k (gen_value v)
| TResumeFinal (k, v) -> sprintf "FINAL_THROW(%s, %s)" k (gen_value v)

(* let genFunc func = function
| VAbs (name, params, body)
| _ -> "" *)

(* Pass through the top levels to keep track of effect signatures. *)
let rec sig_pass toplevel : eff_sig_env =
  match toplevel with
  | [] -> []
  | (VEffSig (sig_name, dcl_list)) :: tail ->
      (sig_name, dcl_list) :: (sig_pass tail)
  | _ :: tail -> sig_pass tail

(* Pass through the top levels keep track of effect types. *)
let rec eff_type_pass toplevel : eff_type_env =
  match toplevel with
  | [] -> []
  | (VObj (_, _, hdl_list)) :: tail ->
      (List.map (fun x -> 
        let (hdl_anno, name, _, _) = x in
          (match hdl_anno with (* analyze escapeness when it's a general handler *)
          | HHdl1 | HHdls -> (name, hdl_anno)
          | _ -> (name, hdl_anno))
        ) hdl_list)
      @ (eff_type_pass tail)
  | _ :: tail -> eff_type_pass tail

let rec fun_type_pass toplevel : fun_type_env =
  let rec get_handle_bodies t = (* Name of functions that are handlers *)
    match t with
    | TLet (_, t1, t2) -> (get_handle_bodies t1) @ (get_handle_bodies t2)
    | TIf (_, t1, t2) -> (get_handle_bodies t1) @ (get_handle_bodies t2)
    | THdl (_, body_name, _, _) -> [body_name]
    | _ -> []
  in
  match toplevel with
  | [] -> []
  | (VAbs (_, _, t)) :: tail ->
    get_handle_bodies t @ (fun_type_pass tail)
  | _ :: tail -> fun_type_pass tail
  
let gen_toplevel toplevel =
  let header = "#include <stdint.h>\n#include <stdlib.h>\n#include <stdio.h>\n#include <stdbool.h>\n#include <string.h>\n#include <defs.h>\n#include <datastructure.h>\n"
  in
  let eff_sig_env = sig_pass toplevel in
  let eff_type_env = eff_type_pass toplevel in
  let fun_type_env = fun_type_pass toplevel in
  env := (eff_sig_env, eff_type_env, fun_type_env);
  let declarations = String.concat "\n" (List.map 
      (fun v -> (match v with
      | VAbs (name, params, _) -> 
        sprintf "i64 %s(%s);"
          name 
          (String.concat ", " (list_repeat (List.length params) "i64"))
      | VObj (_, _, hdl_list) ->
        String.concat "\n"
          (List.map (fun (_, hname, hparams, _) -> 
            sprintf "i64 %s(%s);"
            hname 
            (String.concat ", " (list_repeat (List.length hparams) "i64")))
          hdl_list)
      | _ -> ""))
    toplevel) in
  sprintf "%s\n%s\n%s" header declarations
    (String.concat "\n" 
      (List.map 
        (fun x -> gen_value x)
        toplevel))