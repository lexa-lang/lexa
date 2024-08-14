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

type type_expr = var

type typedef = {
  type_name : var;
  type_cons : (var * type_expr list) list
}