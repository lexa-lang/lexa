#!/usr/bin/env python3

import subprocess
import matplotlib.pyplot as plt
import json
import argparse
import numpy as np


def run_command_with_hyperfine(command, n_values, plot_file):
    runtimes = []

    for n in n_values:
        cmd = f"hyperfine -w 3 --export-json results.json '{command} {n}'"
        subprocess.run(cmd, shell=True)
        
        with open("results.json", "r") as results_file:
            results = json.load(results_file)
            mean_runtime = results['results'][0]['mean']
            runtimes.append(mean_runtime)
        # save runtimes in every iteration to avoid interruptions
        with open("runtimes.txt", "w") as f:
            for n, runtime in zip(n_values, runtimes):
                f.write(f"{n} {runtime}\n")

    # zip n_values and runtimes to a list of pairs
    return list(zip(n_values, runtimes))

def plot_runtime(runtime_pairs, plot_file, degree):
    n_values, runtimes = zip(*runtime_pairs)
    plt.plot(n_values, runtimes, marker='o', label='Runtime')

    if degree:
        # Ajustement quadratique
        coeffs = np.polyfit(n_values, runtimes, degree)
        poly_eqn = np.poly1d(coeffs)

        # Générer des points x pour une courbe lisse
        x_continuous = np.linspace(min(n_values), max(n_values), 100)
        y_fitted = poly_eqn(x_continuous)

        # polynomial_formula = " + ".join(f"{float(coeff):.2f} * n^{i}" for i, coeff in enumerate(coeffs[::-1]))
        # polynomial_formula = f"${polynomial_formula}$"
        polynomial_formula = ""

        # Tracer la courbe ajustée de manière continue
        plt.plot(x_continuous, y_fitted, linestyle='--', label=f'Best fit curve with degree {degree} {polynomial_formula}')

    plt.legend()
    plt.xlabel('n')
    plt.ylabel('Runtime (seconds)')
    plt.title('Runtime vs n')
    plt.grid(True)
    plt.savefig(plot_file)

def main():
    parser = argparse.ArgumentParser(description="Run a command with varying input n, record runtime with hyperfine, and plot runtime vs n.")
    parser.add_argument("command", nargs='?', type=str, help="Command to run")
    parser.add_argument("--min_n", type=int, default=0, help="Minimum value of n (inclusive)")
    parser.add_argument("--max_n", type=int, default=100, help="Maximum value of n (inclusive)")
    parser.add_argument("--interval", type=int, default=20, help="Interval between consecutive n values")
    parser.add_argument("--plot_file", type=str, default="plot.png" ,help="Optional output file name for the plot")
    parser.add_argument("--time_file", type=str, default=None, help="Optional input file name for the runtimes")
    parser.add_argument("--degree", type=int, default=None, help="Degree of polynomial for fitting")

    args = parser.parse_args()
    
    if args.time_file:
        with open(args.time_file, "r") as f:
            runtime_pairs = [tuple(map(float, line.strip().split())) for line in f]
        plot_runtime(runtime_pairs, args.plot_file, args.degree)
    else:
        n_values = list(range(args.min_n, args.max_n + 1, args.interval))
        runtime_pairs = run_command_with_hyperfine(args.command, n_values, args.plot_file)
        plot_runtime(runtime_pairs, args.plot_file, args.degree)
    

if __name__ == "__main__":
    main()
