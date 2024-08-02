import matplotlib.pyplot as plt
import subprocess
from concurrent.futures import ThreadPoolExecutor
import re
import argparse

import sys, os
chemin_actuel = os.path.dirname(os.path.abspath(__file__))
chemin_parent = os.path.dirname(chemin_actuel)
sys.path.append(chemin_parent)

from utils import *

IN_VAL_PLACEHOLDER = "IN"

def plot(result_file, title, plot_file, overhead_sec):
    plt.figure(figsize=(6,6))

    n_values, runtimes = zip(*parse_output(result_file))
    runtimes = [r - overhead_sec for r in runtimes]
    plt.plot(n_values, runtimes, marker='o', alpha=1)

    plt.xlabel('n')
    plt.ylabel('Runtime (seconds)')
    plt.title(title)
    plt.grid(True)
    plt.savefig(plot_file, dpi=600)

    print_message(f"\"{title}\" saved to {plot_file}")
    
def main():
    cmds = {
        "scheduler" : {
            "lexi" : {
                "build" : "dune exec -- sstal main.ir -o main.c; clang -O3 -g -I ../../../stacktrek main.c -o main",
                "run" : f"./main {{{IN_VAL_PLACEHOLDER}}}",
                "max_input" : 3000,
            },
            "effekt" : {
                "build" : "effekt_latest.sh --backend js --compile main.effekt",
                # 0 in the run command is a dummy second argument to tell the program to measure its internal timing
                "run" : f"node --eval \"require(\'\"\'./out/main.js\'\"\').main()\" -- _ {{{IN_VAL_PLACEHOLDER}}} 0",
                "max_input" : 3000,
                "adjust_warmup" : True
            },
            "koka" : {
                "build" : "koka -O3 -v0 -o main main.kk ; chmod +x main",
                "run" : f"./main {{{IN_VAL_PLACEHOLDER}}}",
                "max_input" : 3000,
            },
            "koka_named" : {
                "build" : "koka -O3 -v0 -o main main.kk ; chmod +x main",
                "run" : f"./main {{{IN_VAL_PLACEHOLDER}}}",
                "max_input" : 3000,
                "fail_reason" : "Koka internal compiler error",
            },
            "ocaml" : {
                "build" : "opam exec --switch=4.12.0+domains+effects -- ocamlopt -O3 -o main main.ml",
                "run" : f"./main {{{IN_VAL_PLACEHOLDER}}}",
                "max_input" : 1000,
            }
        },


        "resume_nontail_with_stack_growth" : {
            # "lexi" : {
            #     "build" : "dune exec -- sstal main.ir -o main.c; clang -O3 -g -I ../../../stacktrek main.c -o main",
            #     "run" : f"./main {{{IN_VAL_PLACEHOLDER}}}",
            #     "max_input" : 60000,
            # },
            # "effekt" : {
            #     "build" : "effekt_latest.sh --backend ml --compile main.effekt",
            #     # 0 in the run command is a dummy second argument to tell the program to measure its internal timing
            #     "run" : f"./main {{{IN_VAL_PLACEHOLDER}}}",
            #     "max_input" : 60000,
            # },
            # "koka" : {
            #     "build" : "koka -O3 -v0 -o main main.kk ; chmod +x main",
            #     "run" : f"./main {{{IN_VAL_PLACEHOLDER}}}",
            #     "max_input" : 1000,
            # },
            # "koka_named" : {
            #     "build" : "koka -O3 -v0 -o main main.kk ; chmod +x main",
            #     "run" : f"./main {{{IN_VAL_PLACEHOLDER}}}",
            #     "max_input" : 1000,
            # },
            # "ocaml" : {
            #     "build" : "opam exec --switch=4.12.0+domains+effects -- ocamlopt -O3 -o main main.ml",
            #     "run" : f"./main {{{IN_VAL_PLACEHOLDER}}}",
            #     "max_input" : 40000,
            # }
        }
    }
    for bench, sys_cmds in cmds.items():
        for sys, cmds in sys_cmds.items():
            if "fail_reason" in cmds:
                print_message(f"Skipping {sys} {bench} due to {cmds['fail_reason']}")
                continue
            path = f"../../benchmark-programs/{sys}/{bench}"
            result_file = f"{sys}_{bench}.csv"
            num_input = 10
            build_and_bench(path, cmds["build"], cmds["run"], cmds["max_input"], num_input, result_file)
            overhead_sec = 0
            if "adjust_warmup" in cmds:
                overhead_sec = bench_warnup_overhead(path, cmds["run"])
            plot(result_file, f"{sys.capitalize()} {bench}", f"{sys}_{bench}.png", overhead_sec)

if __name__ == "__main__":
    main()