type prim_type =
  | PTI64 (* int64_t *)
  | PTNodeP (* node_t* *)
  | PTTreeP (* tree_t* *)
  | PTQueueP (* queue_t* *)
  | PTStringP (* char* *)

type prim_env = (string * prim_type list) list

exception UndefinedPrimitive of string
exception InvalidPrimitiveCall of string

let prim_env = [
  ("lambdaManInit", []);
  ("lambdaManGetWidth", []);
  ("lambdaManGetHeight", []);
  ("lambdaManGetToken", [PTI64; PTI64]);
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
  ("stringMake", [PTI64; PTI64]);
  ("stringSubStr", [PTStringP; PTI64; PTI64]);
  ("stringCharAt", [PTStringP; PTI64]);
  ("stringLen", [PTStringP]);
  ("floatMake", [PTI64; PTI64]);
  ("floatAdd", [PTI64; PTI64]);
  ("floatMul", [PTI64; PTI64]);
  ("floatPrint", [PTI64]);
  ("mathAbs", [PTI64]);
  ("boolAnd", [PTI64; PTI64])
]

let gen_prim_type = function
| PTI64 -> "(int64_t)"
| PTNodeP -> "(node_t*)"
| PTTreeP -> "(tree_t*)"
| PTQueueP -> "(queue_t*)"
| PTStringP -> "(char*)"
