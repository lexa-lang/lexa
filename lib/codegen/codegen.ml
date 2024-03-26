open Syntax
open Printf
open Primitive

type handler_type = hdl_anno * bool
type eff_sig_env = (var * string list) list
type eff_type_env = (var * handler_type) list
type env = eff_sig_env * eff_type_env

exception UndefinedHandler of string
exception UndefinedSignature of string
exception ParameterMismatch of string
exception NestedFunction of string

let get_eff_sig_env ((a, _) : env) = a
let get_eff_type_env ((_, b) : env) = b

let lookup_hdl_type (hdl_var : var) (env : eff_type_env) : string =
  match (List.find_opt (fun (s, _) -> s = hdl_var) env) with
  | None -> raise (UndefinedHandler hdl_var)
  | Some (_, hdl_type) -> 
      (match hdl_type with
      | (HDef, _) -> "TAIL"
      | (HExc, _) -> "ABORT"
      | (HHdl1, escapeness) -> "SINGLESHOT" ^ (if escapeness then " | ESCAPE_K" else "")
      | (HHdls, escapeness) -> "MULTISHOT" ^ (if escapeness then " | ESCAPE_K" else ""))
      
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

let rec genValue (env : env) = function
| VVar x -> x
| VInt i -> string_of_int i
| VBool b -> if b then "1" else "0"
| VAbs (name, params, body) -> 
    let genParams params =
      String.concat ", " (List.map (fun p -> "intptr_t " ^ p) params)
    in
    String.concat "\n" 
        [(if name = "main" then "int " else "intptr_t ")
          ^ name ^ "(" ^ (genParams params) ^ ")" ^ " {";
          "return (";
          (if name = "main" then "(int)" else "") ^ genTerm env body;
          ");";
        "}"]
  | VEffSig _ -> ""
  | VObj (_, obj_params, hdls) -> 
    let genParams hdl_params =
      String.concat ", " 
        ((List.map (fun obj_param -> "intptr_t* " ^ obj_param) obj_params) 
          @ (List.map (fun hdl_param -> "intptr_t " ^ hdl_param) hdl_params))
    in
    let gen_hdl (_, name, hdl_params, body) = 
      sprintf "intptr_t %s(%s) {\nreturn(%s);\n}" name ((genParams hdl_params) ^ ", void** exc")
      (genTerm env body)
    in
    String.concat "\n" (List.map (fun x -> gen_hdl x) hdls)
  | VPrim prim ->
      String.sub prim 1 ((String.length prim) - 1)

and genValueList env l =
  "(" ^ String.concat "," (List.map (fun x -> genValue env x) l) ^ ")"

(* final tells if resume is final *)
and genTerm (env : env) = function
| TValue v -> genValue env v
| TArith (v1, op, v2) ->
    genValue env v1 ^ " " 
    ^ genArith op ^ " " ^ genValue env v2
| TCmp (v1, op, v2) ->
    genValue env v1 ^ " " 
    ^ genCmp op ^ " " ^ genValue env v2
| TLet (x, t1, t2) ->
    String.concat "\n"
      ["({";
        "intptr_t " ^ x ^ " = " ^ (genTerm env t1) ^ ";";
        genTerm env t2 ^ ";";
      "})"]
| TApp (v1, params) ->
    (match v1 with
    | VPrim prim -> 
      let name = genValue env v1 in (* name is prim with leading ~ stripped *)
      (* The name here should have ~ stripped *)
      let cast_params (name : string) (params : value list) : string list =
        match List.assoc_opt name prim_env with
        | None -> raise (UndefinedPrimitive name)
        | Some param_types -> 
            let rec cast params pt =
              (match params, pt with
              | [], [] -> []
              | params_h :: params_t, pt_h :: pt_t ->
                ((gen_prim_type pt_h) ^ (genValue env params_h)) :: (cast params_t pt_t)
              | _, _ -> raise (InvalidPrimitiveCall name)) in
            cast params param_types in
      let casted_params = cast_params name params in
      sprintf "%s(%s)" prim (String.concat ", " casted_params) 
    | _ -> (genValue env v1) ^ genValueList env params)
| TIf (v, t1, t2) ->
    sprintf "(%s) ? (%s) : (%s)" (genValue env v) (genTerm env t1) (genTerm env t2)
