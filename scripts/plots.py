import matplotlib
import matplotlib.pyplot as plt
try:
    import scienceplots # In nix, it is installed through a manual installation
except ImportError:
    pass
from mpl_toolkits.axisartist.axislines import AxesZero
import subprocess
from concurrent.futures import ThreadPoolExecutor
import re
import argparse
import pandas as pd
import numpy as np
plt.rcParams['pdf.fonttype'] = 42
plt.rcParams['ps.fonttype'] = 42

matplotlib.use("pgf")
preamble = r'\usepackage{fontspec}\setmainfont{Linux Libertine O}\setmonofont[Scale=MatchLowercase]{JetBrains Mono}\usepackage{xcolor}'
params = {
    'font.family': 'serif',
    'text.usetex': True,
    # 'text.latex.unicode': True,
    'pgf.rcfonts': False,
    'pgf.texsystem': 'xelatex',
    'pgf.preamble': preamble,
    'font.size': 12,
    'xtick.labelsize': 8,
    'ytick.labelsize': 8,
}
plt.rcParams.update(params)


plt.rc('text.latex', preamble=r'\usepackage{amsmath}')


import sys, os
chemin_actuel = os.path.dirname(os.path.abspath(__file__))
chemin_parent = os.path.dirname(chemin_actuel)
sys.path.append(chemin_parent)

from utils import *

plt.style.use(['science'])#, "no-latex"])

# This plots all benchmarks scaling plots
def plot_df(df, dirname):

    def process_platform_name(name, benchmark):
        if name == "koka":
            return "Koka (regular)"
        if name == "koka_named":
            return "Koka (named)"
        if name == "effekt":
            if benchmark.rstrip("$") in ["generator", "handler_sieve"]:
                return "Effekt (Scheme)"
            if benchmark.rstrip("$") in ["scheduler", "interruptible_iterator"]:
                return "Effekt (JS)"
            return "Effekt"
        if name == "lexi":
            return r"\textsc{Lexa}"
        if name == "ocaml":
            return "OCaml"
        if name == "nqueens":
            return "NQueens"
        return name.replace("_", " ").rstrip("$").title()

    def process_benchmark_name(name):
        if name == "nqueens":
            return "NQueens"
        return name.replace("_", " ").rstrip("$").title()
    
    special = [
        # ("koka", "resume_nontail_2"),
        # ("koka_named", "resume_nontail_2"),
        ("effekt", "interruptible_iterator"),
        ("effekt", "scheduler"),
        ("ocaml", "interruptible_iterator")
    ]
    for idx, row in df.iterrows():
        benchmark = row['benchmark']
        platform = row['platform']
        if (platform, benchmark) in special:
            df.loc[idx, 'benchmark'] = benchmark + "$"
        if platform == "lexi" and benchmark in [t[1] for t in special]:
            row['benchmark'] = benchmark + "$"
            df.loc[df.index.max() + 1] = row

    colors = {
        "lexi": "#3572EF",
        "effekt": "green",
        "koka": "red",
        "koka_named": "orange",
        "ocaml": "purple"
    }
    markers = {
        "lexi": ".",
        "effekt": ".",
        "koka": ".",
        "koka_named": "x",
        "ocaml": "x",
    }
    fig, axs = plt.subplots(4, 4, figsize=(10, 13))
    fig.supxlabel('Input size', fontsize=14)
    fig.supylabel('Running time (s)', fontsize=14)
    for i, benchmark in enumerate(df['benchmark'].unique()):
        ax1 = axs[i//4, i%4]
        # ax2 = ax1.twinx()
        # ax2.set_visible(False)
        df['time_sec'] = df['time_mili'] / 1000
        for platform in df['platform'].unique():
            subset = df[(df['benchmark'] == benchmark) & (df['platform'] == platform)]
            if not subset.empty and not pd.isna(subset.iloc[0]['time_sec']):
                l, = ax1.plot(subset['n'], subset['time_sec'], label=process_platform_name(platform, benchmark), marker=markers[platform], alpha=0.8, color=colors[platform], markersize=5, linewidth=1.0)
        if benchmark.endswith("$"):
            title = r'{\bfseries ' + process_benchmark_name(benchmark) + '}'
        else:
            title = process_benchmark_name(benchmark)
        ax1.set_title(title, fontsize=14, pad=10)
        ax1.legend(loc='upper left')
        # ax2.legend(loc='upper right')

        plt.ticklabel_format(axis='y', style='plain')
        ax1.grid(True)

    plt.tight_layout(pad=0, rect=(0.028,0.025,1,1))

    filename = "scaling_plot.pdf"
    plt.savefig(dirname + filename, dpi=600)


# This plots the effekt vs lexa scaling plot
def plot_df2(df, dirname):
    fig, axs = plt.subplots(1, 2, figsize=(6, 2.5))
    fig.supylabel('Running time (s)', fontsize=12)
    for i, platform in enumerate(["effekt", "lexi"]):
        ax1 = axs[i]
        # if i == 0:
        #     ax1.set_ylabel('Running time (s)')
        ax1.set_xlabel('Input size')
        df['time_sec'] = df['time_mili'] / 1000
        for color, benchmark in [("#0C1844", "scheduler_notick"), ("#C80036", "scheduler")]:
            subset = df[(df['benchmark'] == benchmark) & (df['platform'] == platform)]
            label = r"with \texttt{Tick}" if benchmark == "scheduler" else r"without \texttt{Tick}"
            l, = ax1.plot(subset['n'], subset['time_sec'], label=label, marker='.' if benchmark == "scheduler" else 'x', alpha=0.8, color=color, markersize=5, linewidth=1.10)

        ax1.set_title('Scheduler program in ' + (r'\textsc{Lexa}' if platform == "lexi" else 'Effekt'), fontsize=13, pad=20)
        ax1.legend(loc='upper left')

        plt.ticklabel_format(axis='y', style='plain')
        ax1.grid(True)

    fig.subplots_adjust(wspace=2)
    plt.tight_layout(pad=0, rect=(0.07,0,1,1))

    filename = "two_scaling_plot.pdf"
    plt.savefig(dirname + filename, dpi=600)


def main():
    # Parse arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("--plot-only", type=str, default=None)
    parser.add_argument("--tick-plot", action="store_true")
    parser.add_argument("--quick", action="store_true")
    parser.add_argument("--output-dir", type=str, default='./scaling_plots/')
    args = parser.parse_args()

    if args.tick_plot:
        plot_fun = plot_df2
    else:
        plot_fun = plot_df

    if args.plot_only:
        df = pd.read_csv(args.plot_only)
        plot_fun(df, args.output_dir)
        return

    from config import config, platforms, benchmarks, bench_CPUs

    if args.tick_plot:
        result_txt = "plotting_runtimes2.txt"
        result_csv = "plotting_runtimes2.csv"
        for benchmark in ["scheduler_notick"]:
            LEXI_BUILD_COMMAND = "../../../_build/default/bin/main.exe main.lx -o main.c && clang -O3 -g -I ../../../stacktrek main.c -o main -lm"
            LEXI_RUN_COMMAND = "./main {IN}"
            config[("lexi", benchmark)] = {
                "build": LEXI_BUILD_COMMAND, "run": LEXI_RUN_COMMAND,
            }

            EFFEKT_BUILD_COMMAND = "effekt_latest.sh --backend ml --compile main.effekt && mlton -default-type int64 -output main out/main.sml"
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
        result_txt = "plotting_runtimes.txt"
        result_csv = "plotting_runtimes.csv"
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
    plot_fun(df, args.output_dir)

if __name__ == "__main__":
    main()
