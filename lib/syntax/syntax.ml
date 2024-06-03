open Common

type top_level =
  | TLAbs of var * var list * expr
  | TLEffSig of var * var list
  | TLObj of var * var list * hdl list

and hdl = hdl_anno * var * var list * expr (* handler *)

and expr =
  | Var of var
  | Int of int
  | Bool of bool
  | Prim of string
  | Arith of expr * arith * expr
  | Cmp of expr * cmp * expr 
  | App of expr * expr list
  | New of expr list
  | Get of expr * expr
  | Set of expr * expr * expr
  | Raise of var * var * expr list
  | Resume of var * expr
  | ResumeFinal of var * expr
  | Hdl of var list * var * var * var (* handle *)
  | Letrec of var * var list * expr * expr (* val x = fun(x, y) {body}; e2*)
  | Let of var * expr * expr
  | If of expr * expr * expr