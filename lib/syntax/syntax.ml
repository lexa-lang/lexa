type var = string

type arith =
  | AAdd
  | AMult
  | ASub
  | ADiv
  | AMod

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

type top_level =
  | TLAbs of var * var list * expr
  | TLEffSig of var * var list
  | TLObj of var * var list * hdl list

(* and value = 
  | VVar of var
  | VInt of int
  | VBool of bool
  | VAbs of var * var list * expr
  | VEffSig of var * var list
  | VObj of var * var list * hdl list
  | VPrim of string *)

and hdl = hdl_anno * var * var list * expr (* handler *)

and heap_value = expr list

and clo_env = var list

and expr =
  | Var of var
  | Int of int
  | Bool of bool
  | Prim of string
  | EArith of expr * arith * expr
  | ECmp of expr * cmp * expr 
  | EApp of expr * expr list
  | ENew of heap_value
  | EGet of expr * expr
  | ESet of expr * expr * expr
  | ERaise of var * var * expr list
  | EResume of var * expr
  | EResumeFinal of var * expr
  | EHdl of expr list * var * var * var (* handle *)
  | EFun of var list * expr (* Function [fun f(x) = t] *)
  | EClosure of var list * expr * clo_env
  | ELet of var * expr * expr
  | EIf of expr * expr * expr