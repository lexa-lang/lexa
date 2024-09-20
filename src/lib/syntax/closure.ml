open Common

type closure = { entry : var; fv : Varset.t }

type hdl = { op_anno : hdl_anno;
            op_name : var;
            op_params : var list;
            op_body : t }

and pattern =
  | PTypecon of var * var list

and t = (* expressions AFTER closure conversion *)
  | Var of var
  | Int of int
  | Float of float
  | Bool of bool
  | Str of string
  | Char of char
  | Prim of string
  | Arith of t * arith * t
  | Neg of t
  | BArith of t * barith * t
  | Cmp of t * cmp * t 
  | New of t list
  | Get of t * t
  | Set of t * t * t
  | Raise of {
    raise_stub : t;
    raise_op : var;
    raise_args : t list
  }
  | Resume of t * t
  | ResumeFinal of t * t
  | Handle of { env : var list;
    body_name: var;
    obj_name : var;
    sig_name : var
  }
  | Closure of closure
  | AppClosure of t * t list
  | App of t * t list
  | Let of var * t * t
  | If of t * t * t
  | Stmt of t * t
  | Recdef of (var * closure) list * t
  | Typecon of var * t list
  | Match of {
    match_expr : t;
    pattern_matching : (pattern * t) list
  }

type top_level =
  | TLAbs of var * var list * t
  | TLEffSig of var * var list
  | TLObj of var * var list * hdl list
  | TLType of typedef list
  | TLOpen of var
  | TLOpenC of var