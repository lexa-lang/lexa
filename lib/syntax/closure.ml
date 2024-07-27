open Common

type closure = { entry : var; fv : Varset.t }

type hdl = hdl_anno * var * var list * t

and handle = { env : var list;
               body_name: var;
               obj_name : var;
               sig_name : var }

and t = (* expressions AFTER closure conversion *)
  | Var of var
  | Int of int
  | Bool of bool
  | Prim of string
  | Arith of t * arith * t
  | Cmp of t * cmp * t 
  | New of t list
  | Get of t * t
  | Set of t * t * t
  | Raise of t * var * t list
  | Resume of t * t
  | ResumeFinal of t * t
  | Handle of handle
  | Closure of closure
  | AppClosure of t * t list
  | App of t * t list
  | Let of var * t * t
  | If of t * t * t
  | Stmt of t * t

type top_level =
  | TLAbs of var * var list * t
  | TLEffSig of var * var list
  | TLObj of var * var list * hdl list