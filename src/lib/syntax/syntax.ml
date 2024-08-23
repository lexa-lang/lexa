open Common

type top_level =
  | TLAbs of var * var list * expr
  | TLEffSig of var * var list
  | TLType of typedef list
  | TLOpen of var

and fundef = { name : var;
               params : var list;
               body : expr }

and hdl = hdl_anno * var * var list * expr (* handler *)

and handle = { handle_body : expr;
               stub : var;
               sig_name : var;
               handler_defs : hdl list}

and expr =
  | Var of var
  | Int of int
  | Float of float
  | Bool of bool
  | Str of string
  | Char of char
  | Prim of string
  | Arith of expr * arith * expr
  | Cmp of expr * cmp * expr 
  | Neg of expr
  | BArith of expr * barith * expr
  | App of expr * expr list
  | New of expr list
  | Get of expr * expr
  | Set of expr * expr * expr
  | Raise of expr * var * expr list
  | Resume of expr * expr
  | ResumeFinal of expr * expr
  | Handle of handle (* handle *)
  | Recdef of fundef list * expr
  | Fun of var list * expr
  | Let of var * expr * expr
  | If of expr * expr * expr
  | Stmt of expr * expr
  | Typecon of var * expr list
  | Match of expr * (var * var list * expr) list