| TNew value_list ->
    let size = List.length value_list in
    let init = sprintf "intptr_t temp = (intptr_t)malloc(%d * sizeof(intptr_t));" size
      ^ "\n"
      ^ String.concat "\n" (List.mapi (fun i v -> sprintf "((intptr_t*)temp)[%d] = %s;" i (genValue env v)) value_list)
      ^ "\ntemp;\n" in
    sprintf "({%s})" init
| TGet (v, i) ->
    sprintf "((intptr_t*)%s)[%d]" (genValue env v) i 
| TSet (v1, i, v2) ->
    sprintf "((intptr_t*)%s)[%d] = %s" (genValue env v1) i (genValue env v2) 
| THdl (env_list, body_var, _, effsig) ->
    let hdl_list = lookup_eff_sig_dcls effsig (get_eff_sig_env env) in
    let hdl_str = "(" ^ (String.concat ", " (List.map 
      (fun hdl_name -> 
        let hdl_type = lookup_hdl_type hdl_name (get_eff_type_env env) in
          (sprintf "{%s, %s}" hdl_type hdl_name)) hdl_list)) ^ ")" in
    let env_str = "(" ^ String.concat ", " env_list ^ ")" in
    sprintf "HANDLE(%s, %s, %s)" body_var hdl_str env_str
| TRaise (stub, hdl, params) ->
    let hdl_idx = lookup_hdl_index hdl (get_eff_sig_env env) in
    sprintf "RAISE(%s, %d, %s)" stub hdl_idx (genValueList env params)
| TResume (k, v) -> sprintf "THROW(%s, %s)" k (genValue env v)
| TResumeFinal (k, v) -> sprintf "FINAL_THROW(%s, %s)" k (genValue env v)

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

(* Given a handler body, determine if k escape *)
let if_escape (h : hdl) : bool =
  let (_, _, params, body) = h in
  let rec get_resumption_var l = (match l with
    | [] -> raise (ParameterMismatch "")
    | x :: [] -> x
    | _ :: tail -> get_resumption_var tail)
  in
  let resumption_var = get_resumption_var params in
  let rec occurs_in_v (v : value) : bool = (match v with
    | VVar x -> if (x = resumption_var) then true else false
    | VAbs (name, _, _) -> raise (NestedFunction name)
    | VInt _ -> false
    | VBool _ -> false
    | VEffSig (name, _) -> raise (NestedFunction name)
    | VObj (name, _, _) -> raise (NestedFunction name)
    | VPrim _ -> false)
  and occurs_in_t (t : term) : bool = (match t with
    | TValue v -> occurs_in_v v
    | TArith (v1, _, v2) -> occurs_in_v v1 || occurs_in_v v2
    | TCmp (v1, _, v2) -> occurs_in_v v1 || occurs_in_v v2
    | TLet (_, t1, t2) -> occurs_in_t t1 || occurs_in_t t2
    | TIf (cond, t1, t2) -> occurs_in_v cond || occurs_in_t t1 || occurs_in_t t2
    | TApp (_, vs) -> List.exists (fun x -> occurs_in_v x) vs
    | TNew vs -> List.exists (fun x -> occurs_in_v x) vs
    | TGet (v, _) -> occurs_in_v v
    | TSet (v1, _, v2) -> occurs_in_v v1 || occurs_in_v v2
    | TRaise (_, _, vs) -> List.exists (fun x -> occurs_in_v x) vs
    | TResume (_, _) -> false
    | TResumeFinal (_, _) -> false
    | THdl (envs, _, _, _) -> List.mem resumption_var envs)
  in
  occurs_in_t body

(* Pass through the top levels keep track of effect types. *)
let rec eff_type_pass toplevel : eff_type_env =
  match toplevel with
  | [] -> []
  | (VObj (_, _, hdl_list)) :: tail ->
      (List.map (fun x -> 
        let (hdl_anno, name, _, _) = x in
          (match hdl_anno with (* analyze escapeness when it's a general handler *)
          | HHdl1 | HHdls -> (name, (hdl_anno, if_escape x))
          | _ -> (name, (hdl_anno, false)))
        ) hdl_list)
      @ (eff_type_pass tail)
  | _ :: tail -> eff_type_pass tail

let genToplevel toplevel =
  let header = "#include <stdint.h>\n#include <stdlib.h>\n#include <stdio.h>\n#include <stdbool.h>\n#include <string.h>\n#include <defs.h>\n#include <datastructure.h>\n"
  in
  let eff_sig_env = sig_pass toplevel in
  let eff_type_env = eff_type_pass toplevel in
  String.concat "\n" (header :: (List.map (fun x -> genValue (eff_sig_env, eff_type_env) x) toplevel))