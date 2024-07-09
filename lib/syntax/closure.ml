open Common

type closure = { entry : var; fv : Varset.t }

type t = (* expressions AFTER closure conversion *)
  | Var of var
  | Int of int
  | Bool of bool
  | Prim of string
  | Arith of t * arith * t
  | Cmp of t * cmp * t 
  | New of t list
  | Get of t * t
  | Set of t * t * t
  | Raise of var * var * t list
  | Resume of var * t
  | ResumeFinal of var * t
  | Hdl of var list * var * var * var
  | Closure of closure
  | AppClosure of t * t list
  | App of t * t list
  | Let of var * t * t
  | If of t * t * t

type hdl = hdl_anno * var * var list * t

type top_level =
  | TLAbs of var * var list * t
  | TLEffSig of var * var list
  | TLObj of var * var list * hdl list