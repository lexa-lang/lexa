type var = string

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
  | HHdl1 (* Singleshot *)
  | HHdls (* Multishot*)

type value = 
  | VVar of var
  | VInt of int
  | VBool of bool
  | VAbs of var * var list * term
  | VEffSig of var * var list
  | VObj of var * var list * hdl list

and hdl = hdl_anno * var * var list * term (* handler *)

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
  | TRaise of var * var * value list
  | TResume of var * value
  | TResumeFinal of var * value
  | THdl of var list * var * var * var (* handle *)

and heap_item = location * value

and heap =
  heap_item list

and location = string

type toplevel = value list