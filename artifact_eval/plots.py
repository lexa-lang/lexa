import matplotlib.pyplot as plt
import subprocess
from concurrent.futures import ThreadPoolExecutor
import re
import argparse
import pandas as pd

import sys, os
chemin_actuel = os.path.dirname(os.path.abspath(__file__))
chemin_parent = os.path.dirname(chemin_actuel)
sys.path.append(chemin_parent)

from utils import *

def plot_df(df):
    for benchmark in df['benchmark'].unique():
        plt.figure()
        for platform in df['platform'].unique():
            subset = df[(df['benchmark'] == benchmark) & (df['platform'] == platform)]
            if subset['time_mili'].isna().any():
                plt.plot([], [], label=platform + " (Not Available)", marker='o', alpha=0.8)
            else:
                plt.plot(subset['n'], subset['time_mili'], label=platform, marker='o', alpha=0.8)

        plt.xlabel('Input size')
        plt.ylabel('Runtime (mili-seconds)')
        plt.title(benchmark)
        plt.legend()
        plt.grid(True)

        plt.savefig(f"./plots/scaling_plot_{benchmark}.png", dpi=600)
        print_message(f"\"{benchmark}\" saved to ./plots/scaling_plot_{benchmark}.png")

result_txt = "plotting_runtimes.txt"
result_csv = "plotting_runtimes.csv"

def main():
    # Parse arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("--plot-only", action="store_true")
    args = parser.parse_args()
    if args.plot_only:
        df = pd.read_csv(result_csv)
        plot_df(df)
        return
    from config import config, platforms, benchmarks, bench_CPUs
    config = {(platform, benchmark): params for (platform, benchmark), params in config.items() }

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
    df = pd.DataFrame(results, columns=["platform", "benchmark", "n", "time_mili"])
    df.to_csv(result_csv)
    plot_df(df)

if __name__ == "__main__":
    main()