import matplotlib.pyplot as plt
import subprocess
import re
import argparse


def print_message(message):
    print(f"{'='*len(message)}\n{message}\n{'='*len(message)}")

input_range = range(500, 5001, 500)
# Comment the line below to reproduce the plot in the paper. 
input_range = range(50, 501, 50)
warmup_runs = 3
max_runs = 1000

def parse_output(output_file):
    pairs = []
    f = open(output_file, 'r')
    for line in f.readlines()[1:]:
        command = line.split(",")[0]
        n = int(re.search(r'\d+', command).group())
        mean_time = float(line.split(",")[1])
        pairs.append((n, mean_time))
    return pairs

def plot(file_with_tick, file_without_tick, title, plot_file):
    plt.figure(figsize=(5,5))

    n_values, runtimes = zip(*parse_output(file_with_tick))
    plt.plot(n_values, runtimes, marker='o', label='With Tick', alpha=1)

    n_values, runtimes = zip(*parse_output(file_without_tick))
    plt.plot(n_values, runtimes, marker='o', label='Without Tick', alpha=0.5)

    plt.legend()
    plt.xlabel('n')
    plt.ylabel('Runtime (seconds)')
    plt.title(title)
    plt.grid(True)
    plt.savefig(plot_file, dpi=300)

    print_message(f"\"{title}\" saved to {plot_file}")

def bench_and_plot_effekt():
    effekt_scheduler_build = "cd ../benchmark-programs/effekt/scheduler && effekt022.sh --backend js --compile main.effekt"
    effekt_scheduler_run = "'node --eval \"require('\\''../benchmark-programs/effekt/scheduler/out/main.js'\\'').main()\" -- _ {}'"
    effekt_result_file = "result_effekt_scheduler.csv"
    effekt_scheduler_command = f"hyperfine --warmup {warmup_runs} -M {max_runs} --export-csv {effekt_result_file} " + " ".join([effekt_scheduler_run.format(i) for i in input_range])

    effekt_scheduler_notick_build = "cd ../benchmark-programs/effekt/scheduler_notick && effekt022.sh --backend js --compile main.effekt"
    effekt_scheduler_notick_run = "'node --eval \"require('\\''../benchmark-programs/effekt/scheduler_notick/out/main.js'\\'').main()\" -- _ {}'"
    effekt_result_notick_file = "result_effekt_scheduler_notick.csv"
    effekt_scheduler_notick_command = f"hyperfine --warmup {warmup_runs} -M {max_runs} --export-csv {effekt_result_notick_file} " + " ".join([effekt_scheduler_notick_run.format(i) for i in input_range])

    try:
        print_message("Building Effekt's Scheduler")
        subprocess.run(effekt_scheduler_build, check=True, text=True, capture_output=True, shell=True)
        print_message("Building Effekt's Scheduler without Tick")
        subprocess.run(effekt_scheduler_notick_build, check=True, text=True, capture_output=True, shell=True)

        print_message("Running and benchmarking Effekt's Scheduler")
        subprocess.run(effekt_scheduler_command, check=True, text=True, shell=True)
        print_message("Running and benchmarking Effekt's Scheduler without Tick")
        subprocess.run(effekt_scheduler_notick_command, check=True, text=True, shell=True)
    except subprocess.CalledProcessError as e:
        print_message(e.stderr)
        exit(1)

    plot(effekt_result_file, effekt_result_notick_file, "Effekt's Scheduler with and without Tick", "effekt-plot.png")

def bench_and_plot_lexi():
    lexi_scheduler_build = "cd ../benchmark-programs/lexi/scheduler && dune exec -- sstal main.ir -o main.c && clang-format -i main.c && clang -O3 -g -I ../../../stacktrek main.c -o main"
    lexi_scheduler_run = "'../benchmark-programs/lexi/scheduler/main {}'"
    lexi_result_file = "result_lexi_scheduler.csv"
    lexi_scheduler_command = f"hyperfine --warmup {warmup_runs} -M {max_runs} --export-csv {lexi_result_file} " + " ".join([lexi_scheduler_run.format(i) for i in input_range])

    lexi_scheduler_notick_build = "cd ../benchmark-programs/lexi/scheduler_notick && dune exec -- sstal main.ir -o main.c && clang-format -i main.c && clang -O3 -g -I ../../../stacktrek main.c -o main"
    lexi_scheduler_notick_run = "'../benchmark-programs/lexi/scheduler_notick/main {}'"
    lexi_result_notick_file = "result_lexi_scheduler_notick.csv"
    lexi_scheduler_notick_command = f"hyperfine --warmup {warmup_runs} -M {max_runs} --export-csv {lexi_result_notick_file} " + " ".join([lexi_scheduler_notick_run.format(i) for i in input_range])

    try:
        print_message("Building Lexi's Scheduler")
        subprocess.run(lexi_scheduler_build, check=True, text=True, capture_output=True, shell=True)
        print_message("Building Lexi's Scheduler without Tick")
        subprocess.run(lexi_scheduler_notick_build, check=True, text=True, capture_output=True, shell=True)

        print_message("Running and benchmarking Lexi's Scheduler")
        subprocess.run(lexi_scheduler_command, check=True, text=True, shell=True)
        print_message("Running and benchmarking Lexi's Scheduler without Tick")
        subprocess.run(lexi_scheduler_notick_command, check=True, text=True, shell=True)
    except subprocess.CalledProcessError as e:
        print_message(e.stderr)
        exit(1)

    plot(lexi_result_file, lexi_result_notick_file, "Lexi's Scheduler with and without Tick", "lexi-plot.png")

def main():
    parser = argparse.ArgumentParser(description="Process the --kicktire argument")
    parser.add_argument('--kick-tire', action='store_true', help='Enable the kicktire option')
    
    args = parser.parse_args()
    
    if args.kick_tire:
        global warmup_runs
        global max_runs
        warmup_runs = 0
        max_runs = 1
        print_message("Kicktire mode enabled.")

    bench_and_plot_effekt()
    bench_and_plot_lexi()
    print_message("Done.")

if __name__ == "__main__":
    main()
