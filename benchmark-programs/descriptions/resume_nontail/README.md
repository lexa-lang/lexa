# Resume Nontail

Repeatedly apply an operation in a loop at a non-tail position. Handle the
operation by resuming in non-tail position.

Compute the repeated application of provided operation. The operation is applied
via handling of effect `Operator` which applies an operation on the rest of
computation (recursive call with decremented param) and provided argument. The
continuation should be resumed at a non-tail position as indicated by the
following code.

```ocaml
effect Operator : int -> unit

handle
  let rec loop i =
    if i = 0 then
      initial_value
  else (
    perform (Operator i);
    loop (i - 1)
  )
  in
  loop n
with
  | effect (Operator x) k -> let y = continue k () in abs (x - (503 * y) + 37) mod 1009
```

The full benchmark is repeated `1000` times, each time, the result from the
previous run is taken as the `initial_value`. The initial `initial_value` is
`0`.

Try to call the repeating part of the program in a tail recursive way, as the
stack size of `looper` is expected to be linear in `n`.

The input is a single non-negative integer `n`.

The output is a single integer, operation applied `n` times and repeated `1000`
times.

## Examples

### Small

Input: 5

Output: 37

### Large

Input: 10000

Output: 860

## Metadata

### Labels

SINGLE_RESUMPTION, EXACTLY_ONCE_RESUMPTION, DEEP_RESUMPTION_STACK

### References

### Rationale

The benchmark measures the performance of a deep stack of resumptions applied
exactly once, but in a non tail position.

