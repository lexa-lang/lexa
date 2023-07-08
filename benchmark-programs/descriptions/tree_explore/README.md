# Tree explore

The goal of this benchmark is to compute the maximal result of reducing a binary
operation over all possible paths from the root to the leaves in a full binary
tree 10 times.

Effect handlers are used to simulate non-determinism when exploring the tree.
Leaf value is determined by the global state. The initial value of the state is
`0`. Before descending into a child subtree, the state is updated as `state :=
op state node_value`. The value of leaf is defined as the current value of the
`state`. The global state can be implemented in a way which is most idiomatic
for the target language. The full benchmark is repeated 10 times, each time,
result from the previous traversal is taken as the initial value of the state.

Tree should be explored in a depth-first manner. Left subtree should be explored
before right subtree and `op` should be right reduced over the path. State
should be updated in way such that every resumption of the continuation updates
it.

The values in the binary tree nodes are defined in the same way as in
[002_generator](./002_generator.md). If the height is 0, then the tree has no
nodes. Hence, the output should be 0. If the tree has height `h`, then the root
node has value `h`, all the nodes in the next level have value `h-1`, all the
nodes in the subsequent level have value `h-2`, and so on.

The binary tree should be constructed using a space-efficient DAG representation
which represents complete binary tree of height `h` with `h` nodes. The OCaml
function `make_tree` below constructs such a complete binary tree:

```ocaml
type 'a tree =
| Leaf
| Node of 'a tree * 'a * 'a tree

let rec make_tree = function
  | 0 -> Leaf
  | n -> let t = make_tree (n-1) in Node (t,n,t)
```

The binary operation is defined as:

```ocaml
let op x y = (abs (x - 503*y + 37)) mod 1009
```

Tree of height `2` would produce the following possible paths:

```ocaml
[[2; 1; 503]; [2; 1; 37], [2; 1; 466]; [2; 1; 0]]
```

with results:

```ocaml
[op 2 (op 1 503); op 2 (op 1 37); op 2 (op 1 466); op 2 (op 1 0)]
- : [393; 858; 562; 913]
```

And the maximal value of `913`.

The input is the height of the complete binary tree.

The output is the maximal value of the fold operation over all paths from the
root to leaves.

## Examples

### Small

Input: 5

Output: 946

### Large

Input: 16

Output: 1005

## Metadata

### Labels

BACKTRACKING, MULTIPLE_RESUMPTIONS

### References

### Rationale

This benchmark measures the performance of state with multiple resumptions.

