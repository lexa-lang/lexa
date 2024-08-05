import matplotlib
import matplotlib.pyplot as plt
from mpl_toolkits.axisartist.axislines import AxesZero
import subprocess
from concurrent.futures import ThreadPoolExecutor
import re
import argparse
import pandas as pd
import numpy as np
matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42

import sys, os
chemin_actuel = os.path.dirname(os.path.abspath(__file__))
chemin_parent = os.path.dirname(chemin_actuel)
sys.path.append(chemin_parent)

from utils import *

plt.style.use(['science', "no-latex"])

# This plots all benchmarks scaling plots
def plot_df(df):
    def process_name(name):
        if name == "koka":
            name = "Koka (regular)"
        if name == "koka_named":
            name = "Koka (named)"
        if name == "effekt":
            name = "Effekt"
        if name == "lexi":
            name = "Lexi"
        if name == "ocaml":
            name = "OCaml"
        return name
    twinx = [
        # ("koka", "concurrent_search"),
        ("koka", "resume_nontail_2"),
        ("koka_named", "resume_nontail_2"),
        ("effekt", "interruptible_iterator"),
        ("effekt", "scheduler"),
    ]
    twinx2 = [
        ("ocaml", "interruptible_iterator")
    ]
    colors = {
        "lexi": "blue",
        "effekt": "green",
        "koka": "red",
        "koka_named": "orange",
        "ocaml": "purple"
    }
    fig, axs = plt.subplots(5, 3, figsize=(10, 15))
    for i, benchmark in enumerate(df['benchmark'].unique()):
        if i // 3 == 4:
            # Last row only has one plot
            ax1 = axs[4, 1]
            ax1.set_ylabel('Runtime (s)')
        else:
            ax1 = axs[i//3, i%3]
            if i % 3 == 0:
                ax1.set_ylabel('Runtime (s)')
        plt.xlabel('Input size')
        ax2 = ax1.twinx()
        ax3 = ax1.twinx()
        ax2.set_visible(False)
        ax3.set_visible(False)
        ax3.spines.right.set_position(("axes", 1.2))
        df['time_sec'] = df['time_mili'] / 1000
        for platform in df['platform'].unique():
            subset = df[(df['benchmark'] == benchmark) & (df['platform'] == platform)]
            if subset['time_sec'].isna().any():
                continue
            else:
                if (platform, benchmark) in twinx:
                    p2, = ax2.plot(subset['n'], subset['time_sec'], label=process_name(platform), marker='x', alpha=0.5, color=colors[platform], markersize=5)
                    ax2.set_visible(True)
                elif (platform, benchmark) in twinx2:
                    p3, = ax3.plot(subset['n'], subset['time_sec'], label=process_name(platform), marker='x', alpha=0.5, color=colors[platform], markersize=5)
                    ax3.set_visible(True)
                else:
                    l, = ax1.plot(subset['n'], subset['time_sec'], label=process_name(platform), marker='o', alpha=0.5, color=colors[platform], markersize=5)
                    
        ax1.set_title(benchmark.replace("_", " ").title(), fontsize=20)
        ax1.legend(loc='upper left')
        ax2.legend(loc='upper right')
        ax3.legend(loc='lower right')

        if ax3._visible:
            ax3.tick_params(axis='y', colors=p3.get_color())
            ax2.tick_params(axis='y', colors=p2.get_color())

        plt.ticklabel_format(axis='y', style='plain')
        ax1.grid(True)

    plt.tight_layout(pad=0)

    axs[4, 0].remove()
    axs[4, 2].remove()

    plt.savefig(f"./scaling_plots/scaling_plot.eps", dpi=600)
    plt.savefig(f"./scaling_plots/scaling_plot.png", dpi=600)
    print_message(f"\"{benchmark}\" scaling plot saved to ./scaling_plots/scaling_plot.eps")


# This plots the Effekt vs Lexi scaling plot
def plot_df2(df):
    def process_name(name):
        if name == "koka":
            name = "Koka (regular)"
        if name == "koka_named":
            name = "Koka (named)"
        if name == "effekt":
            name = "Effekt"
        if name == "lexi":
            name = "Lexi"
        if name == "ocaml":
            name = "OCaml"
        return name
    fig, axs = plt.subplots(1, 2, figsize=(7, 2.5))
    for i, platform in enumerate(["effekt", "lexi"]):
        ax1 = axs[i]
        df['time_sec'] = df['time_mili'] / 1000
        for benchmark in ["scheduler_notick", "scheduler"]:
            subset = df[(df['benchmark'] == benchmark) & (df['platform'] == platform)]
            label = "With Tick" if benchmark == "scheduler" else "Without Tick"
            l, = ax1.plot(subset['n'], subset['time_sec'], label=label, marker='o', alpha=0.5, markersize=5)

        if i == 0:
            ax1.set_ylabel('Runtime (s)')
        ax1.set_xlabel('Input size')
        ax1.set_title(f"{platform.title()}'s Scheduler with and without Tick", fontsize=12)
        ax1.legend(loc='upper left')

        plt.ticklabel_format(axis='y', style='plain')
        ax1.grid(True)

    fig.subplots_adjust(wspace=0.5)

    plt.savefig(f"./scaling_plots/two_scaling_plot.eps", dpi=600)
    plt.savefig(f"./scaling_plots/two_scaling_plot.png", dpi=600)
    print_message(f"\"{benchmark}\" scaling plot saved to ./two_scaling_plots/scaling_plot.eps")


def main():
    # Parse arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("--plot-only", type=str, default=None)
    parser.add_argument("--quick", action="store_true")
    args = parser.parse_args()

    tick_vs_no_tick = False
    if tick_vs_no_tick:
        plot_fun = plot_df2
    else:
        plot_fun = plot_df

    if args.plot_only:
        df = pd.read_csv(args.plot_only)
        plot_fun(df)
        return

    from config import config, platforms, benchmarks, bench_CPUs

    if tick_vs_no_tick:
        result_txt = "plotting_runtimes.txt"
        result_csv = "plotting_runtimes.csv"
        for benchmark in ["scheduler_notick"]:
            LEXI_BUILD_COMMAND = "dune exec -- sstal main.ir -o main.c; clang -O3 -g -I ../../../stacktrek main.c -o main"
            LEXI_RUN_COMMAND = "./main {IN}"
            config[("lexi", benchmark)] = {
                "build": LEXI_BUILD_COMMAND, "run": LEXI_RUN_COMMAND,
            }

            EFFEKT_BUILD_COMMAND = "effekt_latest.sh --backend ml --compile main.effekt ; mlton -default-type int64 -output main out/main.sml"
            EFFEKT_RUN_COMMAND = "./main {IN}"
            config[("effekt", benchmark)] = {
                "build": EFFEKT_BUILD_COMMAND, "run": EFFEKT_RUN_COMMAND,
            }

        for platform in ["lexi", "effekt"]:
            config[(platform, "scheduler_notick")]["bench_input"] = 3000
            config[(platform, "scheduler")]["bench_input"] = 3000

        config[("effekt", "scheduler_notick")]["build"] = "effekt_latest.sh --backend js --compile main.effekt"
        config[("effekt", "scheduler_notick")]["run"] = "node --eval \"require(\'\"\'./out/main.js\'\"\').main()\" -- _ {IN} 0"
        config[("effekt", "scheduler_notick")]["adjust_warmup"] = True
        config[("effekt", "scheduler_notick")]["scale"] = 10
    
        config = {(platform, benchmark): params for (platform, benchmark), params in config.items() if benchmark in ["scheduler_notick", "scheduler"] and platform in ["lexi", "effekt"]}
    else:
        result_txt = "plotting_runtimes2.txt"
        result_csv = "plotting_runtimes2.csv"
        config = {(platform, benchmark): params for (platform, benchmark), params in config.items() }

    if os.path.exists(result_txt):
        os.rename(result_txt, result_txt + ".bak")
    if os.path.exists(result_csv):
        os.rename(result_csv, result_csv + ".bak")

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
                int(bench(f"../benchmark-programs/{c[0]}/{c[1]}", c[3]["run"], c[2], c[3].get("adjust_warmup", False), quick=args.quick)
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
    plot_fun(df)

if __name__ == "__main__":
    main()