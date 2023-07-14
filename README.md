# Artifact for the OOPSLA 2023 paper 'From Capabilities to Regions'

[![DOI](https://zenodo.org/badge/???.svg)](https://zenodo.org/badge/latestdoi/???)

This GitHub repository constitutes the artifact for our paper

> From Capabilities to Regions: Enabling Efficient Compilation of Lexical Effect Handlers.
> Marius Müller, Philipp Schuster, Jonathan Lindegaard Starup, Klaus Ostermann, Jonathan Immanuel Brachthäuser.
> Conditionally accepted at OOPSLA 2023.

## Overview

The artifact consists of the benchmarks conducted for the evaluation of the compilation approach presented in the paper.

The benchmark programs are taken from a [community benchmark suite](https://github.com/effect-handlers/effect-handlers-bench) that has been designed specifically for effect-handler implementations.
This repository contains the sources of the [benchmark programs](./benchmark-programs) for all languages we have benchmarked against.
In addition to the languages taken from the community benchmark suite, we have added our own implementations of these programs in Effekt and hand-optimized versions in SML.
There are also [descriptions](./benchmark-programs/descriptions) of what each benchmark program does.

Moreover, this repository contains a [`Dockerfile`](./Dockerfile) which can be used to build a Docker image for a container with all necessary languages installed.
The benchmarks can hence be run inside this container.

For comparison, there are also two files containing results:
- [`results-paper.md`](./results-paper.md) which contains the results from the paper extended with a column for the newly added SML versions
- [`results-example.md`](./results-example.md) which contains the results from a run of the benchmarks in the container on an Intel(R) Core(TM) i5-8265U

### Additional Instructions
Please find additional instructions in the following two files:

- [`GETTING-STARTED.md`](./GETTING-STARTED.md) for the kick-the-tires phase.
- [`STEP-BY-STEP.md`](./STEP-BY-STEP.md) for suggestions on how to proceed with the evaluation of the artifact.
