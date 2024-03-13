open Syntax
open Printf

type c_code = string list

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

let rec genValue = function
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
          (if name = "main" then "(int)" else "") ^ genTerm body;
          ");";
        "}"]

and genValueList l =
  "(" ^ String.concat "," (List.map (fun x -> genValue x) l) ^ ")"

and genTerm = function
| TValue v -> genValue v
| TArith (v1, op, v2) ->
    genValue v1 ^ " " 
    ^ genArith op ^ " " ^ genValue v2
| TCmp (v1, op, v2) ->
    genValue v1 ^ " " 
    ^ genCmp op ^ " " ^ genValue v2
| TLet (x, t1, t2) ->
    String.concat "\n"
      ["({";
        "intptr_t " ^ x ^ " = " ^ (genTerm t1) ^ ";";
        genTerm t2 ^ ";";
      "})"]
| TApp (v1, params) ->
    (genValue v1) ^ genValueList params
| TIf (v, t1, t2) ->
    String.concat " " [genValue v; "?"; genTerm t1; ":"; genTerm t2]
| TNew value_list ->
    let size = List.length value_list in
    sprintf "(intptr_t)malloc(%d * sizeof(intptr_t))" size
| TGet (v, i) ->
    sprintf "((intptr_t*)%s)[%d]" (genValue v) i 
| TSet (v1, i, v2) ->
    sprintf "((intptr_t*)%s)[%d] = %s" (genValue v1) i (genValue v2) 
| _ -> "TODO"

(* let genFunc func = function
| VAbs (name, params, body)
| _ -> "" *)

let genToplevel toplevel =
  let header = "
#include <stdint.h>\n#include <stdlib.h>\n#include <stdio.h>\n" in
  String.concat "\n" (header :: (List.map (fun x -> genValue x) toplevel))