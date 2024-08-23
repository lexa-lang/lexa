# N-Queens Problem

The goal of the benchmark is to calculate the number of safe assignments of
queens on a N x N chess board. Effect handlers are utilised for backtracking
search.

Compute the number of solutions to the N-Queens problem. Use brute force search
without any heuristics or symmetries to speed up the search. Use the effect
`Pick : int -> int` which continues the search for every cell in the current
column and `Fail : unit -> void` to fail the search.

The input is the size `N` of the chess board.

The output is the number of solutions.

## Examples

### Small

Input: 5

Output: 10

### Large

Input: 12

Output: 14200

## Metadata

### Labels

BACKTRACKING, MULTIPLE_RESUMPTIONS

### References

### Rationale

