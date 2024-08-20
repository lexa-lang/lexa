type prim_type =
  | PTI32 (* int32_t *)
  | PTI64 (* int64_t *)
  | PTDouble (* double *)
  | PTNodeP (* node_t* *)
  | PTTreeP (* tree_t* *)
  | PTQueueP (* queue_t* *)
  | PTStringP (* char* *)
  | PTArrayP (* array_t* *)

type prim_env = (string * prim_type list) list

exception UndefinedPrimitive of string
exception InvalidPrimitiveCall of string

let prim_env = [
  ("check", [PTI64]);
  ("error", [PTStringP]);
  ("lambdaManInit", []); (* TODO: remove lambdamans *)
  ("lambdaManGetWidth", []);
  ("lambdaManGetHeight", []);
  ("lambdaManGetField", [PTI64; PTI64]);
  ("listNode", [PTI64; PTNodeP]);
  ("listEnd", []);
  ("listIsEmpty", [PTNodeP]);
  ("listRange", [PTI64; PTI64]);
  ("listPrint", [PTNodeP]);
  ("listHead", [PTNodeP]);
  ("listTail", [PTNodeP]);
  ("listSetHead", [PTNodeP; PTI64]);
  ("listSetTail", [PTNodeP; PTNodeP]);
  ("listAppend", [PTNodeP; PTNodeP]);
  ("listMax", [PTNodeP]);
  ("listLen", [PTNodeP]);
  ("listAt", [PTNodeP; PTI64]);
  ("treeNode", [PTI64; PTTreeP; PTTreeP]);
  ("treeLeaf", []);
  ("treeIsEmpty", [PTTreeP]);
  ("treeLeft", [PTTreeP]);
  ("treeRight", [PTTreeP]);
  ("treeValue", [PTTreeP]);
  ("queueMake", []);
  ("queueIsEmpty", [PTQueueP]);
  ("queueEnq", [PTQueueP; PTI64]);
  ("queueDeq", [PTQueueP]);
  ("queueLen", [PTQueueP]);
  ("readInt", []);
  ("printInt", [PTI64]);
  ("printFloat", [PTI64]);
  ("printChar", [PTI64]);
  ("stringMake", [PTI64; PTI64]);
  ("stringSubStr", [PTStringP; PTI64; PTI64]);
  ("stringCharAt", [PTStringP; PTI64]);
  ("stringLen", [PTStringP]);
  ("boxFloat", [PTDouble]);
  ("unboxFloat", [PTI64]);
  ("floatAdd", [PTI64; PTI64]);
  ("floatSub", [PTI64; PTI64]);
  ("floatMul", [PTI64; PTI64]);
  ("floatDiv", [PTI64; PTI64]);
  ("floatPow", [PTI64; PTI64]);
  ("floatExp", [PTI64]);
  ("floatNeg", [PTI64]);
  ("floatRand", []);
  ("floatPi", []);
  ("floatCos", [PTI64]);
  ("floatSin", [PTI64]);
  ("floatSqrt", [PTI64]);
  ("floatLog", [PTI64]);
  ("floatLt", [PTI64; PTI64]);
  ("floatLeq", [PTI64; PTI64]);
  ("mathAbs", [PTI64]);
  ("boolAnd", [PTI64; PTI64]);
  ("boolOr", [PTI64; PTI64]);
  ("arrayMake", [PTI64]);
  ("arrayMakeInit", [PTI64; PTI64]);
  ("arrayLen", [PTArrayP]);
  ("arrayAt", [PTArrayP; PTI64]);
  ("arraySet", [PTArrayP; PTI64; PTI64]);
  ("arrayPush", [PTArrayP; PTI64]);
  ("arrayPop", [PTArrayP]);
  ("arrayPrint", [PTArrayP]);
  ("arrayPrintChars", [PTArrayP]);
  ("pairMake", [PTI32; PTI32]);
  ("pairFst", [PTI64]);
  ("pairSnd", [PTI64]);
  ("strPrint", [PTStringP]);
  ("strConcat", [PTStringP; PTStringP]);
  ("strEq", [PTStringP; PTStringP]);
  ("strcmp", [PTStringP; PTStringP]);
  ("strlen", [PTStringP]);
  ("strCharAt", [PTStringP; PTI64])
]

let gen_prim_type = function
| PTI32 -> "(int32_t)"
| PTI64 -> "(int64_t)"
| PTDouble -> "(double)"
| PTNodeP -> "(node_t*)"
| PTTreeP -> "(tree_t*)"
| PTQueueP -> "(queue_t*)"
| PTStringP -> "(char*)"
| PTArrayP -> "(array_t*)"