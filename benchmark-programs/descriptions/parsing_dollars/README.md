# Parsing Dollars

The idea of this benchmark is to parse a file format where each line contains a
number of dollar characters. The parser will for each line emit the number of
dollars. When it encounters a character that is not a newline nor a dollar it
stops. We then take the sum of emitted numbers. Since we do not want to deal
with characters we simulate them as integers. Since we do not want to deal with
files we simulate a file of `n` lines where line `i` contains `i` hashes.

## Examples

### Small

Input: 10

Output: 55

### Large

Input: 20000

Output: 200010000

## Metadata

### Labels

### References

### Rationale

This benchmark uses multiple effects in a non-trivial way including non-local
control flow.

