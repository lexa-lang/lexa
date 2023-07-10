## Step-By-Step

> **Availability**: We will make our artifact available via Zenodo.

We provide an artifact that supports the claims about the evaluation of our compilation approach made in the paper.

The [GETTING-STARTED.md](./GETTING-STARTED.md) guide explains how to set up the artifact.
Here, we describe in more detail, how the artifact supports the claims.

### Claims supported by the artifact

The benchmarks of course do not really support the theorems stated in the paper (for which we have pen-and-paper proofs).
Still, having an implemented compiler for our approach, which produces correct results for the given programs, gives some confidence in the correctness.
After entering the container (as described in the [GETTING-STARTED.md](./GETTING-STARTED.md) guide), reviewers can also make changes to the existing programs or write their own programs in Effekt.
The container has vim installed as an editor, but it runs Ubuntu and other editors can be installed in the usual way for Ubuntu.
Alternatively, the source file can be written outside of the container and copied inside via

```
docker cp /path/to/source liftinf-bench-container:/home/ubuntu/benchmark-programs/path/to/destination
```

The source file can compiled with

```
effekt.sh --backend ml --compile main.effekt; mlton -default-type int64 -output main out/main.sml
```

given that it is named `main.effekt`.
This results in an executable `main` which can be called with

```
./main
```

or potentially with additional command-line arguments (see one of the benchmark programs on how to use command-line arguments).
Note, however, that due to limitations of SML the compiler does neither support higher-rank-polymorphic function types nor polymorphic effect signatures.

In section 4.2.2, we claim that

> Effekt outperforms the other languages in most benchmarks, sometimes by an order of magnitude.

While the numbers of the benchmark can vary a bit due the virtualization overhead of Docker, the speedups of Effekt relative to the other languages shown in Figure 10 in the paper should still be mostly visible.

### Suggested steps for evaluation

We suggest that the reviewers:
1. Familiarize themselves with the benchmark programs by reading the [desciptions](./benchmark-programs/descriptions).
2. Run the benchmarks.
3. Compare the results of the benchmarks with the numbers given in the paper, verifying that the relative speedups are mostly reproducible despite the virtualization via Docker.
4. Potentially modify the given programs or write programs of their own and compile them with the Effekt compiler in the Docker container to verify that it works correctly.
