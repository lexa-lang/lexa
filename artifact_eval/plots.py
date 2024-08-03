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

result_txt = "plotting_runtimes.txt"

def main():
    from config import config, platforms, benchmarks, bench_CPUs
    config = {(platform, benchmark): params for (platform, benchmark), params in config.items() if benchmark == "tree_explore"}

    # Build
    config_tups = [(platform, benchmark, 0, params) for (platform, benchmark), params in config.items()]
    with ThreadPoolExecutor(max_workers=len(bench_CPUs)) as executor:
        executor.map(
            lambda c: build(f"../benchmark-programs/{c[0]}/{c[1]}", c[3]["build"]),
            config_tups
        )

    # Run for sequence of inputs
    results = []
    config_tups = [(platform, benchmark, i, params) for (platform, benchmark), params in config.items() for i in range(0, params["bench_input"]+1, int(params["bench_input"]/10))]
    with ThreadPoolExecutor(max_workers=len(bench_CPUs)) as executor:
        results_generator = executor.map(
            lambda c: 
                (c[0], 
                c[1],
                c[2],
                int(bench(f"../benchmark-programs/{c[0]}/{c[1]}", c[3]["run"], c[2], c[3].get("adjust_warmup", False))
                    * c[3].get("scale", 1))
                )
                if "fail_reason" not in c[3] else (c[0], c[1], c[2], None),
            config_tups
        )
        with open(result_txt, 'w') as f:
            for platform, benchmark, i, time_mili in results_generator:
                results += [(platform, benchmark, i, time_mili)]
                f.write(f"{platform:<15} {benchmark:<30} {i:<10} {time_mili}\n")
                f.flush()

    # Plot
    import pandas as pd
    df = pd.DataFrame(results, columns=["platform", "benchmark", "n", "time_mili"])
    print(df)
    for benchmark in df['benchmark'].unique():
        plt.figure()
        for platform in df['platform'].unique():
            subset = df[(df['benchmark'] == benchmark) & (df['platform'] == platform)]
            plt.plot(subset['n'], subset['time_mili'], label=platform, marker='o', alpha=0.9)

        plt.xlabel('n')
        plt.ylabel('Runtime (mili-seconds)')
        plt.title(benchmark)
        plt.legend()
        plt.grid(True)

        plt.yscale('log')

        plt.savefig(f"./plots/scaling_plot_{benchmark}.png", dpi=600)

if __name__ == "__main__":
    main()