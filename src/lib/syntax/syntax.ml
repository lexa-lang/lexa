open Common

type top_level =
  | TLAbs of var * var list * expr
  | TLEffSig of var * var list
  | TLType of typedef list
  | TLOpen of var
  | TLOpenC of var

and fundef = { name : var;
               params : var list;
               body : expr }

and hdl = { op_anno : hdl_anno;
            op_name : var;
            op_params : var list;
            op_body : expr }

and pattern =
  | PTypecon of var * var list

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
  | Raise of {
    raise_stub : expr;
    raise_op : var;
    raise_args : expr list
  }
  | Resume of expr * expr
  | ResumeFinal of expr * expr
  | Handle of { handle_body : expr;
    stub : var;
    sig_name : var;
    handler_defs : hdl list
  }
  | Recdef of fundef list * expr
  | Fun of var list * expr
  | Let of var * expr * expr
  | If of expr * expr * expr
  | Stmt of expr * expr
  | Typecon of var * expr list
  | Match of {
    match_expr : expr;
    pattern_matching : (pattern * expr) list
  }