type prim_type =
  | PTI64 (* int64_t *)
  | PTNodeP (* node_t* *)
  | PTTreeP (* tree_t* *)
  | PTQueueP (* queue_t* *)

type prim_env = (string * prim_type list) list

exception UndefinedPrimitive of string
exception InvalidPrimitiveCall of string

let prim_env = [
  ("listNode", [PTI64; PTNodeP]);
  ("listEnd", []);
  ("listIsEmpty", [PTNodeP]);
  ("listHead", [PTNodeP]);
  ("listTail", [PTNodeP]);
  ("listAppend", [PTNodeP; PTNodeP]);
  ("listMax", [PTNodeP]);
  ("treeNide", [PTI64; PTTreeP; PTTreeP]);
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
  ("printInt", [PTI64])
]

let gen_prim_type = function
| PTI64 -> "(int64_t)"
| PTNodeP -> "(node_t*)"
| PTTreeP -> "(tree_t*)"
| PTQueueP -> "(queue_t*)"


   