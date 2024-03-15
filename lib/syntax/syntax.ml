type var = string

type label = string

type arith =
  | AAdd
  | AMult
  | ASub
  | ADiv

type cmp =
  | CEq
  | CNeq
  | CLt
  | CGt

type hdl_anno =
  | HDef
  | HExc
  | HHdl

type value = 
  | VVar of var
  | VInt of int
  | VBool of bool
  | VAbs of var * var list * term
  | VEffSig of var * var list
  | VObj of var * var list * hdl list

and hdl = hdl_anno * var * var list * term

and heap_value = value list

and term =
  | TValue of value
  | TArith of value * arith * value
  | TCmp  of value * cmp * value
  | TLet of var * term * term
  | TIf of value * term * term
  | TApp of value * value list
  | TNew of heap_value
  | TGet of value * int
  | TSet of value * int * value
  | TRaise of value * value
  | TAbort of value * value
  | TThrow of value * value
  | THdl of value list * var * var * term * handler

and handler =
  | HNormal of var * var * var * term
  | HAbortive of var * var * term

and heap_item = location * value

and heap =
  heap_item list

and location = string

type toplevel = value list