# Product early

Compute the product of a list of numbers and abort early if encountering a `0`
in a non-tail recursive way. Run this on a descending list of 1000 numbers
ending in a `0`. Iterate this `n` times.

Input is the number of times the product of the list should be computed.

Output is the sum of the products of the list which is always `0`.

## Examples

### Small

Input: 5

Output: 0

### Large

Input: 100000

Output: 0

## Metadata

### Labels

### References

Extensible Effects

Freer Monads, More Extensible Effects

### Rationale

We build a stack with 1000 frames and discard them.

