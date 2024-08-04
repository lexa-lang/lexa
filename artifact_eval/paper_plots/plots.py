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
from config import config, platforms, benchmarks, bench_CPUs

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
    config = {(platform, benchmark): params for (platform, benchmark), params in config.items() if benchmark == "scheduler"}
    
    config_tups = [(platform, benchmark, i, params) for i in range(0, params["bench_input"], 10) for (platform, benchmark), params in config.items()]

    # Build
    with ThreadPoolExecutor(max_workers=len(bench_CPUs)) as executor:
        executor.map(
            lambda c: build(f"../benchmark-programs/{c[0]}/{c[1]}", c[3]["build"]),
            config_tups
        )

    with ThreadPoolExecutor(max_workers=len(bench_CPUs)) as executor:
        results_generator = executor.map(
            lambda c: 
                (c[0], 
                c[1],
                c[2],
                int(build_and_bench(f"../benchmark-programs/{c[0]}/{c[1]}", c[3]["build"], c[3]["run"], c[3]["bench_input"], c[3].get("adjust_warmup", False))
                    * c[3].get("scale", 1))
                )
                if "fail_reason" not in c[3] else (c[0], c[1], c[2], None),
            config_tups
        )
        with open(result_txt, 'w') as f:
            for platform, benchmark, time_mili in results_generator:
                results += [(platform, benchmark, time_mili)]
                f.write(f"{platform:<15} {benchmark:<30} {time_mili}\n")
                f.flush()

if __name__ == "__main__":
    main()