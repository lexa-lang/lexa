open Common

type top_level =
  | TLAbs of var * var list * expr
  | TLEffSig of var * var list
  | TLObj of var * var list * hdl list

and fundef = { name : var;
               params : var list;
               body : expr }

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
  | Raise of expr * var * expr list
  | Resume of expr * expr
  | ResumeFinal of expr * expr
  | Hdl of var list * var * var * var (* handle *)
  | Recdef of fundef list * expr
  | Fun of var list * expr
  | Let of var * expr * expr
  | If of expr * expr * expr
  | Stmt of expr * expr