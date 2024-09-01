# Lexa Compiler

## Overview
Lexa is a compiler designed to implement lexically scoped effect handlers, a language-design concept that equips algebraic effects with modular semantics for both robust local-reasoning and expressive control-flow management.

See the paper "Lexical Effect Handlers, Directly" for more information.

## Getting Started

### Prerequisites
We currently only support x86-64 platform.

### Setup
1. **Install Nix**: Follow the instructions at [NixOS](https://nixos.org/download.html) to install Nix on your system.
2. **Clone the Repository**: Clone the Lexa repository to your local machine.
3. **Build the Development Environment**: Run `nix develop` in the root directory of the repository to build the development environment.
4. **Build the Project**: Run `dune build` to build the compiler.

### Running the Compiler
To run the Lexa compiler, use the following command:
```bash
./lexa <source_file>
```
See `./casestudies  `  and `./test` for exmaple Lexa programs.

### Reproduce the result in OOPSLA'24 paper
1. **Figure 2**: Run `cd scripts; python ./plots.py --tick-plot --plot-only ./final_plotting_runtimes2.csv`, the plot will be saved in `./scaling_plots/two_scaling_plot.pdf`. To plot using fresh data, run `python ./plots.py --tick-plot`.
2. **Table 1**: Run `cd scripts; python bench.py`, the result will be saved in `./runtimes.csv`.
3. **Figure 16**: Run `cd scripts; python ./plots.py --plot-only ./final_plotting_runtimes.csv`, the plot will be saved in `./scaling_plots/scaling_plot.pdf`. To plot using fresh data, run `python ./plots.py`.