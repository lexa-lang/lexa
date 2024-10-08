# A compiler for the Lexa programming language

## Overview

Lexa is a programming language supporting *lexically scoped effect handlers*.
These effect handlers are a powerful means to express and manage [complex](https://dl.acm.org/doi/10.1145/3428207) control flow.
They allow for [strong local-reasoning principles](https://dl.acm.org/doi/10.1145/3290318), too.

This repository contains an implementation of Lexa. The compiler **translates high-level, modular algebraic effects to low-level, swift stack switching**.
The design and implementation of the Lexa compiler are described in the following paper:

> Cong Ma, Zhaoyi Ge, Edward Lee, Yizhou Zhang.  
> [Lexical Effect Handlers, Directly](https://dl.acm.org/doi/10.1145/3689770).  
> Proceedings of the ACM on Programming Languages (PACMPL), Volume 8, Issue OOPSLA2, October 2024.

## Getting started

### Prerequisites
* Supported platform: x86-64.
* 32GB of RAM recommended for building.

### Setup using Docker (recommended for evaluation)
```
docker run -it hflsmax/lexa-lang:OOPSLA24
```

### Setup using Nix (recommended for development)
1. **Install Nix**: Follow the [instructions](https://nixos.org/download.html) to install Nix on your system.
2. **Clone the repository**: Clone the Lexa repo to your local machine.
3. **Build the development environment**: Run `nix develop` in the repository root. This could take over an hour.
4. **Build the project**: Run `dune build` to build the compiler.

### Running the Compiler
To run the Lexa compiler, use the following commands:
```bash
./lexa <source_file>
./a.out
```
See `./casestudies`  and `./test` for exmaple Lexa programs.

## Reproducing the results in the OOPSLA 2024 paper
1. Follow the instructions above to set up the project.
2. **Figure 2**: Run `cd scripts; python ./plots.py --tick-plot --plot-only ./final_plotting_runtimes2.csv`. The plot will be saved in `./scaling_plots/two_scaling_plot.pdf`. To plot using fresh data, run `python ./plots.py --tick-plot`.
3. **Table 1**: Run `cd scripts; python bench.py`. The result will be saved in `./runtimes.csv`.
4. **Figure 16**: Run `cd scripts; python ./plots.py --plot-only ./final_plotting_runtimes.csv`. The plot will be saved in `./scaling_plots/scaling_plot.pdf`. To plot using fresh data, run `python ./plots.py`.
5. **Test formalized translation**: Run `cd src/formalized_translation; racket artifact.rkt`.

## Contact/Contribute
Please reach out to Cong Ma (cong.ma@uwaterloo.ca) for any questions. We welcome contributions to the project.
