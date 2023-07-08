# Short benchmark name

*A description of the benchmark.*

*Describe the algorithm of the benchmark perhaps with a small example.*

*Describe the type and shape of the input and output data.*

*If a specific version of an algorithm is used, provide a detailed description
and possible code sample to explain how it should be implemented.*

*If the benchmark relies on more complicated input generated from input value
(binary tree, random graph, ...), provide a code sample that generates it from
the input parameters.*

*If the generation of input data is time-consuming, it is ok to run the
benchmark multiple times on the same generated input for more accurate results.
Be careful that a smart compiler will not optimize the multiple runs away and
clearly state the number of times the computation should be repeated.*

## Examples

### Small

*Provide a small input output pair for testing, runtime should be a few milliseconds.*

Input: 5

Output: 120

### Large

*Provide a large input output pair for benchmarking, runtime should be a few seconds.*

Input: 10

Output: 3628800

## Metadata

### Labels (Optional)

*Optional labels to help categorize the benchmark.
If currently available labels in `../LABLES.md` do not sufficiently capture the classification, you are welcome to add new ones.
If you do add a new label, be sure to add it to applicable existing benchmarks.*

Example:
MULTIPLE_RESUMPTIONS, CONCURRENCY, MULTIPLE_RESUMPTIONS

### References (Optional)

*If this or a similar benchmark appeared in the literature provide the reference and explain the difference.*

### Rationale (Optional)

*Provide a short rationale for the benchmark.
Describe what it measures and why it is important to measure it.*

Example:
This benchmark measures the performance of deeply nested handlers.
This is a good benchmark to measure the performance of selecting the correct handler for performed effect.

