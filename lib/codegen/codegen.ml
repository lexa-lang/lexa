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
exception InvalidHandleBody of string

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

let gen_arith = function
| AAdd -> "+"
| AMult -> "*"
| ASub -> "-"
| ADiv -> "/"
| AMod -> "%"

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
  | CDef of c_annotation * c_keyword * c_type * var * (c_type * var) list * expr

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

let rec gen_c_def (def : c_def) : string = 
  match def with
  | CDef (annotation, keyword, t_return, name, params, body) ->
    sprintf "%s%s %s %s(%s) {\nreturn(%s);\n}\n" 
      (gen_c_annotation annotation)
      (gen_c_keyword keyword)
      (gen_c_type t_return) 
      name 
      (gen_params params)
      (gen_expr body)

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

and gen_args l =
  "(" ^ String.concat "," (List.map (fun x -> gen_expr x) l) ^ ")"

and gen_expr e =
  let s = (match e with
    | Var x -> x
    | Int i -> string_of_int i
    | Bool b -> if b then "1" else "0"
    | Prim prim ->
        String.sub prim 1 ((String.length prim) - 1)
    | EArith (e1, op, e2) ->
      sprintf "%s %s %s" (gen_expr e1) (gen_arith op) (gen_expr e2)
    | ECmp (e1, op, e2) ->
      sprintf "%s %s %s" (gen_expr e1) (gen_cmp op) (gen_expr e2)
    | ELet (x, e1, e2) ->
        sprintf "{i64 %s = (i64)%s;\n%s;}" x (gen_expr e1) (gen_expr e2)
    | EApp (e1, args) ->
        (match e1 with
        | Prim _ -> 
          let name = gen_expr e1 in (* name is prim with leading ~ stripped *)
          (* The name here should have ~ stripped *)
          let cast_args (name : string) (args : expr list) : string list =
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
          sprintf "((%s)%s)%s" cast_func_str (gen_expr e1) (gen_args args))
    | EIf (v, e1, e2) ->
        sprintf "%s ? %s : %s" (gen_expr v) (gen_expr e1) (gen_expr e2)
    | ENew value_list ->
        let size = List.length value_list in
        let init = sprintf "i64 temp = (i64)malloc(%d * sizeof(i64));" size
          ^ "\n"
          ^ String.concat "\n" (List.mapi (fun i v -> sprintf "((i64*)temp)[%d] = (i64)%s;" i (gen_expr v)) value_list)
          ^ "\ntemp;\n" in
        sprintf "({%s})" init
    | EGet (e1, e2) ->
        sprintf "((i64*)%s)[%s]" (gen_expr e1) (gen_expr e2)
    | ESet (e1, e2, e3) ->
        sprintf "((i64*)%s)[%s] = %s" (gen_expr e1) (gen_expr e2) (gen_expr e3) 
    | EHdl (env_list, body_var, _, effsig) ->
        let hdl_list = lookup_eff_sig_dcls effsig (get_eff_sig_env !env) in
        let hdl_str = "(" ^ (String.concat ", " (List.map 
          (fun hdl_name -> 
            let hdl_type = lookup_hdl_type hdl_name (get_eff_type_env !env) in
              (sprintf "{%s, %s}" hdl_type hdl_name)) hdl_list)) ^ ")" in
        let env_str = "(" ^ String.concat ", " (List.map (fun e -> gen_expr e) env_list) ^ ")" in
        sprintf "HANDLE(%s, %s, %s)" body_var hdl_str env_str
    | ERaise (stub, hdl, args) ->
        let hdl_idx = lookup_hdl_index hdl (get_eff_sig_env !env) in
        sprintf "RAISE(%s, %d, %s)" stub hdl_idx (gen_args args)
    | EResume (k, e) -> sprintf "THROW(%s, %s)" k (gen_expr e)
    | EResumeFinal (k, e) -> sprintf "FINAL_THROW(%s, %s)" k (gen_expr e)
    | EClosure (_, _, _) -> "TODO"
    | EFun (_, _) -> "TODO") in
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
  | (TLObj (_, _, hdl_list)) :: tail ->
      (List.map (fun x -> 
        let (hdl_anno, name, _, _) = x in
          (match hdl_anno with (* analyze escapeness when it's a general handler *)
          | HHdl1 | HHdls -> (name, hdl_anno)
          | _ -> (name, hdl_anno))
        ) hdl_list)
      @ (eff_type_pass tail)
  | _ :: tail -> eff_type_pass tail

let rec fun_type_pass (toplevel : top_level list) : fun_type_env =
  let rec get_handle_bodies t = (* Name of functions that are handlers *)
    match t with
    | ELet (_, t1, t2) -> (get_handle_bodies t1) @ (get_handle_bodies t2)
    | EIf (_, t1, t2) -> (get_handle_bodies t1) @ (get_handle_bodies t2)
    | EHdl (_, body_name, _, _) -> [body_name]
    | _ -> []
  in
  match toplevel with
  | [] -> []
  | (TLAbs (_, _, t)) :: tail ->
    get_handle_bodies t @ (fun_type_pass tail)
  | _ :: tail -> fun_type_pass tail

let gen_top_level (tl : top_level) =
  match tl with 
  | TLAbs (name, params, body) -> 
    if name = "main" then
      sprintf "int main(int argc, char *argv[]) {\ninit_stack_pool();\ni64 __res__ = %s;\ndestroy_stack_pool();\nreturn((int)__res__);\n}\n"
        (gen_expr body)
    else
      let cdec = 
        CDec (CANone, CKStatic, CTI64, name, (List.map (fun _ -> CTI64) params)) in
      c_decs := (name, cdec) :: !c_decs;
      let cdef =
        CDef (CANone, CKStatic, CTI64, name, (List.map (fun p -> (CTI64, p)) params), body) in
      gen_c_def cdef
      (* sprintf "i64 %s(%s) {\nreturn(%s);\n}\n" name (genParams params) (gen_expr body) *)
  | TLEffSig _ -> ""
  | TLObj (_, obj_params, hdls) -> 
    let gen_hdl (hdl_anno, name, hdl_params, body) = 
      let concated_params = (List.map (fun x -> (CTI64P, x)) obj_params) 
        @ (List.map (fun x -> (CTI64, x)) hdl_params) in
      let annotation = (match hdl_anno with
      | HDef -> CANone
      | HExc -> CANone
      | _ -> CAFastSwitch) in
      let c_def = CDef (annotation, CKNone, CTI64, name, concated_params, body) in
      let c_dec = CDec (annotation, CKNone, CTI64, name, (List.map (fun (a, _) -> a) concated_params)) in
      c_decs := (name, c_dec) :: !c_decs;
      gen_c_def c_def
    in
    String.concat "\n" (List.map (fun x -> gen_hdl x) hdls)
  
let gen_top_level_s (toplevels : top_level list) =
  let header = "#include <stdint.h>\n#include <stdlib.h>\n#include <stdio.h>\n#include <stdbool.h>\n#include <string.h>\n#include <defs.h>\n#include <datastructure.h>\n"
  in
  let eff_sig_env = sig_pass toplevels in
  let eff_type_env = eff_type_pass toplevels in
  let fun_type_env = fun_type_pass toplevels in
  env := (eff_sig_env, eff_type_env, fun_type_env);
  let prog = (String.concat "\n" 
    (List.map 
      (fun x -> gen_top_level x)
      toplevels)) in
  let declarations = String.concat "\n" (List.map 
    (fun (_, d) -> gen_c_dec d) !c_decs) in
  sprintf "%s\n%s\n%s" header declarations prog
